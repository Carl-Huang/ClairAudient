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
#import "AboutScoreViewController.h"
#import "ThemeViewController.h"
#import "HelpViewController.h"
#import "MusicFansViewController.h"
#import "IntegralChampionViewController.h"
#import "CatalogRankViewController.h"
#import "ChampionHomePageViewController.h"
#import "RecommendSoundViewController.h"
#import "DownloadRankViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "VipRegisterViewController.h"
#import "LoginSuccessViewController.h"
#import "MessageInviteViewController.h"
#import "UserCenterViewController.h"
#import "MyDownloadViewController.h"
#import "PersonalHomePageViewController.h"
#import "MyProductionViewController.h"
#import "MyUploadViewController.h"
#import "ReviewViewController.h"
#import "UserCenterViewController.h"
#import "IntegralViewController.h"
#import "SoundEffectViewController.h"
#import "MixingViewController.h"
#import "RecordViewController.h"
#import "RecordListViewController.h"
@interface ControlCenter : NSObject

+ (AppDelegate *)appDelegate;
+ (UIWindow *)keyWindow;
+ (UIWindow *)newWindow;
+ (void)setNavigationTitleWhiteColor;
+ (void)makeKeyAndVisible;
+ (void)showSettingVC;
+ (void)showThemeVC;
+ (void)showHelpVC;
+ (void)showAboutScoreVC;
+ (void)showMixingMusicListVC;
+ (void)showMusicFansVC;
+ (void)showIntegralChampionVC;
+ (void)showCatalogRankVC;
+ (void)showRecommendSoundVC;
+ (void)showChampionHomePageVC;
+ (void)showDownloadRankVC;
+ (void)showFIndSoundVC;
+ (void)showSoundCatalogVC;
+ (void)showRegisterVC;
+ (void)showVipRegisterVC;
+ (void)showUserCenterVC;
+ (void)showMyUploadVC;
+ (void)showMyDownloadVC;
+ (void)showLoginSuccessVC;
+ (void)showMyProductionVC;
+ (void)showPersonalHomePageVC;
+ (void)showMessageInviteVC;
+ (void)showReviewVC;
+ (void)showLoginVC;
+ (void)showIntegralVC;
+ (void)showSoundEffectVC;
+ (void)showMixingVC;
+ (void)showRecordVC;
+ (void)showRecordListVC;
+ (void)showVC:(NSString *)vcName;
+ (MainViewController *)mainViewController;
+ (UIViewController *)viewControllerWithName:(NSString *)vcName;
+ (UINavigationController *)navWithRootVC:(UIViewController *)vc;
@end
