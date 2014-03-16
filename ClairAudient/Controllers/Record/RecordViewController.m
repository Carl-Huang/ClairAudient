//
//  RecordViewController.m
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//
#import "RecordListViewController.h"
#import "RecordViewController.h"
#import "RecordMusicInfo.h"
#import "MBProgressHUD.h"
#import "AudioRecorder.h"
#import "AudioManager.h"
#import "AudioWriter.h"
#import "GobalMethod.h"

#import "AsynEncodeAudioRecord.h"

@interface RecordViewController ()<UIAlertViewDelegate>
{
    AudioManager    * audioManager;
    AudioRecorder   * recorder;
    
    NSTimer         * counter;
    NSInteger       hour;
    NSInteger       minute;
    NSInteger       second;
    NSString * defaultFileName;
    NSURL    * recordFileURL;
    NSString * recordMakeTime;
    NSString * recordFilePath;
    
    UIImage * stretchImage;
    
    AsynEncodeAudioRecord * asynEncodeRecorder;
}
@property (strong ,nonatomic) AudioWriter * writer;
@property (assign ,nonatomic) CGFloat maximumWidth;
@end

@implementation RecordViewController
@synthesize writer,maximumWidth;

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
    
    asynEncodeRecorder = [AsynEncodeAudioRecord shareAsynEncodeAudioRecord];
    [asynEncodeRecorder setDecibelBlock:^(CGFloat decibbel)
     {
         @autoreleasepool {
             dispatch_async(dispatch_get_main_queue(), ^{
                 CGFloat absDecibel = abs(decibbel);
                 NSLog(@"%f",absDecibel);
             });
         }
         
     }];

    
    
//    audioManager = [AudioManager shareAudioManager];
//    recorder = [AudioRecorder shareAudioRecord];
//    __weak RecordViewController * weakSelf = self;
//    [recorder setMeterLevelBlock:^(CGFloat meter)
//    {
//        CGRect rect = weakSelf.indicatorView.frame;
//        CGFloat  meterLevel = (CGFloat)abs(meter);
//        if(meterLevel > weakSelf.maximumWidth)
//        {
//            weakSelf.maximumWidth = meterLevel;
//        }
//        rect.size.width = 2*meterLevel/weakSelf.maximumWidth * weakSelf.maximumWidth;
//        weakSelf.indicatorView.frame = rect;
//    }];
//    
    
    
    CGRect rect = _indicatorView.frame;
    maximumWidth = rect.size.width;
    rect.size.width = 0;
    _indicatorView.frame = rect;
    [self.beginRecordView setHidden:YES];
    
    
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [asynEncodeRecorder stopPlayer];
    
//    [recorder cleanRecordResource];
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
        
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
       

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
    [format setDateFormat:@"yyyyMMddhhmmss"];
    NSString * dateStr = [format stringFromDate:currentDate];
    return dateStr;
}

//获取音乐长度
-(CGFloat)getMusicLength:(NSURL *)url
{
    AVURLAsset* audioAsset =[AVURLAsset assetWithURL:url];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    return floor(audioDurationSeconds);
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
    
    [asynEncodeRecorder initializationAudioRecrodWithFileExtension:@"mp3"];
    [asynEncodeRecorder playFile:recordFilePath];
    
    
    
//    [recorder initRecordWithPath:recordFilePath];
//    [recorder startRecord];


    
    [self resetActionView:YES];
    [self timerStart];
    [self resetClocker];
}
- (IBAction)pauseBtnAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    if (btn.selected) {
        [self timerStop];
        
        [asynEncodeRecorder stopPlayer];
//        [recorder pauseRecord];
    }else
    {
        [self timerStart];
        
        [asynEncodeRecorder startPlayer];
//        [recorder startRecord];
    }
}

- (IBAction)stopRecordAction:(id)sender {
    

    [asynEncodeRecorder stopPlayer];
//    [recorder stopRecord];
    [self resetActionView:NO];
    [self timerStop];
    self.clocker.text = @"00:00:00";
   
    
    //1）转换格式
    NSString * destinationFileName = [[self getDocumentDirectory] stringByAppendingPathComponent:[defaultFileName stringByAppendingPathExtension:@"mp3"]];
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [audioManager audio_PCMtoMP3WithSourceFile:recordFilePath destinationFile:destinationFileName withSampleRate:44100];
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //2）保存录音文件信息
    RecordMusicInfo * recordFile = [RecordMusicInfo MR_createEntity];
    recordFile.title    = defaultFileName;
    recordFile.length   = [NSString stringWithFormat:@"%0.2f",[self getMusicLength:recordFileURL]];
    recordFile.makeTime = recordMakeTime;
    recordFile.localPath= destinationFileName;
    [[NSManagedObjectContext MR_defaultContext]MR_saveOnlySelfAndWait];
    
    //3）删除录音文件
    [[NSFileManager defaultManager]removeItemAtPath:recordFilePath error:nil];
    
    
//    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"保存成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alertView show];
//    alertView = nil;
    RecordListViewController * viewController = [[RecordListViewController alloc]initWithNibName:@"RecordListViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
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
//            [audioManager pause];
//            [recorder stopRecord];
            [asynEncodeRecorder stopPlayer];
            [[NSFileManager defaultManager]removeItemAtPath:recordFilePath error:nil];
//            [self.writer stop];
            [self resetActionView:NO];
            break;
        default:
            break;
    }
}

@end
