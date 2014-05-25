//
//  SoundMaker.m
//  SimpleRecord
//
//  Created by vedon on 2/3/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//
#define DebugLog 1
#define FramesSize 1024*3

#import "SoundMaker.h"
#import "STTypes.h"
#import "FIFOSampleBuffer.h"
#include <sys/timeb.h>

using namespace soundtouch;
@interface SoundMaker()
{
    ExtAudioFileRef   _audioFile;
    CFURLRef          _sourceURL;
    
    CFURLRef  _destinationFileURL;
    ExtAudioFileRef   _destinationFile;
    
    AudioStreamBasicDescription _clientFormat;
    AudioStreamBasicDescription _fileFormat;
     NSMutableData *soundTouchDatas;
    
    int audioBufferSize;
    timeb ts1,ts2;
    int timeOffset;
    
    CompletedBlock completedBlock;
}
@end

@implementation SoundMaker
{
    soundtouch::SoundTouch mSoundTouch;
   
}

#pragma mark - Public
-(void)initalizationSoundTouchWithSampleRate:(NSUInteger)sampleRate
                                    Channels:(NSUInteger)channel
                                 TempoChange:(CGFloat)tempoChange
                              PitchSemiTones:(NSInteger)semiTones
                                  RateChange:(CGFloat)rateChange
                         processingAudioFile:(NSString *)filePath
                                    destPath:(NSString *)destPath
                              completedBlock:(CompletedBlock)block
{
    mSoundTouch.setSampleRate(sampleRate);
    mSoundTouch.setChannels(channel);
    mSoundTouch.setTempoChange(tempoChange);
    mSoundTouch.setPitchSemiTones(semiTones);
    mSoundTouch.setRateChange(rateChange);
    mSoundTouch.setSetting(SETTING_SEQUENCE_MS, 40);
    mSoundTouch.setSetting(SETTING_SEEKWINDOW_MS, 16);
    mSoundTouch.setSetting(SETTING_OVERLAP_MS, 8);
    if (block) {
        completedBlock = [block copy];
    }
    [self convertAudioFileWithPath:filePath destinationPath:destPath];
    
}

-(void)initalizationSoundTouchWithSampleRate:(NSUInteger)sampleRate
                                    Channels:(NSUInteger)channel
                                 TempoChange:(CGFloat)tempoChange
                              PitchSemiTones:(NSInteger)semiTones
                                  RateChange:(CGFloat)rateChange
{
    mSoundTouch.setSampleRate(sampleRate);
    mSoundTouch.setChannels(channel);
    mSoundTouch.setTempoChange(tempoChange);
    mSoundTouch.setPitchSemiTones(semiTones);
    mSoundTouch.setRateChange(rateChange);
    mSoundTouch.setSetting(SETTING_SEQUENCE_MS, 40);
    mSoundTouch.setSetting(SETTING_SEEKWINDOW_MS, 16);
    mSoundTouch.setSetting(SETTING_OVERLAP_MS, 8);
}


-(void)processingSample:(soundtouch::SAMPLETYPE *)inSamples
                 length:(NSUInteger)nSamples
{
    audioBufferSize = nSamples;
    mSoundTouch.putSamples(inSamples, nSamples);
}

-(void)fillSamples:(soundtouch::SAMPLETYPE *)sample reveivedSamplesLength:(NSInteger *)nSamplesPerChannel maxSampleLength:(NSInteger)maxSampleLength
{
    *nSamplesPerChannel = mSoundTouch.receiveSamples(sample, maxSampleLength);
}

-(void)pullLastSampleFromPipe;
{
    mSoundTouch.flush();
}

#pragma mark - Private
-(void)convertAudioFileWithPath:(NSString *)path destinationPath:(NSString *)desPath
{
    if ([[NSFileManager defaultManager]fileExistsAtPath:path]) {
        [self writeSoundTouchDataTo:desPath dataFormat:[self configureAudioFile:[NSURL fileURLWithPath:path]]];
            [self processingBuffer];
    }
}

