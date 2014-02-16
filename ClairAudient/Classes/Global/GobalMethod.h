//
//  GobalMethod.h
//  ClairAudient
//
//  Created by vedon on 16/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GobalMethod : NSObject
+(void)getExportPath:(NSString *)fileName completedBlock:(void (^)(BOOL isDownloaded,NSString * exportFilePath))block;

+(NSURL *)getMusicUrl:(NSString *)path;

//获取音乐长度
+(CGFloat)getMusicLength:(NSURL *)url;
@end
