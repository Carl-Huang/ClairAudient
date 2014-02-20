//
//  MusicMixerOutput.h
//  Record_Mix_Play
//
//  Created by vedon on 4/1/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface MusicMixerOutput : NSObject
+ (OSStatus)mixAudio:(NSString *)audioPath1
            andAudio:(NSString *)audioPath2
              toFile:(NSString *)outputPath
  preferedSampleRate:(float)sampleRate
  withCompletedBlock:(void (^)(id object ,NSError * error))completedBlock;

+(void)appendAudioFile:(NSString *)filePath toFile:(NSString *)appendedFile compositionPath:(NSString *)compositionPath compositionTimes:(NSInteger)times withCompletedBlock:(void (^)(NSError * error,BOOL isFinish))block;
@end
