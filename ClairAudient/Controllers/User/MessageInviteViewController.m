//
//  MessageInviteViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "MessageInviteViewController.h"

@interface MessageInviteViewController ()

@end

@implementation MessageInviteViewController

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
- (IBAction)selectFriendAction:(id)sender
{
    
}

- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}
- (IBAction)selectFirstMsgAction:(id)sender
{
    [_msgBtn_1 setSelected:YES];
    [_msgBtn_2 setSelected:NO];
}

- (IBAction)selectSectionSectionMsgAction:(id)sender
{
    [_msgBtn_1 setSelected:NO];
    [_msgBtn_2 setSelected:YES];
}
@end
