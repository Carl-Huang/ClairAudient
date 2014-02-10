//
//  MainViewController.h
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MainViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UIView *adScrollView;




- (IBAction)showRecordVC:(id)sender;
- (IBAction)showFoundMusicVC:(id)sender;
- (IBAction)showMixingMusicVC:(id)sender;
- (IBAction)showMusicFansVC:(id)sender;
- (IBAction)showIntegralVC:(id)sender;
- (IBAction)showAccountVC:(id)sender;
- (IBAction)showSettingVC:(id)sender;

@end
