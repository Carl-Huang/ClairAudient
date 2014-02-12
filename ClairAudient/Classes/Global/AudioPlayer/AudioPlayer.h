//
//  AudioPlayer.h
//  Share
//
//  Created by Lin Zhang on 11-4-26.
//  Copyright 2011年 www.eoemobile.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GetProcessingLocationBlock) (double processOffset);

@class AudioStreamer;
@interface AudioPlayer : NSObject {
    AudioStreamer *streamer;
    NSURL *url;
    NSTimer *timer;
}

@property (nonatomic, retain) AudioStreamer *streamer;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) GetProcessingLocationBlock  block;
- (void)play;
- (void)stop;
- (BOOL)isProcessing;

@end
