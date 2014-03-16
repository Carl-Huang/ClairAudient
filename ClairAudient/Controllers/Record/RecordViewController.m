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
#import "GobalMethod.h"


#import "AsynEncodeAudioRecord.h"

@interface RecordViewController ()<UIAlertViewDelegate>
{
    
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
@property (assign ,nonatomic) CGFloat maximumWidth;
@end

@implementation RecordViewController
@synthesize maximumWidth;

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
    
    __weak RecordViewController * weakSelf = self;
    asynEncodeRecorder = [AsynEncodeAudioRecord shareAsynEncodeAudioRecord];
    [asynEncodeRecorder setDecibelBlock:^(CGFloat decibbel)
     {
         @autoreleasepool {
             dispatch_async(dispatch_get_main_queue(), ^{
                 @autoreleasepool {
                     CGFloat absDecibel = abs(decibbel);
                     CGRect rect = weakSelf.indicatorView.frame;
                     if(absDecibel > weakSelf.maximumWidth)
                     {
                         weakSelf.maximumWidth = absDecibel;
                     }
                     rect.size.width = absDecibel/5 * weakSelf.maximumWidth ;
                     weakSelf.indicatorView.frame = rect;
                     
//                     NSLog(@"%f",rect.size.width);
                 }
                
             });
         }
         
     }];
    
   

    

    CGRect rect = _volumeContainerView.frame;
    maximumWidth = rect.size.width;


    [self.beginRecordView setHidden:YES];
    
    
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [asynEncodeRecorder stopPlayer];
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
    
    recordMakeTime  = [GobalMethod getMakeTime];
    defaultFileName = [GobalMethod userCurrentTimeAsFileName];
    
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
    }else
    {
        [self timerStart];
        
        [asynEncodeRecorder startPlayer];
    }
}

- (IBAction)stopRecordAction:(id)sender {
    

    [asynEncodeRecorder stopPlayer];
    [self resetActionView:NO];
    [self timerStop];
    self.clocker.text = @"00:00:00";
   
    
    //1）取得转换后的文件
    NSString * destinationFileName = [[self getDocumentDirectory] stringByAppendingPathComponent:[defaultFileName stringByAppendingPathExtension:@"mp3"]];
    
    //2）保存录音文件信息
    RecordMusicInfo * recordFile = [RecordMusicInfo MR_createEntity];
    recordFile.title    = defaultFileName;
    recordFile.length   = [GobalMethod getMusicLength:[NSURL fileURLWithPath:recordFilePath]];
    recordFile.makeTime = recordMakeTime;
    recordFile.localPath= destinationFileName;
    [[NSManagedObjectContext MR_defaultContext]MR_saveOnlySelfAndWait];
    
    //3）删除录音文件
    [[NSFileManager defaultManager]removeItemAtPath:recordFilePath error:nil];
    

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

            [asynEncodeRecorder stopPlayer];
            [[NSFileManager defaultManager]removeItemAtPath:recordFilePath error:nil];
            [self resetActionView:NO];
            break;
        default:
            break;
    }
}

@end
