//
//  ThemeViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-6.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "ThemeViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "UserDefaultMacro.h"
@interface ThemeViewController ()

@end

@implementation ThemeViewController
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

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"关于积分";
    [self setLeftAndRightBarItem];
}


- (IBAction)defaultTheme:(id)sender {
    [[NSUserDefaults standardUserDefaults]setObject:@"hunyin_6.png" forKey:ThemeImage];
    [[NSUserDefaults standardUserDefaults ]synchronize];
    [self.bgView setImage:[UIImage imageNamed:@"hunyin_6.png"]];
}

- (IBAction)simpleTheme:(id)sender {
    [[NSUserDefaults standardUserDefaults]setObject:@"hunyin_6.png" forKey:ThemeImage];
    [[NSUserDefaults standardUserDefaults ]synchronize];
    [self.bgView setImage:[UIImage imageNamed:@"hunyin_6.png"]];
}

- (IBAction)paowenTheme:(id)sender {
    [[NSUserDefaults standardUserDefaults]setObject:@"hunyin_6.png" forKey:ThemeImage];
    [[NSUserDefaults standardUserDefaults ]synchronize];
    [self.bgView setImage:[UIImage imageNamed:@"hunyin_6.png"]];
}

- (IBAction)froestTheme:(id)sender {
    [[NSUserDefaults standardUserDefaults]setObject:@"hunyin_6.png" forKey:ThemeImage];
    [[NSUserDefaults standardUserDefaults ]synchronize];
    [self.bgView setImage:[UIImage imageNamed:@"hunyin_6.png"]];
}

@end
