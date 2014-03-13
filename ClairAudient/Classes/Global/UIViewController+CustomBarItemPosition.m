//
//  UIViewController+CustomBarItemPosition.m
//  ClairAudient
//
//  Created by Carl on 14-1-8.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "UIViewController+CustomBarItemPosition.h"
#import "MainViewController.h"
@implementation UIViewController (CustomBarItemPosition)
- (void)setLeftAndRightBarItem
{
    if([OSHelper iOS7])
    {
        [self setLeftCustomBarItem:@"setting_" action:nil imageEdgeInsets:UIEdgeInsetsMake(0, -28, 0, 0)];
        
        
        
        [self setRightCustomBarItem:@"setting_4" action:@selector(gotoRootViewController) imageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -28)];
    }
    else
    {
        [self setLeftCustomBarItem:@"setting_" action:nil imageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        [self setRightCustomBarItem:@"setting_4" action:@selector(gotoRootViewController) imageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -10)];
    }
}

-(void)gotoRootViewController
{
    NSArray * viewControllers = self.navigationController.viewControllers;
    for (UIViewController * vc in viewControllers) {
        if ([vc isKindOfClass:[MainViewController class]]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}
@end
