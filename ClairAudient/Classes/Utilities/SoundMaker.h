//
//  SoundMaker.h
//  SimpleRecord
//
//  Created by vedon on 2/3/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SoundTouch.h"
#import <AudioToolbox/AudioToolbox.h>

typedef void(^CompletedBufferBlock) (int bufferSize,AudioBufferList * audioBufferList);
typedef void(^CompletedBlock) (BOOL isSuccess,NSError * error);
@interface SoundMaker : NSObject
@property (assign ,nonatomic) AudioStreamBasicDescription audio_des;


-(void)initalizationSoundTouchWithSampleRate:(NSUInteger)sampleRate
                                    Channels:(NSUInteger)channel
                                 TempoChange:(CGFloat)tempoChange
                              PitchSemiTones:(NSInteger)semiTones
                                  RateChange:(CGFloat)rateChange
                         processingAudioFile:(NSString *)filePath
                                    destPath:(NSString *)destPath
                              completedBlock:(CompletedBlock)block;

-(void)initalizationSoundTouchWithSampleRate:(NSUInteger)sampleRate
                                    Channels:(NSUInteger)channel
                                 TempoChange:(CGFloat)tempoChange
                              PitchSemiTones:(NSInteger)semiTones
                                  RateChange:(CGFloat)rateChange;


-(void)processingSample:(soundtouch::SAMPLETYPE *)inSamples
                 length:(NSUInteger)nSamples;
-(void)fillSamples:(soundtouch::SAMPLETYPE *)sample reveivedSamplesLength:(NSInteger *)nSamplesPerChannel maxSampleLength:(NSInteger)maxSampleLength;



-(void)pullLastSampleFromPipe;

@end
