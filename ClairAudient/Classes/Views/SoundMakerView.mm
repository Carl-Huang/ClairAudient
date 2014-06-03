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
#import "RecordMusicInfo.h"

@interface SoundMakerView()
{
    NSInteger pitchValue;
    NSInteger rateValue;
    NSInteger tempoValue;
    
    NSString * desPath;
    BOOL isAlreadyProcess;
}
@end
@implementation SoundMakerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage *minImage =     [[UIImage imageNamed:@"seek_select"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
        UIImage *maxImage =     [UIImage imageNamed:@"seek_normal"];
        UIImage *thumbImage =   [UIImage imageNamed:@"change_voice_thumb"];
        
        [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
        [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
        [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
        [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateHighlighted];
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
     UIImage *minImage =     [[UIImage imageNamed:@"seek_select"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    UIImage *maxImage =     [UIImage imageNamed:@"seek_normal"];
    UIImage *thumbImage =   [UIImage imageNamed:@"change_voice_thumb"];

    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateHighlighted];
    
    self.containerView.layer.cornerRadius = 15;
    isAlreadyProcess = NO;
    _rateLabel.text = @"0";
    _pitchLabel.text = @"0";
    _tempoLabel.text = @"0";
    pitchValue = tempoValue = rateValue = 0;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSoundMakerView)];
    [_soundMakerViewBg addGestureRecognizer:tap];
    tap = Nil;
    
    

    if ([OSHelper iPhone5]) {
        CGRect rect  = _maskView.frame;
        rect.size.height+=88;
        _maskView.frame = rect;
    }
}


- (IBAction)listenBtnAciont:(id)sender {
    
    NSString * fileName = [_audioFilePath stringByDeletingPathExtension];
    desPath = [fileName stringByAppendingString:@"_temp.caf"];
    if (_audioFilePath&&!isAlreadyProcess) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self animated:YES];
            SoundMaker * maker = [[SoundMaker alloc]init];
            __weak __typeof(self) weakSelf = self;
            [maker initalizationSoundTouchWithSampleRate:44100 Channels:1 TempoChange:tempoValue PitchSemiTones:pitchValue RateChange:rateValue processingAudioFile:_audioFilePath destPath:desPath completedBlock:^(BOOL isSuccess, NSError *error) {
                if (isSuccess) {
                    [weakSelf playItemWithPath:desPath length:[GobalMethod getMusicLength:[NSURL fileURLWithPath:desPath]]];
                    isAlreadyProcess = YES;
                }else
                {
                    [self showAlertViewWithMessage:@"不支持格式"];
                }
                [MBProgressHUD hideHUDForView:weakSelf animated:YES];
            }];
        });
        
    }else
    {
        [self playItemWithPath:desPath length:[GobalMethod getMusicLength:[NSURL fileURLWithPath:desPath]]];
    }
    
}

- (IBAction)sureBtnAction:(id)sender {
    
    
    [[NSFileManager defaultManager]removeItemAtPath:_audioFilePath error:nil];
//    [[NSFileManager defaultManager]moveItemAtPath:desPath toPath:_audioFilePath error:nil];
    
    NSArray * array = [RecordMusicInfo MR_findByAttribute:@"localPath" withValue:_audioFilePath];
    if ([array count]) {
         RecordMusicInfo * recordItemInfo = [array objectAtIndex:0];
        recordItemInfo.localPath = desPath;
        [[NSManagedObjectContext MR_contextForCurrentThread]MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
            ;
        }];
    }
    [self resetSiderInterface];
   [self removeFromSuperview];
    
    if (_processingBlock) {
        _processingBlock(desPath,YES,nil);
    }
}

-(void)resetSiderInterface
{
    UIImage *minImage =     [UIImage imageNamed:@"sliderLine"];
    UIImage *maxImage =     [UIImage imageNamed:@"record_19"];
    UIImage *thumbImage =   [UIImage imageNamed:@"record_20"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateHighlighted];
    
}


- (IBAction)rateSliderAction:(id)sender {
    
    UISlider * slider = sender;
    rateValue = slider.value;
    _rateLabel.text = [NSString stringWithFormat:@"%d",rateValue];
}
- (IBAction)pitchSliderAction:(id)sender {
    UISlider * slider = sender;
    pitchValue = slider.value;
    _pitchLabel.text = [NSString stringWithFormat:@"%d",pitchValue];
}

- (IBAction)tempoSliderAction:(id)sender {
    UISlider * slider = sender;
    tempoValue = slider.value;
    _tempoLabel.text = [NSString stringWithFormat:@"%d",tempoValue];
}

-(void)removeSoundMakerView
{
    [self resetSiderInterface];
    [self removeFromSuperview];
    if (_processingBlock) {
        _processingBlock(nil,NO,nil);
    }
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
- (void)showAlertViewWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
    });
}
@end
