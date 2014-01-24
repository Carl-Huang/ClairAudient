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
#import "EZOutput.h"
#import "EZAudioFile.h"
#import "EZAudio.h"
#import "EZAudioPlot.h"
#import "TrachBtn.h"
#import <AVFoundation/AVFoundation.h>
#import "MusicCutter.h"
#import "MBProgressHUD.h"
#import "CloneView.h"

@interface MixingViewController ()<EZAudioFileDelegate,EZOutputDataSource>

{
    BOOL isSimulator;
    CGFloat     waveLength;
    CGFloat     musicLength;
    CGFloat     cuttedMusicLength;
    NSString    * edittingMusicFile;
    
    
    CGFloat startLocation;
    CGFloat endLocation;
    
    CGFloat totalLengthOfTheFile;
    UIView * timeline;
    
    EZAudioPlot * tempPlotView ;
    NSInteger  numberOfPlotView;
    
}

@property (assign ,nonatomic)CGFloat currentPositionOfFile;
@property (nonatomic,strong) EZAudioFile *audioFile;
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
    
    //初始化音乐波形图
    self.audioPlot.backgroundColor = PlotViewBackgroundColor
    self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    self.audioPlot.shouldFill      = YES;
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
    
    //设置contentScrollView
    [self.contentScrollView setContentSize:CGSizeMake(500, self.contentScrollView.frame.size.height)];
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    CGRect scrollViewRect = self.contentScrollView.frame;
    scrollViewRect.origin.x +=PlotViewOffset;
    [self.contentScrollView scrollRectToVisible:scrollViewRect animated:YES];
    
    musicLength = [self getMusicLength:[NSURL fileURLWithPath:edittingMusicFile]];
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
    
    
    timeline =  [[UIView alloc]initWithFrame:CGRectMake(PlotViewOffset, 0, 1, self.contentScrollView.frame.size.height)];
    [timeline setBackgroundColor:[UIColor yellowColor]];
    [self addObserver:self forKeyPath:@"currentPositionOfFile" options:NSKeyValueObservingOptionNew context:NULL];
    
    
    [self.contentScrollView addSubview:timeline];
    currentPositionOfFile = 0.0f;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(seekToPosition:)];
    [self.timeLineView addGestureRecognizer:tapGesture];
    tapGesture = nil;
    
    numberOfPlotView = 1;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

-(void)viewWillDisappear:(BOOL)animated
{
   
    [EZOutput sharedOutput].outputDataSource = nil;
    [[EZOutput sharedOutput] stopPlayback];


}
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"currentPositionOfFile"];
    [self setView:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentPositionOfFile"]) {
        CGFloat position = currentPositionOfFile/totalLengthOfTheFile * 320;
        [self updateTimeLinePosition:position];
    }
}

#pragma mark - Private Method
//获取音乐长度
-(CGFloat)getMusicLength:(NSURL *)url
{
    AVURLAsset* audioAsset =[AVURLAsset assetWithURL:url];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration)/100.0f;
    return audioDurationSeconds;
}

-(void)seekToPosition:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self.timeLineView];
    
    [self updateTimeLinePosition:point.x];
    CGFloat position        = point.x / waveLength * totalLengthOfTheFile;
    NSLog(@"position :%f totalLengthOfTheFile:%f ",position,totalLengthOfTheFile);
    self.currentPositionOfFile   = position;
    [self seekToPostionWithValue:position];
    
}

-(void)seekToPostionWithValue:(CGFloat)offset
{
    @synchronized(self.audioFile)
    {
        [self.audioFile seekToFrame:offset];
    }
    
}

-(void)updateTimeLinePosition:(CGFloat)offset
{
    @autoreleasepool {
        CGRect rect = timeline.frame;
        rect.origin.x = offset + PlotViewOffset;
        timeline.frame = rect;
    }
}

-(void)cloneView
{
    CloneView * cloneView = [[CloneView alloc]initWithView:self.audioPlot];
    CGRect rect = cloneView.frame;
    rect.origin.y = 0; 
    rect.origin.x +=rect.size.width;
    cloneView.frame = rect;
    [self.contentScrollView addSubview:cloneView];
    CGSize size = self.contentScrollView.contentSize;
    size.width +=cloneView.frame.size.width;
    [self.contentScrollView setContentSize:size];
    
}

