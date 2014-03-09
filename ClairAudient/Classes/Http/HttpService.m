//
//  HttpService.m
//  HWSDK
//
//  Created by Carl on 13-11-28.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "HttpService.h"
#import "AllModels.h"
#import <objc/runtime.h>
#define HW @"hw_"       //关键字属性前缀
@implementation HttpService

#pragma mark Life Cycle
- (id)init
{
    if ((self = [super init])) {
        
    }
    return  self;
}

#pragma mark Class Method
+ (HttpService *)sharedInstance
{
    static HttpService * this = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        this = [[self alloc] init];
    });
    return this;
}

#pragma mark Private Methods
- (NSString *)mergeURL:(NSString *)methodName
{
    NSString * str =[NSString stringWithFormat:@"%@%@",URL_PREFIX,methodName];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return str;
}

/**
 @desc 返回类的属性列表
 @param 类对应的class
 @return NSArray 属性列表
 */
+ (NSArray *)propertiesName:(Class)cls
{
    if(cls == nil) return nil;
    unsigned int outCount,i;
    objc_property_t * properties = class_copyPropertyList(cls, &outCount);
    NSMutableArray * list = [NSMutableArray arrayWithCapacity:outCount];
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString * propertyName = [NSString stringWithUTF8String:property_getName(property)];
        if(propertyName && [propertyName length] != 0)
        {
            [list addObject:propertyName];
        }
    }
    return list;
}



//将取得的内容转换为模型
- (NSArray *)mapModelsProcess:(id)responseObject withClass:(Class)class
{
    //判断返回值
    if(!responseObject)
    {
        return nil;
    }
    
//    NSArray * properties = [[self class] propertiesName:class];
    NSMutableArray * models = [NSMutableArray array];
    for (NSDictionary * info in responseObject) {
        id model = [self mapModel:info withClass:class];
        if(model)
        {
            [models addObject:model];
        }
    }
    
    return (NSArray *)models;
}

- (id)mapModel:(id)reponseObject withClass:(Class)cls
{
    if (!reponseObject) {
        return nil;
    }
    id model  = [[cls alloc] init];
    NSArray * properties = [[self class] propertiesName:cls];
    for(NSString * property in properties)
    {
        NSString * tmp = [property stringByReplacingOccurrencesOfString:HW withString:@""];
        id value = [reponseObject valueForKey:tmp];
        if(![value isKindOfClass:[NSNull class]])
        {
            if(![value isKindOfClass:[NSString class]])
            {
                [model setValue:[value stringValue] forKey:property];
            }
            else
            {
                [model setValue:value forKey:property];
            }
        }
    }
    return model;
}

#pragma mark Instance Method
/**
 @desc 用户登录
 */
- (void)userLogin:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{

    [self post:[self mergeURL:User_Login] withParams:params completionBlock:^(id obj) {
        NSString * result = [obj valueForKey:@"result"];
        if([result intValue] == 1)
        {
            User * user = [self mapModel:[obj valueForKey:@"user"] withClass:[User class]];
            if(success)
            {
                success(user);
            }
        }
        else if ([result intValue] == 4)
        {
            //用户名不存在
            if(failure)
            {
                failure(nil,result);
            }
        }
        else if ([
                  result intValue] == 5)
        {
            //密码错误
            //用户名不存在
            if(failure)
            {
                failure(nil,result);
            }
            
        }
    } failureBlock:failure];
}

/**
 @desc 用户注册
 */
- (void)userRegister:(NSDictionary *)params completionBlock:(void (^)(BOOL isSuccess))success failureBlock:(void (^)(NSError * error,NSString * reponseString))failure
{
    
}

/**
 @desc 获取声音分类
 */
- (void)findCatalog:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:Find_Catalog] withParams:params completionBlock:^(id obj) {
        NSArray * items = [obj valueForKey:@"items"];
        NSArray * catalogs = [self mapModelsProcess:items withClass:[Catalog class]];
        if(success)
        {
            success(catalogs);
        }
    } failureBlock:failure];
}

/**
 @desc 根据分类获取声音
 */
- (void)findVoiceByCatalog:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Find_Voice_By_Catalog] withParams:params completionBlock:^(id obj) {
        NSArray * items = [obj valueForKey:@"items"];
        NSArray * voices = [self mapModelsProcess:items withClass:[Voice class]];
        if(success)
        {
            success(voices);
        }

    } failureBlock:failure];
}

/**
 @desc 根据声音获取评论
 */