-(AudioStreamBasicDescription)configureAudioFile:(NSURL *)url
{
    _sourceURL = (__bridge CFURLRef)url;
    
    // Try to open the file for reading
    [SoundMaker checkResult:ExtAudioFileOpenURL(_sourceURL,&_audioFile)
               operation:"Failed to open audio file for reading"];
    
    // Try pulling the stream description
    UInt32 size = sizeof(_fileFormat);
    [SoundMaker checkResult:ExtAudioFileGetProperty(_audioFile,kExtAudioFileProperty_FileDataFormat, &size, &_fileFormat)
               operation:"Failed to get audio stream basic description of input file"];
    [SoundMaker printASBD:_fileFormat];
    
    // Set the client format on the stream
    _clientFormat.mBitsPerChannel   = 8 * sizeof(AudioSampleType);
    _clientFormat.mBytesPerFrame    = sizeof(AudioSampleType);
    _clientFormat.mBytesPerPacket   = sizeof(AudioSampleType);
    _clientFormat.mChannelsPerFrame = 1;
    _clientFormat.mFormatFlags      = kAudioFormatFlagsCanonical | kAudioFormatFlagIsNonInterleaved;
    _clientFormat.mFormatID         = kAudioFormatLinearPCM;
    _clientFormat.mFramesPerPacket  = 1;
    _clientFormat.mSampleRate       = 20000;
    
    [SoundMaker checkResult:ExtAudioFileSetProperty(_audioFile,
                                                 kExtAudioFileProperty_ClientDataFormat,
                                                 sizeof (AudioStreamBasicDescription),
                                                 &_clientFormat)
     operation:"Couldn't set client data format on input ext file"];
    
    return  _clientFormat;
}


-(void)processingBuffer
{
    soundTouchDatas = [[NSMutableData alloc] init];
    UInt32 frames = FramesSize;
    UInt32 outputBufferSize = _clientFormat.mBytesPerFrame * FramesSize ;
    AudioBufferList * audioBufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
    audioBufferList->mNumberBuffers = 1;
    audioBufferList->mBuffers->mNumberChannels = _clientFormat.mChannelsPerFrame;
    audioBufferList->mBuffers->mDataByteSize = outputBufferSize;
    audioBufferList->mBuffers->mData =(SAMPLETYPE *) malloc(outputBufferSize);
    

    AudioBufferList * localBufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
    localBufferList->mNumberBuffers = 1;
    localBufferList->mBuffers->mNumberChannels = _clientFormat.mChannelsPerFrame;
    localBufferList->mBuffers->mData =(SAMPLETYPE *) malloc(outputBufferSize);

    SAMPLETYPE * audioData = (SAMPLETYPE *)malloc(2*outputBufferSize);
    ftime(&ts1);
    do {
        memset(audioBufferList->mBuffers->mData, 0, outputBufferSize);
        [SoundMaker checkResult:ExtAudioFileRead(_audioFile,
                                              &frames,
                                              audioBufferList)
         operation:"Failed to read audio data from audio file"];
        [self processingSample:(SAMPLETYPE *)audioBufferList->mBuffers->mData length:outputBufferSize/2];

        int nSamples = 0;
        do {
            [self fillSamples:audioData reveivedSamplesLength:&nSamples maxSampleLength:outputBufferSize];
            if (nSamples!=0) {
                int bufferSize = nSamples*2;
                localBufferList->mBuffers->mDataByteSize = nSamples;
                memcpy(localBufferList->mBuffers->mData, audioData, bufferSize);
                
                [SoundMaker checkResult:ExtAudioFileWriteAsync(_destinationFile,bufferSize/_clientFormat.mBytesPerFrame, localBufferList)
                              operation:"Failed to write audio data to file"];

            }
        } while (nSamples!=0);
        
        
//        [self fillSamples:audioData maxSampleLength:outputBufferSize completedBlock:^(int bufferSize, AudioBufferList *audioBufferList) {
//            [SoundMaker checkResult:ExtAudioFileWrite(_destinationFile,bufferSize/_clientFormat.mBytesPerFrame, audioBufferList)
//                          operation:"Failed to write audio data to file"];
//        }];
    } while (frames!= 0 );
    
    ftime(&ts2);
    timeOffset = (ts2.time - ts1.time) + (ts2.millitm - ts1.millitm)/1000;
    NSLog(@"%d",timeOffset);
    [SoundMaker checkResult:ExtAudioFileDispose(_destinationFile)
                             operation:"Failed to dispose extended audio file in recorder"];
    free(localBufferList ->mBuffers->mData);
    free(localBufferList);
    
    free(audioData);
    free(audioBufferList->mBuffers->mData);
    free(audioBufferList);
    
    if (completedBlock) {
        completedBlock(YES,nil);
    }
    
}

