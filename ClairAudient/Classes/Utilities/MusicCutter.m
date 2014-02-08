//
//  MusicCutter.m
//  Record_Mix_Play
//
//  Created by vedon on 5/1/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "MusicCutter.h"

@implementation MusicCutter

+(void)cropMusic:(NSString *)musicSourcePath exportFileName:(NSString *)exportedFileName withStartTime:(CGFloat)timeS endTime:(CGFloat)timeE withCompletedBlock:(void (^)(AVAssetExportSessionStatus status,NSError *error))completedBlock
{
    
    NSURL *songURL = [NSURL fileURLWithPath:musicSourcePath];
    AVURLAsset *musicAsset = [AVURLAsset URLAssetWithURL:songURL options:nil];
    NSURL *exportURL = [NSURL fileURLWithPath:[self getExportPath:exportedFileName]];
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:musicAsset
                                                                            presetName:AVAssetExportPresetAppleM4A];
    CMTime startTime = CMTimeMake(timeS, 1);
    CMTime stopTime = CMTimeMake(timeE, 1);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    exportSession.outputURL = exportURL; // output path
    exportSession.outputFileType = AVFileTypeMPEGLayer3; // output file type
    exportSession.timeRange = exportTimeRange; // trim time range
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
            completedBlock(AVAssetExportSessionStatusCompleted,nil);
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusFailed");
            completedBlock(AVAssetExportSessionStatusFailed,nil);
        } else {
            completedBlock(exportSession.status,nil);
            NSLog(@"Export Session Status: %d", exportSession.status);
        }
    }];
}

+(NSString *)getExportPath:(NSString *)fileName
{
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    return exportPath;
}
@end
