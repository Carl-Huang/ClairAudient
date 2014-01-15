//
//  UserCenterViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "UserCenterViewController.h"
#import "ControlCenter.h"
@interface UserCenterViewController ()

@end

@implementation UserCenterViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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

- (IBAction)myUploadAction:(id)sender
{
    [ControlCenter showMyUploadVC];
}

- (IBAction)myDownloadAction:(id)sender
{
    [ControlCenter showMyDownloadVC];
}

- (IBAction)myProductionAction:(id)sender
{
    [ControlCenter showMyProductionVC];
}

- (IBAction)homePageAction:(id)sender
{
    [ControlCenter showPersonalHomePageVC];
}
@end
