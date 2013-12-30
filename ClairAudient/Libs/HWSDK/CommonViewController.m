//
//  CommonViewController.m
//  YueXing100
//
//  Created by Carl on 13-12-11.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "CommonViewController.h"
#import "HWSDK_Constants.h"
@interface CommonViewController ()

@end

@implementation CommonViewController
#pragma mark - Lify Cycle
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
#ifdef iOS7_SDK
    if([OSHelper iOS7])
    {
        if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        {
            [self setEdgesForExtendedLayout:UIRectEdgeNone];
            [self setExtendedLayoutIncludesOpaqueBars:NO];
//            [self prefersStatusBarHidden];
//            [self preferredStatusBarStyle];
//            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
#endif
    self.wantsFullScreenLayout = NO;

    
}

//- (BOOL)prefersStatusBarHidden
//{
//    return NO;
//}
//
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleBlackOpaque;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance Methods
- (void)showAlertViewWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
    });
}

@end
