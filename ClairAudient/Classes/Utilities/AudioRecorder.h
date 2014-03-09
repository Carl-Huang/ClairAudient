//
//  AudioRecorder.h
//  ClairAudient
//
//  Created by vedon on 23/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^GetMeterLevelBlock) (CGFloat meter);
@interface AudioRecorder : NSObject

@property (strong ,nonatomic) GetMeterLevelBlock meterLevelBlock;
+(AudioRecorder *)shareAudioRecord;
-(void)initRecordWithPath:(NSString *)localFilePath;
-(void)startRecord;
-(void)pauseRecord;
-(void)stopRecord;
-(CGFloat)meterLevel;
@end
