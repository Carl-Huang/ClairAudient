//
//  ControlCenter.m
//  ClairAudient
//
//  Created by Carl on 13-12-31.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "ControlCenter.h"

@implementation ControlCenter

+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

+ (UIWindow *)keyWindow
{
    return [[UIApplication sharedApplication] keyWindow];
}

+ (UIWindow *)newWindow
{
    UIWindow * window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.backgroundColor = [UIColor whiteColor];
    return window;
}

+ (void)makeKeyAndVisible
{
    AppDelegate * appDelegate = [[self class] appDelegate];
    appDelegate.window = [[self class] newWindow];
    MainViewController * vc = [[self class] mainViewController];
    UINavigationController * nav = [[self class] navWithRootVC:vc];
    appDelegate.navigationController = nav;
    [nav setNavigationBarHidden:YES animated:NO];
    [appDelegate.window setRootViewController:nav];
    [appDelegate.window makeKeyAndVisible];
    vc = nil;
    nav = nil;

}

+ (void)showSettingVC
{
    [[self class] showVC:@"SettingViewController"];
}

+ (void)showMixingMusicListVC
{
    [[self class] showVC:@"MixingMusicListViewController"];
}


+ (void)showVC:(NSString *)vcName
{
    AppDelegate * appDelegate = [[self class] appDelegate];
    UIViewController * vc = [[self class] viewControllerWithName:vcName];
    [appDelegate.navigationController pushViewController:vc animated:YES];
    
}

+ (MainViewController *)mainViewController
{
    MainViewController * vc = [[MainViewController alloc] initWithNibName:NSStringFromClass([MainViewController class]) bundle:[NSBundle mainBundle]];
    return vc;
}

+ (UIViewController *)viewControllerWithName:(NSString *)vcName
{
    Class cls = NSClassFromString(vcName);
    UIViewController * vc = [[cls alloc] initWithNibName:vcName bundle:[NSBundle mainBundle]];
    return vc;
}

+ (UINavigationController *)navWithRootVC:(UIViewController *)vc
{
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    return nav;
}

@end
