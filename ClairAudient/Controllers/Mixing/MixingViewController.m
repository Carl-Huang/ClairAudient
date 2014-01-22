//
//  MixingViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-18.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#define testFile [[NSBundle mainBundle] pathForResource:@"权利游戏" ofType:@"mp3"]

#import "MixingViewController.h"
#import "EZOutput.h"
#import "EZAudioFile.h"
#import "EZAudio.h"
#import "EZAudioPlot.h"
#import "TrachBtn.h"
#import <AVFoundation/AVFoundation.h>
#import "MusicCutter.h"
#import "MBProgressHUD.h"

@interface MixingViewController ()<EZAudioFileDelegate,EZOutputDataSource>

{
    
    CGFloat     waveLength;
    CGFloat     musicLength;
    CGFloat     cuttedMusicLength;
    NSString    * edittingMusicFile;
    
    
    CGFloat startLocation;
    CGFloat endLocation;
    BOOL isSimulator;
}


@property (nonatomic,strong) EZAudioFile *audioFile;
@property (nonatomic,assign) BOOL eof;
@end

@implementation MixingViewController

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
    
    //初始化音乐波形图
    self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.816 green: 0.349 blue: 0.255 alpha: 0.1];
    self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    self.audioPlot.shouldFill      = NO;
    self.audioPlot.shouldMirror    = YES;

    if (isSimulator) {
        edittingMusicFile = testFile;
    }else
    {
        edittingMusicFile = [self.musicInfo valueForKey:@"musicURL"];;
    }
    NSURL * fileURL = [NSURL fileURLWithPath:edittingMusicFile];
    [self openFileWithFilePathURL:fileURL];
    
    
    
    //startBtn ,endBtn
    waveLength = 320.0f;
    self.startBtn.locationView  = self.audioPlot;
    self.endBtn.locationView    = self.audioPlot;
    __weak MixingViewController * weakSelf = self;
    [self.startBtn setBlock:^(NSInteger offset,NSInteger currentOffsetX)
    {
        CGRect rect         = weakSelf.maskView.frame;
        NSInteger offsetWidth = weakSelf.endBtn.frame.origin.x -currentOffsetX;
        if (offsetWidth < 0) {
            rect.size.width = 0;
        }else
        {
            rect.size.width     = offsetWidth;
        }
        rect.origin.x           = offset;
        weakSelf.maskView.frame = rect;
        
        CGFloat start = (currentOffsetX * musicLength)/waveLength;
        startLocation = start;
        cuttedMusicLength = endLocation - startLocation;
        weakSelf.cutLength.text = [NSString stringWithFormat:@"%0.2f",cuttedMusicLength];
        weakSelf.startTime.text = [NSString stringWithFormat:@"%0.2f",start];
    }];
 
    [self.endBtn setBlock:^(NSInteger offset,NSInteger currentOffsetX)
     {
         CGRect rect        = weakSelf.maskView.frame;
         NSInteger offsetWidth = currentOffsetX -weakSelf.startBtn.frame.origin.x ;
         if (offsetWidth < 0) {
             rect.size.width = 0;
         }else
         {
             rect.size.width = offsetWidth;
         }
         weakSelf.maskView.frame= rect;
         
         CGFloat end = currentOffsetX/waveLength * musicLength;
         endLocation = end;
         cuttedMusicLength = endLocation - startLocation;
         weakSelf.cutLength.text = [NSString stringWithFormat:@"%0.2f",cuttedMusicLength];
         weakSelf.endTime.text = [NSString stringWithFormat:@"%0.2f",end];
    }];
    
    CGSize  size = self.contentScrollView.contentSize;
    [self.contentScrollView setContentSize:CGSizeMake(500, size.height)];
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    
    musicLength = [self getMusicLength:[NSURL fileURLWithPath:testFile]];
    startLocation = 0.0f;
    endLocation = musicLength;
    
    CGFloat timeSlice = musicLength / 6.0;
    for (int i =0; i< 6; i++) {
        UILabel * label     = [[UILabel alloc]initWithFrame:CGRectMake(10+(50)*i, 5, 50, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor     = [UIColor whiteColor];
        label.font          = [UIFont systemFontOfSize:12];
        label.text          = [NSString stringWithFormat:@"%0.2f",timeSlice*i];
        [self.timeLabelView addSubview:label];
        label               = nil;
    }
    self.endTime.text = [NSString stringWithFormat:@"%0.2f",musicLength];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)dealloc
{
    [self setView:nil];
}

//获取音乐长度
-(CGFloat)getMusicLength:(NSURL *)url
{
    AVURLAsset* audioAsset =[AVURLAsset assetWithURL:url];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration)/100.0f;
    return audioDurationSeconds;
}


