//
//  VersionManager.h
//  YueXing100
//
//  Created by Carl on 13-12-15.
//  Copyright (c) 2013年 Yoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VersionManager : NSObject
/**
 @desc 检测版本更新
 */
+ (void)checkUpdate:(NSString *)appID compleitionBlock:(void (^)(BOOL hasNew,NSError * error))completionHandle;
@end
