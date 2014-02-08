//
//  MusicMixer.h
//  Record_Mix_Play
//
//  Created by vedon on 3/1/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>

#define MAXBUFS  2
#define NUMFILES 2

#define VAudioSampleRate  44100.0


typedef struct {
    AudioStreamBasicDescription asbd;
    AudioSampleType *data;
	UInt32 numFrames;
} SoundBuffer, *SoundBufferPtr;

typedef struct {
	UInt32 frameNum;
    UInt32 maxNumFrames;
    SoundBuffer soundBuffer[MAXBUFS];
} SourceAudioBufferData, *SourceAudioBufferDataPtr;

typedef struct AudioBufferListArray
{
    AudioBufferList * audioData;
    UInt32 numFrame;
    struct AudioBufferListArray * pNext;
}AudioBufferListArray;


@interface MusicMixer : NSObject
{
    CFURLRef sourceURL[2];
    
	AUGraph   mGraph;
    AudioUnit mEQ;
	AudioUnit mMixer;
    
    NSMutableArray * audioData;
    ExtAudioFileRef  extAudioFile;
    Boolean mIsPlaying;
    
    AudioStreamBasicDescription mClientFormat;
    AudioStreamBasicDescription mOutputFormat;
    
    CFArrayRef mEQPresetsArray;
    
    SourceAudioBufferData mUserData;

    //保存AudioBufferList
    AudioBufferListArray * head,*q,*p;
}

@property (readonly, nonatomic, getter=isPlaying) Boolean mIsPlaying;
@property (readonly, nonatomic, getter=iPodEQPresetsArray) CFArrayRef mEQPresetsArray;

- (void)initializeAUGraph;

- (void)enableInput:(UInt32)inputNum isOn:(AudioUnitParameterValue)isONValue;
- (void)setInputVolume:(UInt32)inputNum value:(AudioUnitParameterValue)value;
- (void)setOutputVolume:(AudioUnitParameterValue)value;
- (void)selectEQPreset:(NSInteger)value;

- (void)startAUGraph;
- (void)stopAUGraph;

- (void) processAudio: (AudioBufferList*) bufferList withNum:(UInt32)numFrame;
@end
extern MusicMixer* audioUnitHelper;
