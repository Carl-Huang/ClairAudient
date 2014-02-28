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
    
    if( self.isRecording ){
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
@end
