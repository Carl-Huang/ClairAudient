//
//  MutiMixingViewController.h
//  ClairAudient
//
//  Created by vedon on 24/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MutiMixingViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *controlBtnView;

@property (strong ,nonatomic) NSDictionary * mutiMixingInfo;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicObject;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;



- (IBAction)backAction:(id)sender;
- (IBAction)playAction:(id)sender;
- (IBAction)startMixingAction:(id)sender;
@end