- (void)findCommentByVoice:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Find_Comment_By_Voice] withParams:params completionBlock:^(id obj) {
        NSArray * items = [obj valueForKey:@"items"];
        NSArray * voiceComments = [self mapModelsProcess:items withClass:[VoiceComment class]];
        if(success)
        {
            success(voiceComments);
        }
    } failureBlock:failure];
}

/**
 @desc 根据用户获取我的上传
 */
- (void)findMyUploadByUser:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Find_MyUpload] withParams:params completionBlock:^(id obj) {
        NSArray * items = [obj valueForKey:@"items"];
        NSArray * voices = [self mapModelsProcess:items withClass:[Voice class]];
        if(success)
        {
            success(voices);
        }
        
    } failureBlock:failure];
}

/**
 @desc 获取积分排行TOP10用户
 */
- (void)findIntegralRankUserWithCompletionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Find_Integral_Rank_User] withParams:nil completionBlock:^(id obj) {
        NSArray * items = [obj valueForKey:@"items"];
        NSArray * users = [self mapModelsProcess:items withClass:[IntegralRankUser class]];
        if(success)
        {
            success(users);
        }
    } failureBlock:failure];
}

/**
 @desc 根据类别Id获取该类别下的推荐声音
 */
- (void)findRecommendByCatalog:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Find_Recommend_By_Catalog] withParams:params completionBlock:^(id obj) {
        NSArray * items = [obj valueForKey:@"items"];
        NSArray * voices = [self mapModelsProcess:items withClass:[Voice class]];
        if(success)
        {
            success(voices);
        }
    } failureBlock:failure];
}

/**
 @desc 根据类别Id获取改类别下的排行声音
 */
- (void)findCatalogRankVoice:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Find_Catalog_Rank_Voice] withParams:params completionBlock:^(id obj) {
        NSArray * items = [obj valueForKey:@"items"];
        NSArray * voices = [self mapModelsProcess:items withClass:[Voice class]];
        if(success)
        {
            success(voices);
        }
    } failureBlock:failure];
}

/**
 @desc 获取下载排行声音
 */
- (void)findDownloadRankVoiceWithCompletionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Find_Download_Rank_Voice] withParams:nil completionBlock:^(id obj) {
        NSArray * items = [obj valueForKey:@"items"];
        NSArray * voices = [self mapModelsProcess:items withClass:[Voice class]];
        if(success)
        {
            success(voices);
        }
    } failureBlock:failure];
}

/**
 @desc 根据关键字搜索音频
 */
- (void)searchVocie:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Search_Voice] withParams:params completionBlock:^(id obj) {
        NSArray * items = [obj valueForKey:@"items"];
        NSArray * voices = [self mapModelsProcess:items withClass:[Voice class]];
        if(success)
        {
            success(voices);

        }
    }failureBlock:failure];
}

/**
 @desc 上传音频
 */
- (void)uploadVoice:(NSDictionary *)params completionBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure
{
    [self post:[self mergeURL:Upload_Voice] withParams:params completionBlock:^(id obj) {
        
    } failureBlock:failure];
}

-(void)getAdvertisementImageWithCompletedBlock:(void (^)(id object))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:GetMainImagesAction] withParams:nil completionBlock:^(id obj) {
        if ([obj count]) {
            NSArray * items = [obj valueForKey:@"ad_image"];
            success(items);
        }
    } failureBlock:failure];
}



-(void)getImageWithResourcePath:(NSString *)path completedBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error))failure
{
    
    NSURL * imageUrl = [NSURL URLWithString:[self mergeURL:path]];
    NSURLRequest * request = [NSURLRequest requestWithURL:imageUrl];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        UIImage * image = [UIImage imageWithData:data];
        success (image);
    }];
    
}

-(void)getCustomiseImageWithCompletedBlock:(void (^)(id))success failureBlock:(void (^)(NSError *, NSString *))failure
{
    [self post:[self mergeURL:WelcomeImageAction] withParams:nil completionBlock:^(id obj) {
        if ([obj count]) {
            NSArray * object = [self mapModelsProcess:obj withClass:[CustomiseImageObj class]];
            success(object);
        }
    } failureBlock:failure];
}

-(void)getCustiomiseImageWithResourcePath:(NSString *)path completedBlock:(void (^)(id object))success failureBlock:(void (^)(NSError * error))failure
{
    
    NSURL * imageUrl = [NSURL URLWithString:[self mergeURL:path]];
    NSURLRequest * request = [NSURLRequest requestWithURL:imageUrl];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        UIImage * image = [UIImage imageWithData:data];
        success (image);
    }];
    
}
@end
