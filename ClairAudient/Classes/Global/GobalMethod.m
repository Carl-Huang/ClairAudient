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
@end
