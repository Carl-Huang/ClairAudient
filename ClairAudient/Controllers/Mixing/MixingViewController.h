//
//  MixingViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-18.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"
#import "EZAudioPlotGL.h"
@class TrachBtn;
@interface MixingViewController : CommonViewController

@property (strong ,nonatomic) NSDictionary * musicInfo;

#pragma mark - Outlet
@property (weak, nonatomic) IBOutlet UILabel *littleTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bigTitleLabel;

@property (weak, nonatomic) IBOutlet EZAudioPlotGL *audioPlot;

@property (weak, nonatomic) IBOutlet UISlider *framePositionSlider;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet TrachBtn *startBtn;
@property (weak, nonatomic) IBOutlet TrachBtn *endBtn;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UILabel *cutLength;



- (IBAction)backAction:(id)sender;
-(IBAction)seekToFrame:(id)sender;
- (IBAction)playMusic:(id)sender;
@end
