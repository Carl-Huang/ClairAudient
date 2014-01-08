//
//  ChampionHomePageViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-8.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "ChampionHomePageViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
@interface ChampionHomePageViewController ()

@end

@implementation ChampionHomePageViewController
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
    self.title = @"冠军主页";
    [self setLeftAndRightBarItem];
}

@end
