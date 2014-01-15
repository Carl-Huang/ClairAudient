//
//  LoginSuccessViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "LoginSuccessViewController.h"
#import "ControlCenter.h"
@interface LoginSuccessViewController ()

@end

@implementation LoginSuccessViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Action Methods
- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}

- (IBAction)messageInviteAction:(id)sender
{
    [ControlCenter showMessageInviteVC];
}

- (IBAction)enterUserCenterAction:(id)sender
{
    [ControlCenter showUserCenterVC];
}
@end
