//
//  MutiMixingViewController.m
//  ClairAudient
//
//  Created by vedon on 24/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MutiMixingViewController.h"
#import "AudioPlotView.h"

@interface MutiMixingViewController ()
{
    AudioPlotView * plotViewUp;
    AudioPlotView * plotViewDown;
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
    
    plotViewUp = [[AudioPlotView alloc]initWithFrame:CGRectMake(0, 80, 320, 140)];
    [plotViewUp setupAudioPlotViewWitnNimber:3 type:OutputTypeDefautl withCompletedBlock:^(BOOL isFinish) {
//        if (isFinish) {
//            plotViewDown = [[AudioPlotView alloc]initWithFrame:CGRectMake(0, 80+plotViewUp.frame.size.height, 320, 140)];
//            [plotViewDown setupAudioPlotViewWitnNimber:6 type:OutputTypeHelper withCompletedBlock:^(BOOL isFinish) {
//                ;
//            }];
//            
//            [self.contentView addSubview:plotViewDown];
//        }
    }];
    [self.contentView addSubview:plotViewUp];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
     [self popVIewController];

}

- (IBAction)playAction:(id)sender {
    [plotViewUp play];
    [plotViewDown play];
    
}
@end
