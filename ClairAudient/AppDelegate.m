//
//  AppDelegate.m
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "AppDelegate.h"
#import "ControlCenter.h"
#import "HWConnect.h"
#import "MutiMixingViewController.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ControlCenter makeKeyAndVisible];
    [ControlCenter setNavigationTitleWhiteColor];
    [self custonNavigationBar];
    
//    MutiMixingViewController * viewController = [[MutiMixingViewController alloc]initWithNibName:@"MutiMixingViewController" bundle:nil];
//    self.window.rootViewController = viewController;
//    [self.window makeKeyAndVisible];
//    viewController = nil;
    
     [MagicalRecord setupCoreDataStackWithStoreNamed:@"ClairDataSource.sqlite"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)custonNavigationBar
{
    if([OSHelper iOS7])
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"ios7_setting_bar"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"setting_bar"] forBarMetrics:UIBarMetricsDefault];
    }
}

@end
