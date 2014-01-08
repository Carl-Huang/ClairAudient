//
//  MusicFansViewController.m
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "MusicFansViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "ControlCenter.h"
@interface MusicFansViewController ()

@end

@implementation MusicFansViewController
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.title = @"音迷";
    [self setLeftAndRightBarItem];

}


#pragma mark - UIButton Actions
- (IBAction)showIntegralChampionVC:(id)sender
{
    [ControlCenter showIntegralChampionVC];
}

- (IBAction)showCatalogRankVC:(id)sender
{
    [ControlCenter showCatalogRankVC];
}

- (IBAction)showDownloadRankVC:(id)sender
{
    [ControlCenter showDownloadRankVC];
}

- (IBAction)showRecommendSoundVC:(id)sender
{
    [ControlCenter showRecommendSoundVC];
}
@end
