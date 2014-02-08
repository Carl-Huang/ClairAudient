//
//  RecordViewController.m
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "RecordViewController.h"
#import "AudioManager.h"
#import "AudioWriter.h"
#import "RecordMusicInfo.h"
#import "AudioRecorder.h"
#import "MBProgressHUD.h"
#import "RecordListViewController.h"

@interface RecordViewController ()<UIAlertViewDelegate>
{
    AudioManager    * audioManager;
    NSTimer         * counter;
    
    NSInteger       hour;
    NSInteger       minute;
    NSInteger       second;
    
    NSString * defaultFileName;
    NSURL    * recordFileURL;
    NSString * recordMakeTime;
    NSString * recordFilePath;
    
    AudioRecorder * recorder;
}
@property (strong ,nonatomic) AudioWriter * writer;
@end

@implementation RecordViewController
@synthesize writer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    audioManager = [AudioManager shareAudioManager];
    recorder = [AudioRecorder shareAudioRecord];
    
    
    
    [self.beginRecordView setHidden:YES];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
-(void)increateTime
{
    second ++;
    if ((second % 60) ==0) {
        minute ++;
        second = 0;
        if ((minute % 60) == 0) {
            hour ++;
            minute = 0;
        }
    }
    @autoreleasepool {
        NSString * hourStr = [NSString stringWithFormat:@"%ld",(long)hour];
        if ([hourStr length] == 1) {
            hourStr = [@"0" stringByAppendingString:hourStr];
        }
        
        NSString * minuteStr = [NSString stringWithFormat:@"%ld",(long)minute];
        if ([minuteStr length] == 1) {
            minuteStr = [@"0" stringByAppendingString:minuteStr];
        }
        
        NSString * secondStr = [NSString stringWithFormat:@"%ld",(long)second];
        if ([secondStr length] == 1) {
            secondStr = [@"0" stringByAppendingString:secondStr];
        }
        NSString * timeStr = [NSString stringWithFormat:@"%@:%@:%@",hourStr,minuteStr,secondStr];
        self.clocker.text = timeStr;

    }
}

-(void)resetClocker
{
    hour = minute = second = 0;
    self.clocker.text = @"";
}

-(void)resetActionView:(BOOL)selected
{
    [self.beforeRecordView setHidden:selected];
    [self.beginRecordView setHidden:!selected];
}

-(void)timerStop
{
    if (counter !=nil) {
        [counter invalidate];
        counter = nil;
    }
}

-(void)timerStart
{
    if (counter == nil) {
        counter = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(increateTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:counter forMode:NSRunLoopCommonModes];
        
        [counter fire];
        
    }
}


-(NSString *)getDefaultFileName
{
    NSDate * currentDate = [NSDate date];
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMddhhmmss"];
    NSString * dateStr = [format stringFromDate:currentDate];
    return dateStr;
}

-(NSString *)getMakeTime;
{
    NSDate * currentDate = [NSDate date];
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString * dateStr = [format stringFromDate:currentDate];
    return dateStr;
}

//获取音乐长度
-(CGFloat)getMusicLength:(NSURL *)url
{
    AVURLAsset* audioAsset =[AVURLAsset assetWithURL:url];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration)/100.0f;
    return audioDurationSeconds;
}

