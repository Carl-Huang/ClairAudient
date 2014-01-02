//
//  ControlCenter.h
//  ClairAudient
//
//  Created by Carl on 13-12-31.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "MainViewController.h"
#import "SettingViewController.h"
#import "MixingMusicListViewController.h"
@interface ControlCenter : NSObject

+ (AppDelegate *)appDelegate;
+ (UIWindow *)keyWindow;
+ (UIWindow *)newWindow;
+ (void)makeKeyAndVisible;
+ (void)showSettingVC;
+ (void)showMixingMusicListVC;
+ (void)showVC:(NSString *)vcName;
+ (MainViewController *)mainViewController;
+ (UIViewController *)viewControllerWithName:(NSString *)vcName;
+ (UINavigationController *)navWithRootVC:(UIViewController *)vc;
@end
