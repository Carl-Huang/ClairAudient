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

typedef  void (^GetDecibelFromRecorder) (CGFloat decibel);
@interface AsynEncodeAudioRecord : NSObject<EZMicrophoneDelegate>

@property (nonatomic,strong) EZMicrophone *microphone;
@property (nonatomic,strong) EZRecorder *recorder;
@property (nonatomic,assign) BOOL isRecording;
@property (nonatomic,strong) GetDecibelFromRecorder decibelBlock;
+(id)shareAsynEncodeAudioRecord;
-(void)initializationAudioRecrodWithFileExtension:(NSString *)ext;
-(void)playFile:(NSString *)filePath;

-(void)startPlayer;
-(void)stopPlayer;
-(void)saveSoundMakerFile;
@end