-(NSString *)getDocumentDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
#pragma mark - Outlet Action
- (IBAction)startRecordAction:(id)sender {
    
    recordMakeTime  = [self getMakeTime];
    defaultFileName = [self getDefaultFileName];
    //录音的格式为caf 格式
    NSString * localRecordFileFullName = [defaultFileName stringByAppendingPathExtension:@"caf"];
    
    recordFilePath = [[self getDocumentDirectory] stringByAppendingPathComponent:localRecordFileFullName];
    recordFileURL = [NSURL fileURLWithPath:recordFilePath];
    NSLog(@"URL: %@", recordFileURL);
    if ([[NSFileManager defaultManager]fileExistsAtPath:recordFilePath isDirectory:NULL]) {
        [[NSFileManager defaultManager]removeItemAtPath:recordFilePath error:nil];
    }
    
    
    [recorder initRecordWithPath:recordFilePath];
    [recorder startRecord];
    
    
    
//    writer = [[AudioWriter alloc]
//              initWithAudioFileURL:recordFileURL
//              samplingRate:audioManager.samplingRate
//              numChannels:audioManager.numInputChannels];
//    __weak RecordViewController * weakSelf = self;
//    __block CGFloat dbVal = 0.0f;
//    audioManager.inputBlock = ^(float *data, UInt32 numFrames, UInt32 numChannels) {
//        [weakSelf.writer writeNewAudio:data numFrames:numFrames numChannels:numChannels];
//        vDSP_vsq(data, 1, data, 1, numFrames*numChannels);
//        CGFloat meanVal = 0.0f;
//        vDSP_meanv(data, 1, &meanVal, numFrames*numChannels);
//        CGFloat one = 1.0;
//        vDSP_vdbcon(&meanVal, 1, &one, &meanVal, 1, 1, 0);
//        dbVal = dbVal + 0.2f*(meanVal - dbVal);
//        if (isnan(dbVal)) {
//            dbVal = 0.f;
//        }
//        CGFloat max = 0.f;
//        CGFloat min = -60.f;
//        
//        CGFloat percentage = 1.f-dbVal/(min-max);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"%f",percentage);
//        });
//    };
//    [audioManager play];
    
    
    
    [self resetActionView:YES];
    [self timerStart];
    [self resetClocker];
}
- (IBAction)pauseBtnAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    if (btn.selected) {
        [self timerStop];
        
//        [audioManager pause];
//        [self.writer pause];
        [recorder pauseRecord];
    }else
    {
        [self timerStart];
        
//        [audioManager play];
//        [self.writer record];
        [recorder startRecord];
    }
}

- (IBAction)stopRecordAction:(id)sender {
    
    //清理工作
//    [audioManager   pause];
//    [self.writer    stop];
//     self.writer = nil;
    
    [recorder stopRecord];
    [self resetActionView:NO];
    [self timerStop];
    self.clocker.text = @"00:00:00";
   
    
    //1）转换格式
    NSString * destinationFileName = [[self getDocumentDirectory] stringByAppendingPathComponent:[defaultFileName stringByAppendingPathExtension:@"mp3"]];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [audioManager audio_PCMtoMP3WithSourceFile:recordFilePath destinationFile:destinationFileName];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //2）保存录音文件信息
    RecordMusicInfo * recordFile = [RecordMusicInfo MR_createEntity];
    recordFile.title    = defaultFileName;
    recordFile.length   = [NSString stringWithFormat:@"%0.2f",[self getMusicLength:recordFileURL]];
    recordFile.makeTime = recordMakeTime;
    recordFile.localPath= destinationFileName;
    [[NSManagedObjectContext MR_defaultContext]MR_saveOnlySelfAndWait];
    
    //3）删除录音文件
    [[NSFileManager defaultManager]removeItemAtPath:recordFilePath error:nil];
    
    
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"保存成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    alertView = nil;
}

- (IBAction)cancelRecordAction:(id)sender {
    [self timerStop];
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"删除录音" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    alertView = nil;
}

- (IBAction)showRecordFileAction:(id)sender {
    
    RecordListViewController * viewController = [[RecordListViewController alloc]initWithNibName:@"RecordListViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
}

- (IBAction)backAction:(id)sender {
    [self popVIewController];
}

#pragma mark - AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //取消
            break;
        case 1:
            //确定
            [audioManager pause];
            [recorder stopRecord];
            [[NSFileManager defaultManager]removeItemAtPath:recordFilePath error:nil];
//            [self.writer stop];
            [self resetActionView:NO];
            break;
        default:
            break;
    }
}

@end
