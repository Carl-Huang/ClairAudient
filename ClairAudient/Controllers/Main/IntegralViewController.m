//
//  IntegralViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-13.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "IntegralViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "ControlCenter.h"
#import "User.h"
@interface IntegralViewController ()

@end

@implementation IntegralViewController
#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self setView:nil];
}

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"积分";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setLeftAndRightBarItem];
    
    NSString * userName = nil;
    if (self.userInfo.userName) {
        userName = self.userInfo.userName;
    }
    _userNameLabel.text = userName;
    
    _integralLabel.text = self.userInfo.integral;
}

#pragma mark - Action Methods
- (IBAction)showAboutScoreVC:(id)sender
{
    [ControlCenter showAboutScoreVC];
}

- (IBAction)makeCallActoin:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://055188888888"]];
}
@end