#pragma mark - Outlet Action
- (IBAction)playMusic:(id)sender {
    if( ![[EZOutput sharedOutput] isPlaying] ){
        if( self.eof ){
            [self.audioFile seekToFrame:0];
        }
        [EZOutput sharedOutput].outputDataSource = self;
        [[EZOutput sharedOutput] startPlayback];
    }
    else {
        [EZOutput sharedOutput].outputDataSource = nil;
        [[EZOutput sharedOutput] stopPlayback];
    }
}

- (IBAction)startCutting:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak MixingViewController * weakSelf = self;
    [MusicCutter cropMusic:edittingMusicFile exportFileName:@"newSong.m4a" withStartTime:self.startTime.text.floatValue*100 endTime:self.endTime.text.floatValue*100 withCompletedBlock:^(AVAssetExportSessionStatus status, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [self showAlertViewWithMessage:@"裁剪成功"];
        });
        
    }];
}


#pragma mark - AudioPlot
-(void)openFileWithFilePathURL:(NSURL*)filePathURL {
    
    // Stop playback
    [[EZOutput sharedOutput] stopPlayback];
    
    self.audioFile                 = [EZAudioFile audioFileWithURL:filePathURL];
    self.audioFile.audioFileDelegate = self;
    self.eof                       = NO;
    
    self.framePositionSlider.maximumValue = (float)self.audioFile.totalFrames;
    
    // Plot the whole waveform
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    self.audioPlot.shouldFill      = YES;
    self.audioPlot.shouldMirror    = YES;
    [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
        [self.audioPlot updateBuffer:waveformData withBufferSize:length];
    }];
    
}

-(void)seekToFrame:(id)sender {
    [self.audioFile seekToFrame:(SInt64)[(UISlider*)sender value]];
}


#pragma mark - EZAudioFileDelegate
-(void)audioFile:(EZAudioFile *)audioFile
       readAudio:(float **)buffer
  withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    if( [EZOutput sharedOutput].isPlaying ){
        dispatch_async(dispatch_get_main_queue(), ^{
            if( self.audioPlot.plotType     == EZPlotTypeBuffer &&
               self.audioPlot.shouldFill    == YES              &&
               self.audioPlot.shouldMirror  == YES ){
                self.audioPlot.shouldFill   = NO;
                self.audioPlot.shouldMirror = YES;
            }
            //      [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
        });
    }
}

-(void)audioFile:(EZAudioFile *)audioFile
 updatedPosition:(SInt64)framePosition {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( !self.framePositionSlider.touchInside ){
            self.framePositionSlider.value = (float)framePosition;
        }
    });
}

#pragma mark - EZOutputDataSource
-(AudioBufferList *)output:(EZOutput *)output
 needsBufferListWithFrames:(UInt32)frames
            withBufferSize:(UInt32 *)bufferSize {
    if( self.audioFile ){
        
        // Reached the end of the file
        if( self.eof ){
            // Here's what you do to loop the file
            [self.audioFile seekToFrame:0];
            self.eof = NO;
        }
        
        // Allocate a buffer list to hold the file's data
        AudioBufferList *bufferList = [EZAudio audioBufferList];
        BOOL eof;
        [self.audioFile readFrames:frames
                   audioBufferList:bufferList
                        bufferSize:bufferSize
                               eof:&eof];
        self.eof = eof;
        
        // Reached the end of the file on the last read
        if( eof ){
            [EZAudio freeBufferList:bufferList];
            return nil;
        }
        return bufferList;
        
    }
    return nil;
}

-(AudioStreamBasicDescription)outputHasAudioStreamBasicDescription:(EZOutput *)output {
    return self.audioFile.clientFormat;
}


#pragma mark - Action Methods
- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}
@end
