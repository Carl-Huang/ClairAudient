//
//  PersonalHomePageViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "PersonalHomePageViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "User.h"
@interface PersonalHomePageViewController ()
@property (nonatomic,strong) User * user;
@end

@implementation PersonalHomePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _user = [User userFromLocal];
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

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"她的主页";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setLeftAndRightBarItem];
    if(self.user)
    {
        _nameField.text = _user.userName;
        _passwordField.text = _user.passWord;
        _birthdayField.text = _user.birthday;
        _jobField.text = _user.workUnit;
        _emailField.text = _user.email;
        
    }
}

@end
