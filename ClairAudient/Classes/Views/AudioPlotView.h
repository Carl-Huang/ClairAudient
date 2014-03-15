//
//  AudioPlotView.h
//  ClairAudient
//
//  Created by vedon on 24/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^GetMusicLocationInfo)(NSDictionary * info);

typedef NS_ENUM(NSInteger, OutputType)
{
    OutputTypeDefautl = 1,
    OutputTypeHelper  = 2,
};

@interface AudioPlotView : UIView
@property (strong ,nonatomic) NSDictionary      * musicInfo;
@property (strong ,nonatomic) GetMusicLocationInfo locationBlock;
@property (strong ,nonatomic) UIImage       * snapShotImage;
/**
 初始化PlotView: Number 为复制的歌曲数量   
 type:有两种类型，因为只设置了两个单例来控制输出的数据 
 path: 音乐文件路径   
 block:完成初始化时候返回
 */
-(void)setupAudioPlotViewWitnNimber:(NSInteger)number type:(OutputType)type musicPath:(NSString *)path withCompletedBlock:(void (^)(BOOL isFinish))block;

-(void)play;
-(void)pause;
-(void)stop;
-(BOOL)isPlaying;

-(void)fastForward:(NSInteger)sec;
-(void)backForward:(NSInteger)sec;
-(CGFloat)getMusicLength;

-(void)configureSnapShotImage:(NSInteger)number completed:(void (^)(BOOL isCompleted))completedBlock;

/**
 The key in locationInfo : startLocation,endLocation
 */
-(NSDictionary *)getCropMusicLocationInfo;


@end
