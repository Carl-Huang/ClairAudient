//
//  AsynEncodeAudioRecord.m
//  SimpleRecord
//
//  Created by vedon on 26/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "AsynEncodeAudioRecord.h"


@implementation AsynEncodeAudioRecord
{
    NSString * audioFilePath;
    NSString * extension;
    char * copyAudioBuffer;
}
+(id)shareAsynEncodeAudioRecord
{
    static AsynEncodeAudioRecord * shareInstance  = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[AsynEncodeAudioRecord alloc]init];
    });
    return shareInstance;
}

#pragma mark - Public Method
-(void)startPlayer
{
    if (!self.isRecording ) {
        [self.microphone startFetchingAudio];
        
    }
    self.isRecording = YES;
}

-(void)stopPlayer
{
    if (self.isRecording) {
        [self.microphone stopFetchingAudio];
    }
    self.isRecording = NO;
}

-(void)initializationAudioRecrodWithFileExtension:(NSString *)ext;
{
    extension = ext;
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
}

-(void)playFile:(NSString *)filePath
{
    audioFilePath = filePath;
    [self startPlayer];
}

-(void)saveSoundMakerFile
{
    //    [soundMaker save];
}

#pragma mark - EZMicrophoneDelegate
-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    // Getting audio data as an array of float buffer arrays. What does that mean? Because the audio is coming in as a stereo signal the data is split into a left and right channel. So buffer[0] corresponds to the float* data for the left channel while buffer[1] corresponds to the float* data for the right channel.
    
    // See the Thread Safety warning above, but in a nutshell these callbacks happen on a separate audio thread. We wrap any UI updating in a GCD block on the main thread to avoid blocking that audio flow.
    dispatch_async(dispatch_get_main_queue(),^{
        // All the audio plot needs is the buffer data (float*) and the size. Internally the audio plot will handle all the drawing related code, history management, and freeing its own resources. Hence, one badass line of code gets you a pretty plot :)
        
    });
}

-(void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
    [EZAudio printASBD:audioStreamBasicDescription];
    
    
    
    self.recorder = [EZRecorder recorderWithDestinationURL:[self testFilePathURL]
                                           andSourceFormat:audioStreamBasicDescription destinateFileExtension:extension];
    
}

-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    
    //The incoming data is liner pcm data;
    if( self.isRecording ){
        
        if (_decibelBlock) {
            [self getTheDecibelFromAudioBufferList:bufferList numberOfFrames:bufferSize DBOffset:-83 lowPassFilter:0.2];
        }
        
        
        int dataSize = bufferList->mBuffers->mDataByteSize;
        if (copyAudioBuffer == NULL) {
            copyAudioBuffer = (char * )malloc(sizeof(char) * dataSize);
        }
        memset(copyAudioBuffer, 0, dataSize);
        memcpy(copyAudioBuffer, bufferList->mBuffers->mData, dataSize);
        
        
        
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
}

#pragma mark - Utility
-(NSArray*)applicationDocuments {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

-(NSString*)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(NSURL*)testFilePathURL {
    return [NSURL fileURLWithPath:audioFilePath];
}

-(void)getTheDecibelFromAudioBufferList:(AudioBufferList *)inputBuffer
                         numberOfFrames:(NSInteger)inNumberFrames
                               DBOffset:(NSInteger)DBOFFSET
                          lowPassFilter:(CGFloat)filter
{
    @autoreleasepool {
        SInt16* samples = (SInt16*)(inputBuffer->mBuffers[0].mData); // Step 1: get an array of your samples that you can loop through. Each sample contains the amplitude.
        
        Float32 decibels = DBOFFSET; // When we have no signal we'll leave this on the lowest setting
        Float32 currentFilteredValueOfSampleAmplitude, previousFilteredValueOfSampleAmplitude; // We'll need these in the low-pass filter
        Float32 peakValue = DBOFFSET; // We'll end up storing the peak value here
        
        for (int i=0; i < inNumberFrames; i++) {
            
            Float32 absoluteValueOfSampleAmplitude = abs(samples[i]); //Step 2: for each sample, get its amplitude's absolute value.
            
            // Step 3: for each sample's absolute value, run it through a simple low-pass filter
            // Begin low-pass filter
            currentFilteredValueOfSampleAmplitude = filter * absoluteValueOfSampleAmplitude + (1.0 - filter) * previousFilteredValueOfSampleAmplitude;
            previousFilteredValueOfSampleAmplitude = currentFilteredValueOfSampleAmplitude;
            Float32 amplitudeToConvertToDB = currentFilteredValueOfSampleAmplitude;
            // End low-pass filter
            
            Float32 sampleDB = 20.0*log10(amplitudeToConvertToDB) + DBOFFSET;
            // Step 4: for each sample's filtered absolute value, convert it into decibels
            // Step 5: for each sample's filtered absolute value in decibels, add an offset value that normalizes the clipping point of the device to zero.
            
            if((sampleDB == sampleDB) && (sampleDB != -DBL_MAX)) { // if it's a rational number and isn't infinite
                
                if(sampleDB > peakValue) peakValue = sampleDB; // Step 6: keep the highest value you find.
                decibels = peakValue; // final value
            }
        }
        if (_decibelBlock) {
            _decibelBlock(decibels);
        }
        //        NSLog(@"decibel level is %f", decibels);
    }
}
@end
