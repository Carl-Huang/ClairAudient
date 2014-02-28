//
//  EZRecorder.m
//  EZAudio
//
//  Created by Syed Haris Ali on 12/1/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "EZRecorder.h"

#import "EZAudio.h"
#import "lame.h"

@interface EZRecorder (){
  AudioConverterRef           _audioConverter;
  AudioStreamBasicDescription _clientFormat;
  ExtAudioFileRef             _destinationFile;
  CFURLRef                    _destinationFileURL;
  AudioStreamBasicDescription _destinationFormat;
  AudioStreamBasicDescription _sourceFormat;
    
    NSError     * lameFileError;
    NSString    * lameFilePath;
    lame_t      lame;
    FILE        *fileHandler;
    int         write;
    unsigned char * mp3_buffer;
}

typedef struct {
  AudioBufferList *sourceBuffer;
} EZRecorderConverterStruct;

@end

@implementation EZRecorder

#pragma mark - Initializers
-(EZRecorder*)initWithDestinationURL:(NSURL*)url
                     andSourceFormat:(AudioStreamBasicDescription)sourceFormat withExtension:(NSString *)audioFileExtension{
  self = [super init];
  if(self){
      //<<Add by vedon 2014-2-25
      lameFilePath = [url path];
      NSLog(@"out path: %@", lameFilePath);
      NSString * tempFilePath = [lameFilePath stringByDeletingPathExtension];
      lameFilePath = [tempFilePath stringByAppendingPathExtension:audioFileExtension];
      
      fileHandler = fopen([lameFilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb");
      if (fileHandler == NULL) {
          lameFileError = [NSError errorWithDomain:@"OpenFileError" code:100 userInfo:nil];
          NSLog(@"fopen file Error");
      }
      
    _destinationFileURL = (__bridge CFURLRef)url;
    _sourceFormat = sourceFormat;
    _destinationFormat = [EZRecorder defaultDestinationFormat];
    [self _configureRecorder];
  }
  return self;
}

#pragma mark - Class Initializers
+(EZRecorder*)recorderWithDestinationURL:(NSURL*)url
                         andSourceFormat:(AudioStreamBasicDescription)sourceFormat
                  destinateFileExtension:(NSString *)ext{
  return [[EZRecorder alloc] initWithDestinationURL:url
                                    andSourceFormat:sourceFormat withExtension:ext];
}

#pragma mark - Class Format Helper
+(AudioStreamBasicDescription)defaultDestinationFormat {
  AudioStreamBasicDescription destinationFormat;
  destinationFormat.mFormatID = kAudioFormatLinearPCM;
  destinationFormat.mChannelsPerFrame = 1;
  destinationFormat.mBitsPerChannel = 16;
  destinationFormat.mBytesPerPacket = destinationFormat.mBytesPerFrame = 2 * destinationFormat.mChannelsPerFrame;
  destinationFormat.mFramesPerPacket = 1;
  destinationFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger; // little-endian
  destinationFormat.mSampleRate = 44100.0;
  return destinationFormat;
}

+(NSString *)defaultDestinationFormatExtension {
  return @"caf";
}

#pragma mark - Private Configuation
-(void)_configureRecorder {
  
    
  // Create the extended audio file
  [EZAudio checkResult:ExtAudioFileCreateWithURL(_destinationFileURL,
                                               kAudioFileCAFType,
                                               &_destinationFormat,
                                               NULL,
                                               kAudioFileFlags_EraseFile,
                                               &_destinationFile)
           operation:"Failed to create ExtendedAudioFile reference"];
  
  // Set the client format
  _clientFormat = _destinationFormat;
  if( _destinationFormat.mFormatID != kAudioFormatLinearPCM ){
    [EZAudio setCanonicalAudioStreamBasicDescription:_destinationFormat
                                    numberOfChannels:_destinationFormat.mChannelsPerFrame
                                         interleaved:YES];
  }
  UInt32 propertySize = sizeof(_clientFormat);
  [EZAudio checkResult:ExtAudioFileSetProperty(_destinationFile,
                                               kExtAudioFileProperty_ClientDataFormat,
                                               propertySize,
                                               &_clientFormat)
             operation:"Failed to set client data format on destination file"];
  
  // Instantiate the writer
  [EZAudio checkResult:ExtAudioFileWriteAsync(_destinationFile, 0, NULL)
             operation:"Failed to initialize with ExtAudioFileWriteAsync"];
  
  // Setup the audio converter
  [EZAudio checkResult:AudioConverterNew(&_sourceFormat, &_clientFormat, &_audioConverter)
             operation:"Failed to create new audio converter"];
  [self initLameCoder];
}

#pragma mark - Lame
-(void)initLameCoder
{
    lame = lame_init();
    lame_set_num_channels(lame,_clientFormat.mChannelsPerFrame);
    lame_set_in_samplerate(lame, _clientFormat.mSampleRate);
    lame_set_brate(lame, 88);
    lame_set_mode(lame, 1);
    lame_set_quality(lame, 2);
    lame_init_params(lame);
    
    const int MP3_SIZE  = 32 * 1024;
    mp3_buffer = malloc(sizeof(unsigned char)* MP3_SIZE);
}

#pragma mark - Events
-(void)appendDataFromBufferList:(AudioBufferList*)bufferList
                 withBufferSize:(UInt32)bufferSize {
    
  // Setup output buffers
  const int MP3_SIZE  = 32 * 1024; // 32 KB
  AudioBufferList *convertedData = [EZAudio audioBufferList];
  convertedData->mNumberBuffers = 1;
  convertedData->mBuffers[0].mNumberChannels = _clientFormat.mChannelsPerFrame;
  convertedData->mBuffers[0].mDataByteSize   = MP3_SIZE;
  convertedData->mBuffers[0].mData           = (UInt8*)malloc(sizeof(UInt8)*MP3_SIZE);
    
    //Start Audio convert asyn
      [EZAudio checkResult:AudioConverterFillComplexBuffer(_audioConverter,
                                                       complexInputDataProc,
                                                       &(EZRecorderConverterStruct){ .sourceBuffer = bufferList },
                                                       &bufferSize,
                                                       convertedData,
                                                       NULL) operation:"Failed while converting buffers"];
  
  // Write the destination audio buffer list into t
  [EZAudio checkResult:ExtAudioFileWriteAsync(_destinationFile, bufferSize, convertedData)
             operation:"Failed to write audio data to file"];

    if (lameFileError == nil) {
        //
        
        
        if (_clientFormat.mFormatFlags != kAudioFormatFlagIsNonInterleaved) {
            write = lame_encode_buffer(lame, convertedData->mBuffers[0].mData, convertedData->mBuffers[0].mData, bufferSize, mp3_buffer, 2*bufferSize);
            
        }else
            
        {
            write = lame_encode_buffer_interleaved(lame, convertedData->mBuffers[0].mData, convertedData->mBuffers[0].mDataByteSize, mp3_buffer, convertedData->mBuffers[0].mDataByteSize/2);
        }
        
        fwrite(mp3_buffer,write, 1, fileHandler);
    }
    
  // Free resources
  [EZAudio freeBufferList:convertedData];
  
}

static OSStatus complexInputDataProc(AudioConverterRef             inAudioConverter,
                                     UInt32                        *ioNumberDataPackets,
                                     AudioBufferList               *ioData,
                                     AudioStreamPacketDescription  **outDataPacketDescription,
                                     void                          *inUserData) {
  EZRecorderConverterStruct *recorderStruct = (EZRecorderConverterStruct*)inUserData;
  
  if ( !recorderStruct->sourceBuffer ) {
    return -2222; // No More Data
  }

  memcpy(ioData,
         recorderStruct->sourceBuffer,
         sizeof(AudioBufferList) + (recorderStruct->sourceBuffer->mNumberBuffers-1)*sizeof(AudioBuffer));
  recorderStruct->sourceBuffer = NULL;
  
  return noErr;
}

#pragma mark - Cleanup
-(void)dealloc {
    free(mp3_buffer);
    fclose(fileHandler);
    lame_close(lame);
  [EZAudio checkResult:AudioConverterDispose(_audioConverter)
             operation:"Failed to dispose audio converter in recorder"];
  [EZAudio checkResult:ExtAudioFileDispose(_destinationFile)
             operation:"Failed to dispose extended audio file in recorder"];
}

@end
