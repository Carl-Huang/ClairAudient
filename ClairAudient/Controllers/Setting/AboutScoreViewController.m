//
//  AboutScoreViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-6.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "AboutScoreViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
@interface AboutScoreViewController ()

@end

@implementation AboutScoreViewController
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
    self.view = nil;
}

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"关于积分";
    [self setLeftAndRightBarItem];
}

@end
