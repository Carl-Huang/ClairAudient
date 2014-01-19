//
//  MainViewController.m
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "MainViewController.h"
#import "ControlCenter.h"
@interface MainViewController ()

@end

@implementation MainViewController
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
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIButton Actions
- (IBAction)showRecordVC:(id)sender
{
    [ControlCenter showRecordListVC];
}

- (IBAction)showFoundMusicVC:(id)sender
{
    [ControlCenter showFIndSoundVC];
}

- (IBAction)showMixingMusicVC:(id)sender
{
    [ControlCenter showMixingMusicListVC];
}

- (IBAction)showMusicFansVC:(id)sender
{
    [ControlCenter showMusicFansVC];
}

- (IBAction)showIntegralVC:(id)sender
{
    [ControlCenter showIntegralVC];
}

- (IBAction)showAccountVC:(id)sender
{
    [ControlCenter showLoginVC];
}

- (IBAction)showSettingVC:(id)sender
{
    [ControlCenter showSettingVC];
}
@end
