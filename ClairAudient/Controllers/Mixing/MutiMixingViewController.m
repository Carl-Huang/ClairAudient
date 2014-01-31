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

@interface MutiMixingViewController ()
{
    AudioPlotView * plotViewUp;
    AudioPlotView * plotViewDown;
    
    NSDictionary * currentEditMusicInfo;
}
@end

@implementation MutiMixingViewController

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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak MutiMixingViewController * weakSelf = self;
    plotViewUp = [[AudioPlotView alloc]initWithFrame:CGRectMake(0, 80, 320, 140)];
    currentEditMusicInfo = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"currentEditingMusic"];
    if (currentEditMusicInfo) {
        [plotViewUp setupAudioPlotViewWitnNimber:[[currentEditMusicInfo valueForKey:@"count"] integerValue] type:OutputTypeDefautl musicPath:[currentEditMusicInfo valueForKey:@"musicURL"] withCompletedBlock:^(BOOL isFinish) {
            if (isFinish) {
                plotViewDown = [[AudioPlotView alloc]initWithFrame:CGRectMake(0, 80+plotViewUp.frame.size.height, 320, 140)];
                [plotViewDown setupAudioPlotViewWitnNimber:1 type:OutputTypeHelper musicPath:[weakSelf.mutiMixingInfo valueForKey:@"musicURL"] withCompletedBlock:^(BOOL isFinish) {
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                }];
                
                [self.contentView addSubview:plotViewDown];
            }
        }];
        [self.contentView addSubview:plotViewUp];

    }else
    {
        //错误
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *destinationFilePath = [NSString stringWithFormat: @"%@/AudioRecording.caf", documentsDirectory];
    NSString *sourceA = [currentEditMusicInfo valueForKey:@"musicURL"];
    NSString *sourceB = [self.mutiMixingInfo valueForKey:@"musicURL"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [MusicMixerOutput mixAudio:sourceA andAudio:sourceB toFile:destinationFilePath preferedSampleRate:10000 withCompletedBlock:^(id object, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            });
        }];
    });
}
@end
