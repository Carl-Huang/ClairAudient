//
//  StreamPlayer.h
//  ClairAudient
//
//  Created by vedon on 11/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioPlayer.h"

@interface StreamPlayer : NSObject

+(id)shareStreamPlayer;
-(void)playFile:(NSURL *)url;
-(void)stop;
-(void)play;
@end
