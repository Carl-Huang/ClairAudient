//
//  ShareManager.h
//  YouLa
//
//  Created by vedon on 8/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareManager : NSObject
+(ShareManager *)shareManager;


/**
 @desc 分享到新浪微博
 */
- (void)shareToSinaWeiboWithTitle:(NSString *)title content:(NSString *)shareContent image:(UIImage *)shareImage;
/**
 @desc 分享到人人
 */
- (void)shareToRenRenWithTitle:(NSString *)title content:(NSString *)shareContent image:(UIImage *)shareImage;

/**
 @desc 分享到腾讯微博
 */
- (void)shareToTencentWeiboWithTitle:(NSString *)title content:(NSString *)shareContent image:(UIImage *)shareImage;

/**
 @desc 分享到微信
 */
- (void)shareToWeiXinContentWithTitle:(NSString *)title content:(NSString *)shareContent image:(UIImage *)shareImage;


/**
 @desc 分享到QQ空间
 */
- (void)shareToQQSpaceWithTitle:(NSString *)title content:(NSString *)shareContent image:(UIImage *)shareImage;
@end
