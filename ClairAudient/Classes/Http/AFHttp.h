//
//  AFHttp.h
//  HWSDK
//
//  Created by Carl on 13-11-28.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
typedef void (^CompletionHandler)(id obj,NSString * tag);
typedef void (^FailureHandler) (NSError * error,NSString * tag);

@interface AFHttp : NSObject
@property (nonatomic,readonly) AFHTTPRequestOperationManager * manager;
+ (AFHttp *)shareInstanced;
+ (NSString *)urlEncode:(NSString *)url;
+ (void)get:(NSString *)url parameters:(NSDictionary *)parameters completionBlock:(void (^)(id obj))success failureBlock:(void (^)(NSError * errorerror,NSString * responseString))failure;
+ (void)post:(NSString *)url withParam:(NSDictionary *)params completionBlock:(void (^)(id obj))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;

- (void)get:(NSString *)url parameters:(NSDictionary *)parameters  completionBlock:(void (^)(id obj))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;
- (void)post:(NSString *)url withParams:(NSDictionary *)params completionBlock:(void (^)(id obj))success failureBlock:(void (^)(NSError * error,NSString * responseString))failure;


@end
