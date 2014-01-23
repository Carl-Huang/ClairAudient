//
//  AudioWriter.h
//  Audio_HelloWorld
//
//  Created by vedon on 7/1/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioManager.h"

@interface AudioWriter : NSObject
@property (nonatomic, copy) HWAudioInputBlock writerBlock;
@property (nonatomic, assign, getter=getDuration, readonly) float currentTime;
@property (nonatomic, assign, getter=getDuration, readonly) float duration;
@property (nonatomic, assign, readonly) float samplingRate;
@property (nonatomic, assign, readonly) UInt32 numChannels;
@property (nonatomic, assign, readonly) float latency;
@property (nonatomic, copy, readonly)   NSURL *audioFileURL;
@property (nonatomic, assign, readonly) BOOL recording;

- (id)initWithAudioFileURL:(NSURL *)urlToAudioFile samplingRate:(float)thisSamplingRate numChannels:(UInt32)thisNumChannels;
- (void)writeNewAudio:(float *)newData numFrames:(UInt32)thisNumFrames numChannels:(UInt32)thisNumChannels;

- (void)record;
- (void)pause;
- (void)stop;
@end
