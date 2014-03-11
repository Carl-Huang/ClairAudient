//
//  StreamPlayer.m
//  ClairAudient
//
//  Created by vedon on 11/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "StreamPlayer.h"
@interface StreamPlayer()
{
    AudioPlayer * audioPlayer ;
}

@end
@implementation StreamPlayer

+(id)shareStreamPlayer
{
    static StreamPlayer * player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[StreamPlayer alloc]init];
    });
    return player;
}

-(void)playFile:(NSURL *)url
{
    if (audioPlayer == nil) {
        audioPlayer = [[AudioPlayer alloc]init];
    }
    if ([audioPlayer isProcessing]) {
        [audioPlayer stop];
    }
    [audioPlayer setBlock:^(double processOffset,BOOL isFinished)
     {
         
       
     }];
    audioPlayer.url = url;
    [audioPlayer play];
}

-(void)stop
{
    if (audioPlayer && [audioPlayer isProcessing]) {
        [audioPlayer stop];
    }
}

-(void)play
{
    if (audioPlayer && ![audioPlayer isProcessing]) {
        [audioPlayer play];
    }
    
}
@end
