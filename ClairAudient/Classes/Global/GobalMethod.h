//
//  GobalMethod.h
//  ClairAudient
//
//  Created by vedon on 16/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum _ANCHOR
{
    TOP_LEFT,
    TOP,
    TOP_RIGHT,
    LEFT,
    CENTER,
    RIGHT,
    BOTTOM_LEFT,
    BOTTOM,
    BOTTOM_RIGHT
} ANCHOR;

@interface GobalMethod : NSObject
+(void)getExportPath:(NSString *)fileName completedBlock:(void (^)(BOOL isDownloaded,NSString * exportFilePath))block;

+(NSURL *)getMusicUrl:(NSString *)path;

+(NSString *)getMakeTime;

+(NSString *)userCurrentTimeAsFileName;

+(NSString *)customiseTimeFormat:(NSString *)date;

+(NSString *)timeIntervalToDate:(long long)interval;

+(BOOL)removeItemAtPath:(NSString *)path;

+(NSString *)getExportPath:(NSString *)fileName;

+(NSString *)getDocumentPath:(NSString *)fileName;

/*                 Audio                  */
+(CGFloat)getMusicLength:(NSURL *)url;
+(CGFloat)getAudioFileLength:(NSURL *)fileURL;

/**
 @desc: 本地通知
 */
+(void)localNotificationBody:(NSString *)body;

+(void)anchor:(UIView*)obj to:(ANCHOR)anchor withOffset:(CGPoint)offset;


+(NSString *)convertSecondToMinute:(CGFloat)time;
+(NSString *)convertMinuteToSecond:(CGFloat)time;
@end
