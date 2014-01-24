//
//  AudioPlotViewController.h
//  ClairAudient
//
//  Created by vedon on 24/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"
@class EZAudioPlotGL;
@class TrachBtn;
@interface AudioPlotViewController : CommonViewController
#pragma mark - Outlet
@property (weak, nonatomic) IBOutlet EZAudioPlotGL *audioPlot;
@property (weak, nonatomic) IBOutlet UIView *timeLabelView;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIView *timeLineView;
@property (weak, nonatomic) IBOutlet TrachBtn *startBtn;
@property (weak, nonatomic) IBOutlet TrachBtn *endBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong ,nonatomic) NSDictionary * musicInfo;
-(void)setupAudioPlotView;
-(void)play;
-(void)pause;
-(void)stop;

-(void)setupAudioPlotViewWithRect:(CGRect)rect;
@end
