//
//  MainViewController.h
//  ClairAudient
//
//  Created by vedon on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MainViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UIView *adScrollView;

@property (weak, nonatomic) IBOutlet UIView *startPageContainer;
@property (weak, nonatomic) IBOutlet UIButton *xunyinBtn;
@property (weak, nonatomic) IBOutlet UIButton *jifenBtn;
@property (weak, nonatomic) IBOutlet UIImageView *startImage;



- (IBAction)showRecordVC:(id)sender;
- (IBAction)showFoundMusicVC:(id)sender;
- (IBAction)showMixingMusicVC:(id)sender;
- (IBAction)showMusicFansVC:(id)sender;
- (IBAction)showIntegralVC:(id)sender;
- (IBAction)showAccountVC:(id)sender;
- (IBAction)showSettingVC:(id)sender;

- (IBAction)hideStartPageAction:(id)sender;
@end