-(void)addPlotView
{
    @autoreleasepool {
        CGRect rect = self.audioPlot.frame;
        rect.origin.x = rect.size.width * numberOfPlotView +PlotViewOffset;
        rect.origin.y -= 10;
        tempPlotView = [[EZAudioPlot alloc]initWithFrame:rect];
        tempPlotView.backgroundColor = PlotViewBackgroundColor;        tempPlotView.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        tempPlotView.plotType        = EZPlotTypeBuffer;
        tempPlotView.shouldFill      = YES;
        tempPlotView.shouldMirror    = YES;
        self.eof                     = NO;
        
        EZAudioFile *tempAudioFile  = [EZAudioFile audioFileWithURL:[NSURL fileURLWithPath:edittingMusicFile]];
        
        
        // Plot the whole waveform
        tempPlotView.plotType        = EZPlotTypeBuffer;
        tempPlotView.shouldFill      = YES;
        tempPlotView.shouldMirror    = YES;
        
        __weak MixingViewController * weakSelf = self;
        [tempAudioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
            [tempPlotView updateBuffer:waveformData withBufferSize:length];
            [weakSelf freePlotViewMemory];
        }];
        
        [self.contentScrollView addSubview:tempPlotView];
        CGSize size = self.contentScrollView.contentSize;
        size.width +=tempPlotView.frame.size.width;
        [self.contentScrollView setContentSize:size];
        tempAudioFile = nil;
    }
    numberOfPlotView ++;
}

-(void)freePlotViewMemory
{
    tempPlotView = nil;
}

#pragma mark - Outlet Action
- (IBAction)playMusic:(id)sender {
    UIButton * btn = (UIButton *)sender;
    
    if( ![[EZOutput sharedOutput] isPlaying] ){
        if( self.eof ){
            [self.audioFile seekToFrame:0];
        }
        [EZOutput sharedOutput].outputDataSource = self;
        [[EZOutput sharedOutput] startPlayback];
        [btn setSelected:YES];
    }
    else {
        [EZOutput sharedOutput].outputDataSource = nil;
        [[EZOutput sharedOutput] stopPlayback];
        [btn setSelected:NO];
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

- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}

- (IBAction)fastForwardAction:(id)sender {
    [self addPlotView];
    currentPositionOfFile = currentPositionOfFile+ForwartTimeLength;
    if (currentPositionOfFile > totalLengthOfTheFile) {
        currentPositionOfFile = fabs(currentPositionOfFile - ForwartTimeLength);
    }
    [self seekToPostionWithValue:currentPositionOfFile];
}

- (IBAction)backForwardAction:(id)sender {
    currentPositionOfFile = currentPositionOfFile-ForwartTimeLength;
    if (currentPositionOfFile < 0) {
        currentPositionOfFile = fabs(currentPositionOfFile - ForwartTimeLength);
    }
    [self seekToPostionWithValue:currentPositionOfFile];
}


#pragma mark - AudioPlot
-(void)openFileWithFilePathURL:(NSURL*)filePathURL {
    
    // Stop playback
    [[EZOutput sharedOutput] stopPlayback];
    
    self.audioFile                 = [EZAudioFile audioFileWithURL:filePathURL];
    self.audioFile.audioFileDelegate = self;
    self.eof                       = NO;
    
    self.framePositionSlider.maximumValue = (float)self.audioFile.totalFrames;
    totalLengthOfTheFile = (float)self.audioFile.totalFrames;
    
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
                self.audioPlot.shouldFill   = YES;
                self.audioPlot.shouldMirror = YES;
            }
            //      [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
        });
    }
}

-(void)audioFile:(EZAudioFile *)audioFile
 updatedPosition:(SInt64)framePosition {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentPositionOfFile = (float)framePosition;
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
            self.currentPositionOfFile = 0.0;
        }
        AudioBufferList *bufferList = [EZAudio audioBufferList];
        BOOL eof;
        [self.audioFile readFrames:frames
                   audioBufferList:bufferList
                        bufferSize:bufferSize
                               eof:&eof];
        self.eof = eof;

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



@end
