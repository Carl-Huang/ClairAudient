//
//  GobalMethod.m
//  ClairAudient
//
//  Created by vedon on 16/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "GobalMethod.h"
#import <AVFoundation/AVFoundation.h>
@implementation GobalMethod

//我的下载
+(void)getExportPath:(NSString *)fileName completedBlock:(void (^)(BOOL isDownloaded,NSString * exportFilePath))block
{
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    
    NSString * fileFloder = [documentsDirectoryPath stringByAppendingPathComponent:@"我的下载"];
    NSString *exportPath = [fileFloder stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileFloder]) {
        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:fileFloder withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        block(YES,exportPath);
        return;
    }
    block(NO,exportPath);
}

+(NSURL *)getMusicUrl:(NSString *)path
{
    NSString * prefixStr = nil;
    if ([path rangeOfString:@"voice_data"].location!= NSNotFound) {
        prefixStr = SoundValleyPrefix;
    }else
    {
        prefixStr = VoccPrefix;
    }
    NSURL * url = [NSURL URLWithString:[prefixStr stringByAppendingString:path]];
    return url;
}

//获取音乐长度
+(CGFloat)getMusicLength:(NSURL *)url
{
    AVURLAsset* audioAsset =[AVURLAsset assetWithURL:url];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration)/60.0f;
    return audioDurationSeconds;
}

+(NSString *)getMakeTime;
{
    NSDate * currentDate = [NSDate date];
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMddhhmmss"];
    NSString * dateStr = [format stringFromDate:currentDate];
    return dateStr;
}

+(NSString *)userCurrentTimeAsFileName
{
    NSDate * date = [NSDate date];
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMddhhmmss"];
    NSString * tempFileName = [format stringFromDate:date];
    return tempFileName;
}

+(NSString *)customiseTimeFormat:(NSString *)date
{
    NSDateFormatter * format  = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMddhhmmss"];
    NSDate * tempDate = [format dateFromString:date];
    
    NSDateFormatter * customiseFormat  = [[NSDateFormatter alloc]init];
    [customiseFormat setDateFormat:@"yyyy-MM-dd"];
    NSString * dateStr = [customiseFormat stringFromDate:tempDate];
    return dateStr;
}

+(BOOL)removeItemAtPath:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        NSError * error;
        [[NSFileManager defaultManager] removeItemAtPath:path error: &error];
        if (error) {
            NSLog(@"RemoveItem Error: %@",[error description]);
            return NO;
        }
        return YES;
    }
    return NO;
}
@end
