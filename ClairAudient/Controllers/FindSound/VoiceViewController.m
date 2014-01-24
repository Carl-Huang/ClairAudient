//
//  VoiceViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-24.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "VoiceViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
@interface VoiceViewController ()

@end

@implementation VoiceViewController

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
    self.title = @"Voice";
    [self setLeftAndRightBarItem];
}

@end
