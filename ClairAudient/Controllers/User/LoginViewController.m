//
//  LoginViewController.m
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "LoginViewController.h"
#import "ControlCenter.h"
#import "HttpService.h"
#import "MBProgressHUD.h"
@interface LoginViewController ()

@end

@implementation LoginViewController
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

- (IBAction)loginAction:(id)sender
{
    NSString * mobile = [_mobileField text];
    NSString * pwd = [_passwordField text];
    if([mobile length] == 0)
    {
        [self showAlertViewWithMessage:@"请填写您的手机号码!"];
        return ;
    }
    
    if([pwd length] == 0)
    {
        [self showAlertViewWithMessage:@"请输入您的密码!"];
        return ;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance] userLogin:@{@"userName":mobile,@"passWord":pwd} completionBlock:^(NSString *responStr) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [ControlCenter showLoginSuccessVC];
        
    } failureBlock:^(NSError *error,NSString * responseString) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if([responseString isEqualToString:@"4"])
        {
            [self showAlertViewWithMessage:@"用户名不存在！"];
        }
        else if([responseString isEqualToString:@"5"])
        {
            [self showAlertViewWithMessage:@"密码不争取！"];
        }
        else
        {
            [self showAlertViewWithMessage:@"登陆失败，请重试！"];
        }
    }];
    
}

- (IBAction)registerAction:(id)sender
{
    [ControlCenter showRegisterVC];
}
@end
