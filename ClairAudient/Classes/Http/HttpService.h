//
//  HttpService.h
//  HWSDK
//
//  Created by Carl on 13-11-28.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "AFHttp.h"
#import "ActionMacro.h"

#define URL_PREFIX @"http://app.hfapp.cn/soundValley/"

@interface HttpService : AFHttp

+ (HttpService *)sharedInstance;
/**
 @desc 用户登录
 */
- (void)userLogin:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
/**
 @desc 用户注册
 */

- (void)userRegister:(NSDictionary *)params completionBlock:(void (^)(BOOL isSuccess))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取声音分类
 */
- (void)findCatalog:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 根据分类获取声音
 */
- (void)findVoiceByCatalog:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 根据声音获取评论
 */
- (void)findCommentByVoice:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 根据用户获取我的上传
 */
- (void)findMyUploadByUser:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取积分排行TOP10用户
 */
- (void)findIntegralRankUserWithCompletionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 根据类别Id获取该类别下的推荐声音
 */
- (void)findRecommendByCatalog:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 根据类别Id获取改类别下的排行声音
 */
- (void)findCatalogRankVoice:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取下载排行声音
 */
- (void)findDownloadRankVoiceWithCompletionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 根据关键字搜索音频
 */
- (void)searchVocie:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 上传音频
 */
- (void)uploadVoice:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


/**
 @desc 获取功能首页最上面的广告图片
 */
- (void)getAdvertisementImageWithCompletedBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

-(void)getImageWithResourcePath:(NSString *)path completedBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error))failure;



/**
 @desc 自定义图片接口：包括启动界面图片，寻音和积分按钮图片
 */
-(void)getCustomiseImageWithCompletedBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

-(void)getCustiomiseImageWithResourcePath:(NSString *)path completedBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error))failure;


/**
 @desc
 */
-(void)getMusicImageWithParams:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

-(void)getMusicImageWithResoucePath:(NSString *)path CompletedBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

/**
 @desc 获取某歌曲的评论
 */
-(void)getCommentWithParams:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
/**
 @desc 反馈
 */
-(void)commentWithParams:(NSDictionary *)params completionBlock:(void (^)(BOOL isSucccess))success failureBlock:(void (^)(NSError *, NSString *))failure;

/**
 @desc 评论音乐
 */
-(void)commentOnMusicWithParams:(NSDictionary *)params completionBlock:(void (^)(BOOL isSuccess))success failureBlock:(void (^)(NSError *, NSString *))failure;
@end
