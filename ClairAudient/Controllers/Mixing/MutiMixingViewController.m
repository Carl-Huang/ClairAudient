//
//  MutiMixingViewController.m
//  ClairAudient
//
//  Created by vedon on 24/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MutiMixingViewController.h"
#import "AudioPlotView.h"
#import "MBProgressHUD.h"
#import "MusicMixerOutput.h"
#import "AudioManager.h"
#import "EditMusicInfo.h"
#import "GobalMethod.h"
#import "PersistentStore.h"
@interface MutiMixingViewController ()
{
    AudioPlotView * plotViewUp;
    AudioPlotView * plotViewDown;
    
    NSDictionary * currentEditMusicInfo;

}
@property (strong ,nonatomic)    AudioManager * audioManager;
@end

@implementation MutiMixingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"混音制作";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak MutiMixingViewController * weakSelf = self;
    plotViewUp = [[AudioPlotView alloc]initWithFrame:CGRectMake(0, 60, 320, 130)];
    currentEditMusicInfo = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"currentEditingMusic"];
    [plotViewUp setLocationBlock:^(NSDictionary * locationInfo)
     {
         NSLog(@"%@",locationInfo);
         [weakSelf updateInterfaceWithUpperInfo:locationInfo];
     }];
    
    if (currentEditMusicInfo) {
        //初始化第一张频谱图
        [plotViewUp setupAudioPlotViewWitnNimber:[[currentEditMusicInfo valueForKey:@"count"] integerValue] type:OutputTypeDefautl musicPath:[currentEditMusicInfo valueForKey:@"musicURL"] withCompletedBlock:^(BOOL isFinish) {
            if (isFinish) {
                //初始化第二张频谱图
                dispatch_async(dispatch_get_main_queue(), ^{
                    plotViewDown = [[AudioPlotView alloc]initWithFrame:CGRectMake(0, 60+plotViewUp.frame.size.height, 320, 130)];
                    [plotViewDown setLocationBlock:^(NSDictionary * locationInfo)
                     {
                         NSLog(@"%@",locationInfo);
                         [weakSelf updateInterfaceWithDownnInfo:locationInfo];
                     }];
                    [plotViewDown setupAudioPlotViewWitnNimber:1 type:OutputTypeHelper musicPath:[weakSelf.mutiMixingInfo valueForKey:@"musicURL"] withCompletedBlock:^(BOOL isFinish) {
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    }];
                    
                    [self.contentView addSubview:plotViewDown];
                });
                
            }
        }];
        [self.contentView addSubview:plotViewUp];

    }else
    {
        //错误
    }
    CGRect rect = self.controlBtnView.frame;
    rect.origin.x = plotViewUp.frame.size.height * 2;
    self.controlBtnView.frame = rect;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (plotViewUp) {
        plotViewUp = nil;
    }
    
    if (plotViewDown) {
        plotViewDown = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Private Method
-(void)updateInterfaceWithUpperInfo:(NSDictionary*)info
{
    NSNumber * start = [info valueForKey:@"startLocation"];
    NSNumber * end   = [info valueForKey:@"endLocation"];
    self.startTimeLabel.text = [NSString stringWithFormat:@"%0.2f",start.floatValue];
    self.endTimeLabel.text   = [NSString stringWithFormat:@"%0.2f",end.floatValue];
    
    CGFloat cutLength = end.floatValue - start.floatValue;
    self.lengthLabel.text = [NSString stringWithFormat:@"%0.2f",cutLength];
    self.musicObject.text = @"音频一";
}

-(void)updateInterfaceWithDownnInfo:(NSDictionary*)info
{
    NSNumber * start = [info valueForKey:@"startLocation"];
    NSNumber * end   = [info valueForKey:@"endLocation"];
    self.startTimeLabel.text = [NSString stringWithFormat:@"%0.2f",start.floatValue];
    self.endTimeLabel.text   = [NSString stringWithFormat:@"%0.2f",end.floatValue];
    
    CGFloat cutLength = end.floatValue - start.floatValue;
    self.lengthLabel.text = [NSString stringWithFormat:@"%0.2f",cutLength];
    self.musicObject.text = @"音频二";
}
#pragma  mark - Outlet Action
- (IBAction)backAction:(id)sender {
     [self popVIewController];

}

- (IBAction)playAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    if (btn.selected) {
        [plotViewUp play];
        [plotViewDown play];
    }else
    {
        [plotViewUp pause];
        [plotViewDown pause];
    }
}

- (IBAction)startMixingAction:(id)sender {
    __weak MutiMixingViewController * weakSelf = self;
    
    NSString *tempFilePath = [GobalMethod getExportPath:@"temp.caf"];
    
    
    NSString * mixingFileName = [GobalMethod userCurrentTimeAsFileName];
    mixingFileName = [mixingFileName stringByAppendingPathExtension:@"mp3"];
    NSString *destinationFilePath = [GobalMethod getExportPath:mixingFileName];
    
    NSString *sourceA = [currentEditMusicInfo valueForKey:@"musicURL"];
    NSString *sourceB = [self.mutiMixingInfo valueForKey:@"musicURL"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [MusicMixerOutput mixAudio:sourceA andAudio:sourceB toFile:tempFilePath preferedSampleRate:10000 withCompletedBlock:^(id object, NSError *error) {
            if (error) {
                [self showAlertViewWithMessage:@"不支持音乐格式"];
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //转换caf to mp3 格式
                    weakSelf.audioManager = [AudioManager shareAudioManager];
                    [weakSelf.audioManager audio_PCMtoMP3WithSourceFile:tempFilePath destinationFile:destinationFilePath withSampleRate:10000];
                    
                    //保存信息到本地
                    EditMusicInfo * info = [EditMusicInfo MR_createEntity];
                    info.localPath = destinationFilePath;
                    info.makeTime = [GobalMethod getMakeTime];
                    info.length = [GobalMethod getMusicLength:[NSURL fileURLWithPath:destinationFilePath]];
                    [PersistentStore save];
                    
                    //删除caf 格式文件
                    [[NSFileManager defaultManager]removeItemAtPath:tempFilePath error:nil];
                    
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                });
            }
            
        }];
    });
}
@end
