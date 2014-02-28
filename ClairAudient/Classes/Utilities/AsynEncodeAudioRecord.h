//
//  AsynEncodeAudioRecord.h
//  SimpleRecord
//
//  Created by vedon on 26/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZAudio.h"
#import <AVFoundation/AVFoundation.h>
@interface AsynEncodeAudioRecord : NSObject<EZMicrophoneDelegate>

@property (nonatomic,strong) EZMicrophone *microphone;
@property (nonatomic,strong) EZRecorder *recorder;
@property (nonatomic,assign) BOOL isRecording;

+(id)shareAsynEncodeAudioRecord;
-(void)initializationAudioRecrodWithFileExtension:(NSString *)ext;
-(void)playFile:(NSString *)filePath;

-(void)startPlayer;
-(void)stopPlayer;
@end
