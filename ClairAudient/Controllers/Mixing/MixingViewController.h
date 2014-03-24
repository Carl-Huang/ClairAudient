//
//  MixingViewController.h
//  ClairAudient
//
//  Created by Vedon on 14-1-18.
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
@property (weak, nonatomic) IBOutlet UILabel *cutLength;
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;




#pragma  mark - Outlet Action
- (IBAction)backAction:(id)sender;
- (IBAction)playMusic:(id)sender;

- (IBAction)startCutting:(id)sender;
- (IBAction)fastForwardAction:(id)sender;
- (IBAction)backForwardAction:(id)sender;
- (IBAction)copyMusicAction:(id)sender;


- (IBAction)addMixingMusicAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@end
