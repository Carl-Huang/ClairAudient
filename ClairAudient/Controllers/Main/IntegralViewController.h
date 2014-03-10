//
//  IntegralViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-13.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"
@class User;
@interface IntegralViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *integralLabel;
@property (strong ,nonatomic) User * userInfo;
- (IBAction)showAboutScoreVC:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@end
