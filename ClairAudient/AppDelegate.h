//
//  AppDelegate.h
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AFURLConnectionOperation;
@class AudioFloatPointReader;
@class AudioManager;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController * navigationController;

@property (strong, nonatomic) NSOperationQueue * downloadOperateQueue;
@property (strong, nonatomic) AudioFloatPointReader * floatReader;
@property (strong, nonatomic) AudioManager * audioMng;
@property (strong, nonatomic) NSDictionary * currentPlayMusicInfo;
@property (assign, nonatomic) CGFloat        currentPlayMusicLength;
@property (assign, nonatomic) CGFloat        audioTotalFrame;

#pragma mark - Operation
-(void)addnewOperation:(NSOperation *)operation;

#pragma mark - Audio
-(void)playItemWithURL:(NSURL *)inputFileURL withMusicInfo:(NSDictionary *)info withPlaylist:(NSArray *)list;
-(void)seekToPostion:(CGFloat)postion;
-(void)playCurrentSongWithInfo:(NSDictionary *)info;
-(BOOL)isPlaying;
-(void)pause;
-(void)play;
@end
