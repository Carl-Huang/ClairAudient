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

+ (void)setNavigationTitleWhiteColor
{
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor]}];
}

+ (void)showSettingVC
{
    [[self class] showVC:@"SettingViewController"];
}

+ (void)showMixingMusicListVC
{
    [[self class] showVC:@"MixingMusicListViewController"];
}

+ (void)showThemeVC
{
    [[self class] showVC:@"ThemeViewController"];
}

+ (void)showHelpVC
{
    [[self class] showVC:@"HelpViewController"];
}

+ (void)showAboutScoreVC
{
    [[self class] showVC:@"AboutScoreViewController"];
}

+ (void)showMusicFansVC
{
    [[self class] showVC:@"MusicFansViewController"];
}

+ (void)showIntegralChampionVC
{
    [[self class] showVC:@"IntegralChampionViewController"];
}

+ (void)showCatalogRankVC
{
    [[self class] showVC:@"CatalogRankViewController"];
}

+ (void)showChampionHomePageVC
{
    [[self class] showVC:@"ChampionHomePageViewController"];
}

+ (void)showRecommendSoundVC
{
    [[self class] showVC:@"RecommendSoundViewController"];
}

+ (void)showDownloadRankVC
{
    [[self class] showVC:@"DownloadRankViewController"];
}

+ (void)showFIndSoundVC
{
    [[self class] showVC:@"FIndSoundViewController"];
}

+ (void)showSoundCatalogVC
{
    [[self class] showVC:@"SoundCatalogViewController"];
}

+ (void)showLoginVC
{
    [[self class] showVC:@"LoginViewController"];
}

+ (void)showRegisterVC
{
    [[self class] showVC:@"RegisterViewController"];
}

+ (void)showVipRegisterVC
{
    [[self class] showVC:@"VipRegisterViewController"];
}

+ (void)showLoginSuccessVC
{
    [[self class] showVC:@"LoginSuccessViewController"];
}

+ (void)showPersonalHomePageVC
{
    [[self class] showVC:@"PersonalHomePageViewController"];
}

+ (void)showUserCenterVC
{
    [[self class] showVC:@"UserCenterViewController"];
}

+ (void)showMyUploadVC
{
    [[self class] showVC:@"MyUploadViewController"];
}

+ (void)showMyDownloadVC
{
    [[self class] showVC:@"MyDownloadViewController"];
}

+ (void)showMyProductionVC
{
    [[self class] showVC:@"MyProductionViewController"];
}

+ (void)showMessageInviteVC
{
    [[self class] showVC:@"MessageInviteViewController"];
}

+ (void)showReviewVC
{
    [[self class] showVC:@"ReviewViewController"];
}

+ (void)showIntegralVC
{
    [[self class] showVC:@"IntegralViewController"];
}

+ (void)showSoundEffectVC
{
    [[self class] showVC:@"SoundEffectViewController"];
}

+ (void)showMixingVC
{
    [[self class] showVC:@"MixingViewController"];
}

+ (void)showRecordVC
{
    [[self class] showVC:@"RecordViewController"];
}

+ (void)showRecordListVC
{
    [[self class] showVC:@"RecordListViewController"];
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
