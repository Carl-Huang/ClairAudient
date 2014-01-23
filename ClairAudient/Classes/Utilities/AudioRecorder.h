//
//  AudioRecorder.h
//  ClairAudient
//
//  Created by vedon on 23/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioRecorder : NSObject


+(AudioRecorder *)shareAudioRecord;

-(void)initRecordWithPath:(NSString *)localFilePath;
-(void)startRecord;
-(void)pauseRecord;
-(void)stopRecord;
-(CGFloat)meterLevel;
@end
