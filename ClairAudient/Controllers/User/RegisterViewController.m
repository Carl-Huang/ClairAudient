//
//  RegisterViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "RegisterViewController.h"
#import "ControlCenter.h"
@interface RegisterViewController ()

@end

@implementation RegisterViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Action Methods
- (IBAction)registerAction:(id)sender
{
    if(_vipBtn.selected)
    {
        [ControlCenter showVipRegisterVC];
    }
}

- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}

- (IBAction)selectNormalAction:(id)sender
{
    [_normalBtn setSelected:YES];
    [_vipBtn setSelected:NO];
}

- (IBAction)selectionVipAction:(id)sender
{
    [_normalBtn setSelected:NO];
    [_vipBtn setSelected:YES];
}
@end
