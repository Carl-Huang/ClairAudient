//
//  HttpService.h
//  HWSDK
//
//  Created by Carl on 13-11-28.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "AFHttp.h"
#define URL_PREFIX @"http://app.hfapp.cn/soundValley/"
#define User_Login                                  @"login"
#define User_Register                               @"user_register"
#define Find_Catalog                                @"FindVltByParentId"
#define Find_Voice_By_Catalog                       @"FindVoiceLibraryAction"
#define Find_Comment_By_Voice                       @"GetCommentByVlId"
#define Find_MyUpload                               @"MyUploadAction"
#define Find_Integral_Rank_User                     @"FindTop10IntegralUserAction"
#define Find_Recommend_By_Catalog                   @"getVlTuiJianTop10Action"
#define Find_Download_Rank_Voice                    @"getVoiceLibraryTop10Action"
#define Find_Catalog_Rank_Voice                     @"getVoiceLibraryTop10Action"
#define Search_Voice                                @"SerachVlAction"
#define Upload_Voice                                @"UploadAction"
#define GetMainImagesAction                         @"GetMainImagesAction"
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
@end
