//
//  AudioManager.h
//  Audio_HelloWorld
//
//  Created by vedon on 7/1/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//
//
//  注意呀，兄弟：
//              1)不使用ARC
//
//
//
//
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>
#import <CoreAudio/CoreAudioTypes.h>
static void CheckError(OSStatus error, const char *operation)
{
	if (error == noErr) return;
	
	char str[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
	if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
		str[0] = str[5] = '\'';
		str[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(str, "%d", (int)error);
    
	fprintf(stderr, "Error: %s (%s)\n", operation, str);
    
	exit(1);
}
@interface AudioManager : NSObject

//处理输出，输入的block
typedef void (^HWAudioOutputBlock)(float *data, UInt32 numFrames, UInt32 numChannels);
typedef void (^HWAudioInputBlock)(float *data, UInt32 numFrames, UInt32 numChannels);


@property (nonatomic, assign)   BOOL forceOutputToSpeaker;


- (void)setInputBlock:(HWAudioOutputBlock)block;
- (void)setOutputBlock:(HWAudioInputBlock)block;
@property (nonatomic, copy) HWAudioOutputBlock outputBlock;
@property (nonatomic, copy) HWAudioInputBlock inputBlock;

//公共的属性设置为只读属性，不允许外部修改
@property (nonatomic, assign, readonly) AudioUnit inputUnit;
@property (nonatomic, assign, readonly) AudioUnit outputUnit;
@property (nonatomic, assign, readonly) AudioBufferList *inputBuffer;
@property (nonatomic, assign, readonly) BOOL inputAvailable;
@property (nonatomic, assign, readonly) UInt32 numInputChannels;
@property (nonatomic, assign, readonly) UInt32 numOutputChannels;
@property (nonatomic, assign, readonly) Float64 samplingRate;
@property (nonatomic, assign, readonly) BOOL isInterleaved;
@property (nonatomic, assign, readonly) UInt32 numBytesPerSample;
@property (nonatomic, assign, readonly) AudioStreamBasicDescription inputFormat;
@property (nonatomic, assign, readonly) AudioStreamBasicDescription outputFormat;
@property (nonatomic, assign, readonly) BOOL playing;

@property (nonatomic, copy)     NSString *inputRoute;
//搞一个单例来处理，比较方便
+(AudioManager *)shareAudioManager;

// Audio Unit 的方法
- (void)play;
- (void)pause;

- (void)audio_PCMtoMP3WithSourceFile:(NSString *)sourceFile destinationFile:(NSString *)desFile withSampleRate:(NSInteger)sampleRate;
//AudioSession 属性
- (void)checkSessionProperties;
- (void)checkAudioSource;
@end
