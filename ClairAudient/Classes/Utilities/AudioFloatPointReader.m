//
//  AudioFloatPointReader.m
//  SimpleRecord
//
//  Created by vedon on 27/2/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "AudioFloatPointReader.h"
@interface AudioFloatPointReader()
{
    NSURL * curentPlayFileURL;
}
@end
@implementation AudioFloatPointReader

+(id)shareAudioFloatPointReader
{
    static AudioFloatPointReader * shareReader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareReader = [[AudioFloatPointReader alloc]init];
    });
    return shareReader;
}

-(void)playAudioFile:(NSURL *)filePath
{
    // Stop playback
    [[EZOutput sharedOutput] stopPlayback];
    curentPlayFileURL      = filePath;
    self.audioFile         = [EZAudioFile audioFileWithURL:filePath];
    _audioDuration         = (float)_audioFile.totalDuration;
    _totalFrame            = (float)_audioFile.totalFrames;
    self.audioFile.audioFileDelegate = self;
}

-(void)seekToFilePostion:(SInt64)position
{
    [_audioFile seekToFrame:position];
}

-(void)startReader
{
    if( ![[EZOutput sharedOutput] isPlaying] ){
        if( self.eof ){
            [self.audioFile seekToFrame:0];
        }
        [EZOutput sharedOutput].outputDataSource = self;
        [[EZOutput sharedOutput] startPlayback];
    }
    else {
        [EZOutput sharedOutput].outputDataSource = nil;
        [[EZOutput sharedOutput] stopPlayback];
    }

}

-(void)stopReader
{
    if ([[EZOutput sharedOutput] isPlaying]) {
        [EZOutput sharedOutput].outputDataSource = nil;
        [[EZOutput sharedOutput] stopPlayback];

    }
}

-(BOOL)isEof
{
    return _eof;
}

-(BOOL)isPlaying
{
    return  [EZOutput sharedOutput].isPlaying;
}

#pragma mark - Private
-(void)playNextSong
{
//    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i =0 ;i < [_playlist count];++i) {
            NSURL * localPath  = [_playlist objectAtIndex:i];
            if ([localPath.path isEqualToString:curentPlayFileURL.path]) {
                [self stopReader];
                if (i == [_playlist count]-1) {
                    [self playAudioFile:[_playlist objectAtIndex:0]];
                }else
                {
                    [self playAudioFile:[_playlist objectAtIndex:i+1]];
                }
                [self startReader];
                break;
            }
        }
//    });
}


-(void)setPlaylist:(NSArray *)playlist
{
    if (_playlist) {
        _playlist = nil;
    }
    _playlist = playlist;
    _isShouldPlayPlaylist = YES;
}
#pragma mark - EZAudioFileDelegate
-(void)audioFile:(EZAudioFile *)audioFile
       readAudio:(float **)buffer
  withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
//    NSLog(@"%f",*buffer[0]);
}

-(void)audioFile:(EZAudioFile *)audioFile
 updatedPosition:(SInt64)framePosition {
        _currentPositionOfAudioFile = (float)framePosition;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"AudioProcessingLocation" object:[NSNumber numberWithFloat:_currentPositionOfAudioFile]];

}

#pragma mark - EZOutputDataSource
-(AudioBufferList *)output:(EZOutput *)output
 needsBufferListWithFrames:(UInt32)frames
            withBufferSize:(UInt32 *)bufferSize {
    if( self.audioFile ){
        
        // Reached the end of the file
        if( self.eof ){
            // Here's what you do to loop the file
            if (_isShouldPlayPlaylist) {
                [self playNextSong];
            }else
            {
                [self.audioFile seekToFrame:0];
            }
            self.eof = NO;
        }
        
        // Allocate a buffer list to hold the file's data
        AudioBufferList *bufferList = [EZAudio audioBufferList];
        BOOL eof;
        [self.audioFile readFrames:frames
                   audioBufferList:bufferList
                        bufferSize:bufferSize
                               eof:&eof];
        self.eof = eof;
        
        // Reached the end of the file on the last read
        if( eof ){
            [EZAudio freeBufferList:bufferList];
            return nil;
        }
        return bufferList;
        
    }
    return nil;
}

-(AudioStreamBasicDescription)outputHasAudioStreamBasicDescription:(EZOutput *)output {
    return self.audioFile.clientFormat;
}
@end
