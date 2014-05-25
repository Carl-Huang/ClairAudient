//
//  SoundMakerView.m
//  ClairAudient
//
//  Created by vedon on 25/5/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "SoundMakerView.h"
#import "SoundMaker.h"
#import "AppDelegate.h"
#import "GobalMethod.h"

@interface SoundMakerView()
{
    NSInteger pitchValue;
    NSInteger rateValue;
    NSInteger tempoValue;
    
    NSString * desPath;
}
@end
@implementation SoundMakerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage *minImage =     [UIImage imageNamed:@"sliderLine"];
        UIImage *maxImage =     [UIImage imageNamed:@"record_19"];
        UIImage *thumbImage =   [UIImage imageNamed:@"record_20"];
        // Initialization code
        //背景
        [_rateSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
        //拖动的显示条
        [_rateSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
        [_rateSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        
        [_tempoSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
        [_tempoSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
        [_tempoSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        
        [_pitchSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
        [_pitchSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
        [_pitchSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        
        pitchValue = tempoValue = rateValue = 0;
        
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    UIImage *minImage =     [UIImage imageNamed:@"sliderLine"];
    UIImage *maxImage =     [UIImage imageNamed:@"record_19"];
    UIImage *thumbImage =   [UIImage imageNamed:@"record_20"];
    // Initialization code
    //背景
    [_rateSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    //拖动的显示条
    [_rateSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_rateSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    [_tempoSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_tempoSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_tempoSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    [_pitchSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [_pitchSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [_pitchSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    pitchValue = tempoValue = rateValue = 0;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



- (IBAction)listenBtnAciont:(id)sender {
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    
    if (_audioFilePath) {

        NSString * fileName = [_audioFilePath stringByDeletingPathExtension];
        desPath = [fileName stringByAppendingString:@"_temp.caf"];
        
        SoundMaker * maker = [[SoundMaker alloc]init];
        __weak __typeof(self) weakSelf = self;
        [maker initalizationSoundTouchWithSampleRate:44100 Channels:1 TempoChange:tempoValue PitchSemiTones:pitchValue RateChange:rateValue processingAudioFile:_audioFilePath destPath:desPath completedBlock:^(BOOL isSuccess, NSError *error) {
            if (isSuccess) {
                [weakSelf playItemWithPath:desPath length:[GobalMethod getMusicLength:[NSURL fileURLWithPath:desPath]]];
            }
            [MBProgressHUD hideHUDForView:weakSelf animated:YES];
        }];

    }
    
}

- (IBAction)sureBtnAction:(id)sender {
}




- (IBAction)rateSliderAction:(id)sender {
    
    UISlider * slider = sender;
    rateValue = slider.value;
    NSLog(@"%d",rateValue);
}
- (IBAction)pitchSliderAction:(id)sender {
    UISlider * slider = sender;
    pitchValue = slider.value;
}

- (IBAction)tempoSliderAction:(id)sender {
    UISlider * slider = sender;
    tempoValue = slider.value;
}

-(void)playItemWithPath:(NSString *)localFilePath length:(NSString *)length
{
    AppDelegate * myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSURL *inputFileURL = [NSURL fileURLWithPath:localFilePath];
    if([inputFileURL.absoluteString isEqualToString:[myDelegate currentPlayFilePath]])
    {
        //同一文件
        [myDelegate play];
    }else
    {
        [myDelegate playItemWithURL:inputFileURL withMusicInfo:nil withPlaylist:nil];

    }
    
}
@end
