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
//#import <ShareSDK/ShareSDK.h>
//#import "WXApi.h"
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
    
    //分享配置
//    [self setupShareStuff];
    
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
//
//-(void)setupShareStuff
//{
//    [ShareSDK registerApp:@"iosv1103"];
//    //新浪微博
//    [ShareSDK connectSinaWeiboWithAppKey:@"568898243"
//                               appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
//                             redirectUri:@"http://www.sharesdk.cn"];
//    //微信
//    [ShareSDK connectWeChatWithAppId:@"wx4868b35061f87885" wechatCls:[WXApi class]];
//    [ShareSDK importWeChatClass:[WXApi class]];
//    
//    //添加QQ空间应用
//    [ShareSDK connectQZoneWithAppKey:@"100371282"
//                           appSecret:@"aed9b0303e3ed1e27bae87c33761161d"];
//    
//}
//
////微信分享配置
//- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
//{
//    
//    
//    return [ShareSDK handleOpenURL:url
//                        wxDelegate:self];
//}
//
//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation
//{
//    //    NSLog(@"%@",url.absoluteString);
//    
//    
//    //判断是否是微信的回调
//    NSString * weiXinAppID = @"wx4868b35061f87885";
//    if ([url.absoluteString rangeOfString:weiXinAppID].location != NSNotFound) {
//        return [ShareSDK handleOpenURL:url
//                     sourceApplication:sourceApplication
//                            annotation:annotation
//                            wxDelegate:self];
//    }
//    
//    return YES;
//}
@end