-(void)fillSamples:(soundtouch::SAMPLETYPE *)audioData maxSampleLength:(NSInteger)maxSampleLength completedBlock:(CompletedBufferBlock )block
{
    int nSamples = 0;
    do {
        [self fillSamples:audioData reveivedSamplesLength:&nSamples maxSampleLength:audioBufferSize];
        
        if (nSamples!=0) {
            int bufferSize = nSamples*2;
            AudioBufferList * localBufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
            localBufferList->mNumberBuffers = 1;
            localBufferList->mBuffers->mNumberChannels = _clientFormat.mChannelsPerFrame;
            localBufferList->mBuffers->mDataByteSize = bufferSize/2;
            localBufferList->mBuffers->mData = malloc(bufferSize);
            memcpy(localBufferList->mBuffers->mData, audioData, bufferSize);
            
            if (block) {
                block(bufferSize,localBufferList);
            }
            free(localBufferList ->mBuffers->mData);
            free(localBufferList);
        }
    } while (nSamples!=0);
}


-(void)writeSoundTouchDataTo:(NSString *)souchTouchFilePath dataFormat:(AudioStreamBasicDescription)format
{
    AudioStreamBasicDescription destinationFormat;
    destinationFormat.mFormatID = kAudioFormatLinearPCM;
    destinationFormat.mBitsPerChannel = sizeof(AudioSampleType) * 8;
    destinationFormat.mBytesPerPacket = destinationFormat.mBytesPerFrame =sizeof(AudioSampleType);
    destinationFormat.mFramesPerPacket = 1;
    destinationFormat.mChannelsPerFrame = 1;
    destinationFormat.mFormatFlags = kAudioFormatFlagsCanonical | kAudioFormatFlagIsNonInterleaved;
    destinationFormat.mSampleRate = format.mSampleRate;
    
    NSURL * url = [NSURL fileURLWithPath:souchTouchFilePath];
    
    _destinationFileURL = (__bridge CFURLRef)url;
    [SoundMaker checkResult:ExtAudioFileCreateWithURL(_destinationFileURL,
                                                      kAudioFileCAFType,
                                                      &destinationFormat,
                                                      NULL,
                                                      kAudioFileFlags_EraseFile,
                                                      &_destinationFile)
                  operation:"Failed to create ExtendedAudioFile reference"];
    // Set the client format
    AudioStreamBasicDescription clientFormat = destinationFormat;
    UInt32 propertySize = sizeof(clientFormat);
    [SoundMaker checkResult:ExtAudioFileSetProperty(_destinationFile,
                                                    kExtAudioFileProperty_ClientDataFormat,
                                                    propertySize,
                                                    &destinationFormat)
                  operation:"Failed to set client data format on destination file"];
    
    // Instantiate the writer
    [SoundMaker checkResult:ExtAudioFileWriteAsync(_destinationFile, 0, NULL)
                  operation:"Failed to initialize with ExtAudioFileWriteAsync"];
}

#pragma mark - OSStatus Utility
+(void)checkResult:(OSStatus)result
         operation:(const char *)operation {
	if (result == noErr) return;
	char errorString[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(result);
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(errorString, "%d", (int)result);
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
	exit(1);
}

+(void)printASBD:(AudioStreamBasicDescription)asbd {
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    (unsigned int)asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    (unsigned int)asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    (unsigned int)asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    (unsigned int)asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    (unsigned int)asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    (unsigned int)asbd.mBitsPerChannel);
}
@end
