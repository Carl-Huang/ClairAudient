//
//  MixingViewController.m
//  ClairAudient
//
//  Created by Vedon on 14-1-18.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#define testFile [[NSBundle mainBundle] pathForResource:@"权利游戏" ofType:@"mp3"]
#define ForwartTimeLength 200000
#define PlotViewBackgroundColor [UIColor colorWithRed: 0.6 green: 0.6 blue: 0.6  alpha: 1.0];
#define PlotViewOffset 20


#import "MixingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MusicCutter.h"
#import "MBProgressHUD.h"
#import "MixingEffectViewController.h"
#import "AudioPlotView.h"

@interface MixingViewController ()

{
    BOOL isSimulator;
    CGFloat     cuttedMusicLength;
    NSString    * edittingMusicFile;
    AudioPlotView * plotView;
    
    MBProgressHUD * progressView;
}

@property (assign ,nonatomic)CGFloat currentPositionOfFile;
@property (nonatomic,assign) BOOL eof;
@end

@implementation MixingViewController
@synthesize currentPositionOfFile;

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
    
    self.bigTitleLabel.text     = [self.musicInfo valueForKey:@"Artist"];
    self.littleTitleLabel.text  = [self.musicInfo valueForKey:@"Title"];
#if TARGET_IPHONE_SIMULATOR
    isSimulator = YES;
#else
    isSimulator = NO;
#endif
    if (isSimulator) {
        edittingMusicFile = testFile;
    }else
    {
        edittingMusicFile = [self.musicInfo valueForKey:@"musicURL"];;
    }
    NSDictionary * currentEditMusicInfo = @{@"musicURL": edittingMusicFile,@"count":@"1"};
    [[NSUserDefaults standardUserDefaults]setObject:currentEditMusicInfo forKey:@"currentEditingMusic"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    __weak MixingViewController * weakSelf =self;
    plotView = [[AudioPlotView alloc]initWithFrame:CGRectMake(0, 80, 320, 245)];
    [plotView setupAudioPlotViewWitnNimber:1 type:OutputTypeDefautl musicPath:edittingMusicFile withCompletedBlock:^(BOOL isFinish) {
        if (isFinish) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }
    }];
    
    [plotView setLocationBlock:^(NSDictionary * locationInfo)
     {
         NSLog(@"%@",locationInfo);
         [weakSelf updateInterfaceWithInfo:locationInfo];
     }];
    self.endTime.text   = [NSString stringWithFormat:@"%0.2f",[plotView getMusicLength]];
    self.cutLength.text = self.endTime.text;
    [self.view addSubview:plotView];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if ([plotView isPlaying]) {
        [plotView stop];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Private Method
-(void)updateInterfaceWithInfo:(NSDictionary*)info
{
    NSNumber * start = [info valueForKey:@"startLocation"];
    NSNumber * end   = [info valueForKey:@"endLocation"];
    self.startTime.text = [NSString stringWithFormat:@"%0.2f",start.floatValue];
    self.endTime.text   = [NSString stringWithFormat:@"%0.2f",end.floatValue];
    
    CGFloat cutLength = end.floatValue - start.floatValue;
    self.cutLength.text = [NSString stringWithFormat:@"%0.2f",cutLength];
    
}

-(NSString *)getTimeAsFileName
{
    NSDate * date = [NSDate date];
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMddhhmmss"];
    NSString * tempFileName = [format stringFromDate:date];
    return tempFileName;
}
#pragma mark - Outlet Action
- (IBAction)playMusic:(id)sender {
    if (![plotView isPlaying]) {
        [plotView play];
    }else
    {
        [plotView pause];
    }
    
 }

- (IBAction)startCutting:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak MixingViewController * weakSelf = self;
    
    // * Synthesis the music according to the length of the file
    // * Crop the music
    NSString * tempFileName = [self getTimeAsFileName];
    if (tempFileName) {
        tempFileName = [tempFileName stringByAppendingPathExtension:@"mov"];
        [MusicCutter cropMusic:edittingMusicFile exportFileName:tempFileName withStartTime:self.startTime.text.floatValue*60 endTime:self.endTime.text.floatValue*60 withCompletedBlock:^(AVAssetExportSessionStatus status, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [self showAlertViewWithMessage:@"裁剪成功"];
            });
            
        }];
    }
   
}

- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}

- (IBAction)fastForwardAction:(id)sender {
    //快进10秒
    [plotView fastForward:10];
}

- (IBAction)backForwardAction:(id)sender {
    //后退10秒
    [plotView backForward:10];
}

- (IBAction)copyMusicAction:(id)sender {
    NSInteger copyNumber = 3;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (plotView) {
            [plotView removeFromSuperview];
            plotView  =  nil;
        }
        
        plotView = [[AudioPlotView alloc]initWithFrame:CGRectMake(0, 80, 320, 245)];
        
        __weak MixingViewController * weakSelf = self;
        [plotView setupAudioPlotViewWitnNimber:copyNumber type:OutputTypeDefautl musicPath:edittingMusicFile withCompletedBlock:^(BOOL isFinish) {
            if (isFinish) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        }];
        
        [plotView setLocationBlock:^(NSDictionary * locationInfo)
         {
             [weakSelf updateInterfaceWithInfo:locationInfo];
         }];
        self.endTime.text   = [NSString stringWithFormat:@"%0.2f",[plotView getMusicLength]];
        self.cutLength.text = self.endTime.text;
        
        NSDictionary * currentEditMusicInfo = @{@"music": edittingMusicFile,@"count":[NSNumber numberWithInteger:copyNumber]};
        [[NSUserDefaults standardUserDefaults]setObject:currentEditMusicInfo forKey:@"currentEditingMusic"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self.view addSubview:plotView];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });
   
    
}

- (IBAction)addMixingMusicAction:(id)sender {
    
    MixingEffectViewController * viewController = [[MixingEffectViewController alloc]initWithNibName:@"MixingEffectViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
}



@end
