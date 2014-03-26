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
#import "User.h"
#import "UserInfo.h"
#import "PersistentStore.h"

@interface LoginViewController ()<UITextFieldDelegate>
{
    CGRect originalRect;
    BOOL isRememberUser;
}
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
    _passwordField.delegate = self;
    _mobileField.delegate = self;

    isRememberUser = [[NSUserDefaults standardUserDefaults]boolForKey:@"isRememberUser"];
    if (isRememberUser) {
        [_rememberBtn setSelected:YES];
        UserInfo * userInfo = [PersistentStore getLastObjectWithType:[UserInfo class]];
        if (userInfo) {
            _mobileField.text = userInfo.name;
            _passwordField.text = userInfo.pwd;
        }
        
        
    }
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    originalRect = _contentView.frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods
- (IBAction)rememberPWDAction:(id)sender {
    [_rememberBtn setSelected:!_rememberBtn.selected];
    if (_rememberBtn.selected) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isRememberUser"];
        isRememberUser = YES;
    }else
    {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isRememberUser"];
        isRememberUser =  NO;
    }
    
}

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
    [[HttpService sharedInstance] userLogin:@{@"userName":mobile,@"passWord":pwd} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if(object)
        {
            [User saveToLocal:object];
            if (isRememberUser) {
                NSArray * array = [PersistentStore getAllObjectWithType:[UserInfo class]];
                for (UserInfo * obj in array) {
                    [PersistentStore deleteObje:obj];
                }
                
                UserInfo * userInfo = [UserInfo MR_createEntity];
                userInfo.name = _mobileField.text;
                userInfo.pwd = _passwordField.text;
                [PersistentStore save];
            }
        
            [ControlCenter showLoginSuccessVC];
        }
        
        
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


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (CGRectEqualToRect(originalRect, _contentView.frame)) {
        [UIView animateWithDuration:0.3 animations:^{
            _contentView.frame = CGRectOffset(_contentView.frame, 0, -60);
        }];
    }
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            _contentView.frame = CGRectOffset(_contentView.frame, 0, 60);
        }];
        return NO;
    }
    return  YES;
}
@end
