//
//  AudioFloatPointReader.h
//  SimpleRecord
//
//  Created by vedon on 27/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZAudio.h"


@interface AudioFloatPointReader : NSObject<EZAudioFileDelegate,EZOutputDataSource>

@property (nonatomic,strong) EZAudioFile *audioFile;
@property (assign ,nonatomic) CGFloat audioDuration;
@property (assign ,nonatomic) CGFloat totalFrame;
@property (assign ,nonatomic) CGFloat currentPositionOfAudioFile;
@property (strong ,nonatomic) NSArray *playlist;
@property (assign ,nonatomic) NSInteger currentPlaySongIndex;

@property (assign ,nonatomic) BOOL isShouldPlayPlaylist;
@property (assign ,nonatomic,getter = isEof) BOOL eof;
@property (assign ,nonatomic,getter = isPlaying) BOOL playing;
+(id)shareAudioFloatPointReader;

-(void)playAudioFile:(NSURL *)filePath;
-(void)seekToFilePostion:(SInt64)position;
-(void)startReader;
-(void)stopReader;
@end
