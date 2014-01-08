//
//  RecommendSoundViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-8.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "RecommendSoundViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
@interface RecommendSoundViewController ()

@end

@implementation RecommendSoundViewController
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
    self.title = @"推荐声音";
    [self setLeftAndRightBarItem];
}


@end
