//
//  MusicCutter.h
//  Record_Mix_Play
//
//  Created by vedon on 5/1/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface MusicCutter : NSObject
+(void)cropMusic:(NSString *)musicSourcePath exportFileName:(NSString *)exportedFileName withStartTime:(CGFloat)timeS endTime:(CGFloat)timeE withCompletedBlock:(void (^)(AVAssetExportSessionStatus status,NSError *error))completedBlock;
@end
