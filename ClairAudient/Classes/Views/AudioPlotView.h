//
//  AudioPlotView.h
//  ClairAudient
//
//  Created by vedon on 24/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, OutputType)
{
    OutputTypeDefautl = 1,
    OutputTypeHelper  = 2,
};
@interface AudioPlotView : UIView

@property (strong ,nonatomic) NSDictionary * musicInfo;


-(void)setupAudioPlotViewWitnNimber:(NSInteger)number type:(OutputType)type withCompletedBlock:(void (^)(BOOL isFinish))block;
-(void)play;
-(void)pause;
-(void)stop;
@end
