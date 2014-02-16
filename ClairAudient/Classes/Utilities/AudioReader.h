//
//  AudioReader.h
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
#import "RingBuffer.h"
#import "AudioManager.h"

@protocol AudioReaderDelegate <NSObject>

-(void)currentFileLocation:(CGFloat)location;

@end
@interface AudioReader : NSObject

@property (nonatomic, assign, getter=   getCurrentTime, setter=setCurrentTime:) float currentTime;
@property (nonatomic, copy)             HWAudioInputBlock readerBlock;
@property (nonatomic, assign) float     latency;
@property (nonatomic, copy, readonly)   NSURL *audioFileURL;
@property (nonatomic, assign, readonly, getter=getDuration) float duration;
@property (nonatomic, assign, readonly) float samplingRate;
@property (nonatomic, assign, readonly) UInt32 numChannels;
@property (nonatomic, assign, readonly) BOOL playing;
@property (assign ,nonatomic) id<AudioReaderDelegate>delegate;



- (id)initWithAudioFileURL:(NSURL *)urlToAudioFile samplingRate:(float)thisSamplingRate numChannels:(UInt32)thisNumChannels;
- (void)retrieveFreshAudio:(float *)buffer numFrames:(UInt32)thisNumFrames numChannels:(UInt32)thisNumChannels;

- (void)play;
- (void)pause;
- (void)stop;

- (float)getDuration;
@end
