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

@interface RecordViewController ()<UIAlertViewDelegate>
{
    AudioManager    * audioManager;
    NSTimer         * counter;
    
    NSInteger       hour;
    NSInteger       minute;
    NSInteger       second;
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

    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyRecording.caf",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    NSLog(@"URL: %@", outputFileURL);
    writer = [[AudioWriter alloc]
                  initWithAudioFileURL:outputFileURL
                  samplingRate:audioManager.samplingRate
                  numChannels:audioManager.numInputChannels];
    __weak RecordViewController * weakSelf = self;
    __block CGFloat dbVal = 0.0f;
    audioManager.inputBlock = ^(float *data, UInt32 numFrames, UInt32 numChannels) {
        vDSP_vsq(data, 1, data, 1, numFrames*numChannels);
        CGFloat meanVal = 0.0f;
        vDSP_meanv(data, 1, &meanVal, numFrames*numChannels);
        CGFloat one = 1.0;
        vDSP_vdbcon(&meanVal, 1, &one, &meanVal, 1, 1, 0);
        dbVal = dbVal + 0.2f*(meanVal - dbVal);
        if (isnan(dbVal)) {
            dbVal = 0.f;
        }
        CGFloat max = 0.f;
        CGFloat min = -60.f;
        
        CGFloat percentage = 1.f-dbVal/(min-max);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%f",percentage);
        });
        
        [weakSelf.writer writeNewAudio:data numFrames:numFrames numChannels:numChannels];
        
    };
    
    
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
        NSString * hourStr = [NSString stringWithFormat:@"%d",hour];
        if ([hourStr length] == 1) {
            hourStr = [@"0" stringByAppendingString:hourStr];
        }
        
        NSString * minuteStr = [NSString stringWithFormat:@"%d",minute];
        if ([minuteStr length] == 1) {
            minuteStr = [@"0" stringByAppendingString:minuteStr];
        }
        
        NSString * secondStr = [NSString stringWithFormat:@"%d",second];
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


#pragma mark - Outlet Action
- (IBAction)startRecordAction:(id)sender {
    [audioManager play];
    [self.beforeRecordView setHidden:YES];
    [self.beginRecordView setHidden:NO];
    
    [counter invalidate];
    counter = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(increateTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:counter forMode:NSRunLoopCommonModes];
    [self resetClocker];
    [counter fire];
}
- (IBAction)pauseBtnAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    if (btn.selected) {
        [audioManager pause];
        [self.writer pause];
    }else
    {
        [audioManager play];
        [self.writer record];
    }
}

- (IBAction)stopRecordAction:(id)sender {
    [audioManager pause];
    [self.writer stop];
}

- (IBAction)cancelRecordAction:(id)sender {
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"删除录音" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    alertView = nil;
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
            break;
        default:
            break;
    }
}

@end
