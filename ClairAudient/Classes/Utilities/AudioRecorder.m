//
//  AudioRecorder.m
//  ClairAudient
//
//  Created by vedon on 23/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.

#import "AudioRecorder.h"
#import <AVFoundation/AVFoundation.h>
@interface AudioRecorder()
{
    AVAudioRecorder * recorder;
    NSTimer         * meterTimer;
    CGFloat          currentMeter;
    BOOL            isTimeStop;
}
@end
@implementation AudioRecorder

+(AudioRecorder *)shareAudioRecord
{
    static AudioRecorder * shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[AudioRecorder alloc]init];
    });
    return shareInstance;
}

-(void)initRecordWithPath:(NSString *)localFilePath
{
   
    AVAudioSession * session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    //录音设置
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //录音格式 无法使用
    [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [settings setValue :[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];//44100.0
    //通道数
    [settings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
    //线性采样位数
    //[recordSettings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
    //音频质量,采样质量
    [settings setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    NSURL * recordedFile = [[NSURL alloc] initFileURLWithPath:localFilePath];
    recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:settings error:nil];
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    

    meterTimer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(updateMeterLevel) userInfo:nil repeats:YES];
    [meterTimer fire];
    isTimeStop = NO;
}

-(void)startRecord
{
    isTimeStop = NO;
    [recorder record];
}

-(void)pauseRecord
{
    isTimeStop = YES;
    [recorder pause];
}

-(void)stopRecord
{
    isTimeStop = YES;
    if (meterTimer) {
        [meterTimer invalidate];
        meterTimer = nil;
    }
    if (recorder) {
        recorder = nil;
    }
    [recorder stop];
}

-(CGFloat)meterLevel
{
    return currentMeter;
}

#pragma mark - Private method
-(void)updateMeterLevel
{
    if (isTimeStop) {
        currentMeter = 0;
    }else
    {
        [recorder updateMeters];
        currentMeter = [recorder peakPowerForChannel:0];
    }
}
@end
