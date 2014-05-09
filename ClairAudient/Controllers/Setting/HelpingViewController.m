//
//  HelpViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-6.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "HelpingViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "User.h"
#import "HttpService.h"
#import "MBProgressHUD.h"

@interface HelpingViewController ()<UIAlertViewDelegate,UITextViewDelegate>
{
    BOOL isEdit;
}
@end

@implementation HelpingViewController
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
    isEdit = NO;
    _contentView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"帮助";
    [self setLeftAndRightBarItem];
    if([OSHelper iPhone5])
    {
        CGRect rect = _contentView.frame;
        rect.size.height +=70;
        _contentView.frame = rect;
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self popVIewController];
            break;
            
        default:
            break;
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    isEdit = YES;
    textView.text = @"";
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
