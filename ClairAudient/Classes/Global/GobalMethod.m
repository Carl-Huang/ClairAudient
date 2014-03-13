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
+(NSString *)getMusicLength:(NSURL *)url
{
    AVURLAsset* audioAsset =[AVURLAsset assetWithURL:url];
    CMTime audioDuration = audioAsset.duration;
     NSString * sec = [GobalMethod convertSecondToMinute:CMTimeGetSeconds(audioDuration)];
    return sec;
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

+(NSString *)timeIntervalToDate:(long long)interval
{
    NSDate * date = [[NSDate alloc]initWithTimeIntervalSince1970:interval];
    NSDateFormatter * customiseFormat  = [[NSDateFormatter alloc]init];
    [customiseFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString * dateStr = [customiseFormat stringFromDate:date];
    return dateStr;
}

+(NSString *)getCurrentDateString
{
    NSDate * date = [NSDate date];
    NSDateFormatter * customiseFormat  = [[NSDateFormatter alloc]init];
    [customiseFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString * dateStr = [customiseFormat stringFromDate:date];
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

+(CGFloat)getAudioFileLength:(NSURL *)fileURL
{
    ExtAudioFileRef audioFile;
    AudioStreamBasicDescription fileFormat;
    Float32 totalDuration = 0.0;
    
    [GobalMethod checkResult:ExtAudioFileOpenURL((__bridge CFURLRef)(fileURL),&audioFile)
               operation:"Failed to open audio file for reading"];
    UInt32 size = sizeof(fileFormat);
    [GobalMethod checkResult:ExtAudioFileGetProperty(audioFile,kExtAudioFileProperty_FileDataFormat, &size, &fileFormat)
               operation:"Failed to get audio stream basic description of input file"];
    [GobalMethod printASBD:fileFormat];
    SInt64  totalFrames;
    size = sizeof(totalFrames);
    [GobalMethod checkResult:ExtAudioFileGetProperty(audioFile,kExtAudioFileProperty_FileLengthFrames, &size, &totalFrames)
               operation:"Failed to get total frames of input file"];
    
    // Total duration
    totalDuration = totalFrames / fileFormat.mSampleRate;
    return totalDuration;
}

+(NSString *)getExportPath:(NSString *)fileName
{
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    
    NSString * fileFloder = [documentsDirectoryPath stringByAppendingPathComponent:@"我的制作"];
    NSString *exportPath = [fileFloder stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileFloder]) {
        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:fileFloder withIntermediateDirectories:NO attributes:nil error:&error];
        
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    return exportPath;
}

+(NSString *)getDocumentPath:(NSString *)fileName
{
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    
    NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    return exportPath;
}
#pragma mark - OSStatus Utility
+(void)checkResult:(OSStatus)result
         operation:(const char *)operation {
	if (result == noErr) return;
	char errorString[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(result);
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(errorString, "%d", (int)result);
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    return;
	exit(1);
}

#pragma mark - AudioStreamBasicDescription Utility
+(void)printASBD:(AudioStreamBasicDescription)asbd {
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    (unsigned int)asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    (unsigned int)asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    (unsigned int)asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    (unsigned int)asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    (unsigned int)asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    (unsigned int)asbd.mBitsPerChannel);
}

+(void)localNotificationBody:(NSString *)body
{
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        
        NSDate *now=[NSDate new];
        notification.fireDate=[now dateByAddingTimeInterval:2]; //触发通知的时间
        notification.repeatInterval=0; //循环次数，kCFCalendarUnitWeekday一周一次
        
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody=body;
        
        notification.hasAction = NO; //是否显示额外的按钮，为no时alertAction消失
        
        notification.applicationIconBadgeNumber = 1; //设置app图标右上角的数字
        
        //下面设置本地通知发送的消息，这个消息可以接受
        NSDictionary* infoDic = [NSDictionary dictionaryWithObject:body forKey:@"content"];
        notification.userInfo = infoDic;
        //发送通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

+(void)anchor:(UIView*)obj to:(ANCHOR)anchor withOffset:(CGPoint)offset
{
    NSInteger statusHeight = 20;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect frm = obj.frame;
    
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        screenSize.height -=statusHeight;
    }
    switch (anchor) {
        case TOP_LEFT:
            frm.origin = offset;
            break;
        case TOP:
            frm.origin.x = (screenSize.width - frm.size.width) / 2 + offset.x;
            frm.origin.y = offset.y;
            break;
        case TOP_RIGHT:
            frm.origin.x = screenSize.width - frm.size.width - offset.x;
            frm.origin.y = offset.y;
            break;
        case LEFT:
            frm.origin.x = offset.x;
            frm.origin.y = (screenSize.height - frm.size.height) / 2 + offset.y;
            break;
        case CENTER:
            frm.origin.x = (screenSize.width - frm.size.width) / 2 + offset.x;
            frm.origin.y = (screenSize.height - frm.size.height) / 2 + offset.y;
            break;
        case RIGHT:
            frm.origin.x = screenSize.width - frm.size.width - offset.x;
            frm.origin.y = (screenSize.height - frm.size.height) / 2 + offset.y;
            break;
        case BOTTOM_LEFT:
            frm.origin.x = offset.x;
            frm.origin.y = screenSize.height - frm.size.height - offset.y;
            break;
        case BOTTOM: // 保证贴屏底
            frm.origin.x = (screenSize.width - frm.size.width) / 2 + offset.x;
            frm.origin.y = screenSize.height - frm.size.height - offset.y;
            break;
        case BOTTOM_RIGHT:
            frm.origin.x = screenSize.width - frm.size.width - offset.x;
            frm.origin.y = screenSize.height - frm.size.height - offset.y;
            break;
    }
    
    obj.frame = frm;
}

+(NSString *)convertSecondToMinute:(CGFloat)time
{
    NSInteger roundDownSecond = floor(time);
    int   h = roundDownSecond / (60 * 60);
    int   m = floor((time - h * 60) / 60);
    int   s = (time - h * 60*60 - m * 60);
    
    NSString * str = nil;
    if (h ==0) {
        if (m == 0 && h == 0) {
            str = [NSString stringWithFormat:@"00:%02d",s];
        }else
        {
            str = [NSString stringWithFormat:@"%02d:%02d",m,s];
        }
        
    }else
    {
        str = [NSString stringWithFormat:@"%02d:%02d:%02d",h,m,s];
    }
    
    
    return str;
}

+(NSString *)convertMinuteToSecond:(CGFloat)time
{
    NSInteger minute = floor(time);
    CGFloat   second = time - minute;
    CGFloat totalTime = minute * 60 + second;
    return nil;
}
@end
