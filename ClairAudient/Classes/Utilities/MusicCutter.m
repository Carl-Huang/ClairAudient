//
//  MusicCutter.m
//  Record_Mix_Play
//
//  Created by vedon on 5/1/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "MusicCutter.h"
#import "lame.h"
#import <MobileCoreServices/MobileCoreServices.h>
@implementation MusicCutter

+(void)cropMusic:(NSString *)musicSourcePath exportFileName:(NSString *)exportedFileName withStartTime:(CGFloat)timeS endTime:(CGFloat)timeE withCompletedBlock:(void (^)(AVAssetExportSessionStatus status,NSError *error,NSString * localPath))completedBlock
{
    
    NSURL *songURL      = [NSURL fileURLWithPath:musicSourcePath];
    [self startCropMusicWithExportFileName:exportedFileName songURL:songURL startTime:timeS endTime:timeE completedBlock:^(AVAssetExportSessionStatus status, NSError *error, NSString *localPath) {
        completedBlock(status,error,localPath);
    }];
    
}

+(void)startCropMusicWithExportFileName:(NSString *)exportedFileName songURL:(NSURL *)songURL startTime:(CGFloat)timeS endTime:(CGFloat)timeE completedBlock:(void (^)(AVAssetExportSessionStatus status,NSError *error,NSString * localPath))completedBlock
{
    AVURLAsset *musicAsset = [AVURLAsset URLAssetWithURL:songURL options:nil];
    NSString * path     = [self getExportPath:exportedFileName];
    NSURL *exportURL    = [NSURL fileURLWithPath:path];
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:musicAsset
                                                                            presetName:AVAssetExportPresetPassthrough];
    CMTime startTime                = CMTimeMake(timeS, 1);
    CMTime stopTime                 = CMTimeMake(timeE, 1);
    CMTimeRange exportTimeRange     = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    exportSession.outputURL         = exportURL;                       // output path
    exportSession.outputFileType    = @"com.apple.quicktime-movie";    // output file type
    exportSession.timeRange         = exportTimeRange;                 // trim time range
    NSLog(@"export.supportedFileTypes : %@",exportSession.supportedFileTypes);
    exportSession.shouldOptimizeForNetworkUse = YES;
    
    //log the file type
    NSString *extension = (__bridge  NSString *)UTTypeCopyPreferredTagWithClass((__bridge  CFStringRef)exportSession.outputFileType, kUTTagClassFilenameExtension);
    
    NSLog(@"extension %@",extension);
    
    
    //start crop music
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
            
            NSFileManager *manage   = [NSFileManager defaultManager];
            NSString * convertedFilePath = [NSString stringWithString:path];
            NSString *mp3Path       = [[convertedFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp3"];
            NSError *error = nil;
            [manage moveItemAtPath:path toPath:mp3Path error:&error];
            NSLog(@"error %@",error);
            completedBlock(AVAssetExportSessionStatusCompleted,error,mp3Path);
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusFailed");
            completedBlock(AVAssetExportSessionStatusFailed,nil,nil);
        } else {
            completedBlock(exportSession.status,nil,nil);
            NSLog(@"Export Session Status: %d", exportSession.status);
        }
    }];

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

+ (void)audio_PCMtoMP3WithSourceFile:(NSString *)sourceFile destinationFile:(NSString *)desFile sampleRate:(int) sampleRate
{
    NSString *cafFilePath = sourceFile;
    
    NSString *mp3FilePath = desFile;
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil])
    {
        NSLog(@"删除");
    }
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192*2;
        const int MP3_SIZE = 8192*2;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, sampleRate);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        
    }
}
@end
