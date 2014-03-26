//
//  HelpViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-6.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "HelpViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "User.h"
#import "HttpService.h"
#import "MBProgressHUD.h"

@interface HelpViewController ()<UIAlertViewDelegate,UITextViewDelegate>
{
    BOOL isEdit;
}
@end

@implementation HelpViewController
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
    self.title = @"用户反馈";
    [self setLeftAndRightBarItem];
}

- (IBAction)submitCommentAction:(id)sender {
    User * user = [User userFromLocal];
    if ([_contentView.text length ] == 0 || !isEdit) {
        [self showAlertViewWithMessage:@"反馈内容不能为空"];
    }else
    {
        if (user) {
            __weak HelpViewController * weakSelf = self;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[HttpService sharedInstance]commentWithParams:@{@"content": _contentView.text,@"userID":user.hw_id} completionBlock:^(BOOL isSuccess) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                if (isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"反馈成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                        alertView = nil;
                        
                    });
                }else
                {
                    [self showAlertViewWithMessage:@"反馈失败"];
                }
                
            } failureBlock:^(NSError *error, NSString *responseString) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }];
        }
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
@end
