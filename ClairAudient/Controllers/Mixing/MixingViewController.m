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

@interface MixingViewController ()<EZAudioFileDelegate,EZOutputDataSource>

{
    //记录开始，结束时间
    NSInteger startTime;
    NSInteger endTime;
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
    
    
    //初始化音乐波形图
    self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.816 green: 0.349 blue: 0.255 alpha: 0.1];
    self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    self.audioPlot.shouldFill      = NO;
    self.audioPlot.shouldMirror    = YES;

    //TODO:读取本地文件的播放
//    NSURL * url = (NSURL *)[self.musicInfo valueForKey:@"musicURL"];

    CGSize  size = self.contentScrollView.contentSize;
    [self.contentScrollView setContentSize:CGSizeMake(500, size.height)];
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    [self openFileWithFilePathURL:[NSURL fileURLWithPath:testFile]];
    
    
    //startBtn ,endBtn
    self.startBtn.locationView  = self.audioPlot;
    self.endBtn.locationView    = self.audioPlot;
    [self.startBtn setBlock:^(NSInteger offset)
    {
        CGRect rect         = self.maskView.frame;
        rect.origin.x       = offset;
        startTime           = offset;
        self.maskView.frame = rect;
        NSInteger length    = endTime-startTime;
        self.cutLength.text = [NSString stringWithFormat:@"%ld",(long)length];
    }];
    [self.startBtn setEndMoveBlock:^(NSInteger offset)
     {
         CGRect rect         = self.maskView.frame;
         rect.origin.x       = offset;
         rect.size.width     = rect.size.width - offset;
         self.maskView.frame = rect;
     }];
    
    [self.endBtn setBlock:^(NSInteger offset)
     {
         CGRect rect        = self.maskView.frame;
         rect.size.width    = offset;
         endTime            = offset;
         self.maskView.frame= rect;
        
         NSInteger length   = endTime-startTime;
         self.cutLength.text = [NSString stringWithFormat:@"%ld",(long)length];
         
    }];
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
