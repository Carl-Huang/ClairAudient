//
//  AudioPlotView.m
//  ClairAudient
//
//  Created by vedon on 24/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#define DefaultTextMusicFile [[NSBundle mainBundle] pathForResource:@"权利游戏" ofType:@"mp3"]
#define ForwartTimeLength 200000
#define PlotViewBackgroundColor [UIColor colorWithRed: 0.6 green: 0.6 blue: 0.6  alpha: 1.0];
#define PlotViewOffset 20

#import "AudioPlotView.h"
#import "EZOutput.h"
#import "EZOutputHelper.h"
#import "EZAudioFile.h"
#import "EZAudio.h"
#import "EZAudioPlot.h"
#import "TrachBtn.h"
#import <AVFoundation/AVFoundation.h>
#import "MusicCutter.h"
#import "MBProgressHUD.h"


@interface AudioPlotView ()<EZAudioFileDelegate,EZOutputDataSource>
{
    BOOL isSimulator;
    
    
    CGFloat     cuttedMusicLength;
    NSString    * edittingMusicFile;

    CGFloat totalLengthOfTheFile;
    UIView * timeline;
    
    EZAudioPlot * tempPlotView ;
    NSInteger  numberOfPlotView;
    OutputType  currentType;
}

@property (strong, nonatomic) EZAudioPlotGL *audioPlot;
@property (strong, nonatomic) UIView *timeLabelView;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UIView *timeLineView;
@property (strong, nonatomic) TrachBtn *startBtn;
@property (strong, nonatomic) TrachBtn *endBtn;
@property (strong, nonatomic) UIScrollView *contentScrollView;

@property (assign ,nonatomic) CGFloat currentPositionOfFile;
@property (nonatomic, strong) EZAudioFile *audioFile;
@property (nonatomic, assign) BOOL eof;
@property (assign ,nonatomic) CGFloat   musicLength;
@property (assign ,nonatomic) CGFloat   waveLength;
@property (assign ,nonatomic) CGFloat startLocation;
@property (assign ,nonatomic) CGFloat endLocation;
@property (assign ,nonatomic) CGFloat cuttedMusicLength;
@end

@implementation AudioPlotView
@synthesize currentPositionOfFile;
@synthesize musicLength,waveLength,startLocation,endLocation,cuttedMusicLength;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setupAudioPlotViewWitnNimber:(NSInteger)number type:(OutputType)type withCompletedBlock:(void (^)(BOOL isFinish))block;
{

#if TARGET_IPHONE_SIMULATOR
    isSimulator = YES;
#else
    isSimulator = NO;
#endif
    currentType = type;
    CGRect rect = self.frame;
    rect.origin.y = 0;
    rect.origin.x = 0;
    
    //设置contentScrollView
    self.contentScrollView = [[UIScrollView alloc]initWithFrame:rect];
    [self.contentScrollView setContentSize:CGSizeMake(60 + number*rect.size.width, self.contentScrollView.frame.size.height)];
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.scrollEnabled = YES;
    
    CGRect scrollViewRect = self.contentScrollView.frame;
    scrollViewRect.origin.x = rect.origin.x+PlotViewOffset;
    self.contentScrollView.backgroundColor = [UIColor clearColor];
    [self.contentScrollView scrollRectToVisible:scrollViewRect animated:YES];
    
    rect.origin.x = PlotViewOffset/2;
    self.audioPlot = [[EZAudioPlotGL alloc]initWithFrame:rect];
    self.audioPlot.backgroundColor = PlotViewBackgroundColor
    self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    self.audioPlot.shouldFill      = YES;
    self.audioPlot.shouldMirror    = YES;
    rect.origin.x = PlotViewOffset;
    
    
    //时间表
    self.timeLabelView = [[UIView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width*number, 40)];
    
    //遮罩
    self.maskView = [[UIView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * number, rect.size.height)];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0.5;
    
    
    //更新点击，更新时间
    self.timeLineView = [[UIView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * number, rect.size.height)];
    self.timeLineView.backgroundColor = [UIColor clearColor];
    
    [self.contentScrollView addSubview:self.audioPlot];
    [self.contentScrollView addSubview:self.maskView];
    [self.contentScrollView addSubview:self.timeLineView];
    [self.contentScrollView addSubview:self.timeLabelView];
    
    if (isSimulator) {
        edittingMusicFile = DefaultTextMusicFile;
    }else
    {
        edittingMusicFile = [self.musicInfo valueForKey:@"musicURL"];;
    }
    NSURL * fileURL = [NSURL fileURLWithPath:edittingMusicFile];
    // Stop playback
    self.audioFile                 = [EZAudioFile audioFileWithURL:fileURL];
    self.audioFile.audioFileDelegate = self;
    self.eof                       = NO;
    
    totalLengthOfTheFile = (float)self.audioFile.totalFrames;
    
    // Plot the whole waveform
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    self.audioPlot.shouldFill      = YES;
    self.audioPlot.shouldMirror    = YES;
    
    [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
        [self.audioPlot updateBuffer:waveformData withBufferSize:length];
        block(YES);
    }];
    
    
    waveLength = rect.size.width * number;
    //startBtn ,endBtn
    self.startBtn = [[TrachBtn alloc]initWithFrame:CGRectMake(2.5, 10, 40, 30)];
    [self.startBtn setBackgroundImage:[UIImage imageNamed:@"sliderStart.png"] forState:UIControlStateNormal];
    
    self.endBtn   = [[TrachBtn alloc]initWithFrame:CGRectMake(rect.size.width-2.5, rect.size.height-30, 40, 30)];
    [self.endBtn setBackgroundImage:[UIImage imageNamed:@"sliderEnd.png"] forState:UIControlStateNormal];

    [self.contentScrollView addSubview:self.startBtn];
    [self.contentScrollView addSubview:self.endBtn];
    self.startBtn.locationView  = self.audioPlot;
    self.endBtn.locationView    = self.audioPlot;
    __weak AudioPlotView * weakSelf = self;
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
         
         CGFloat start = (currentOffsetX * weakSelf.musicLength)/weakSelf.waveLength;
         weakSelf.startLocation = start;
         weakSelf.cuttedMusicLength = weakSelf.endLocation - weakSelf.startLocation;

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
         
         CGFloat end = currentOffsetX/weakSelf.waveLength * weakSelf.musicLength;
         weakSelf.endLocation = end;
         weakSelf.cuttedMusicLength = weakSelf.endLocation - weakSelf.startLocation;
     }];
    
    
    
    
    musicLength = [self getMusicLength:[NSURL fileURLWithPath:edittingMusicFile]]*number;
    startLocation = 0.0f;
    endLocation = musicLength;
    
    
    
    CGFloat slideNum = 6.0 * number;
    CGFloat timeSlice = musicLength / slideNum;
    for (int i =0; i< 6; i++) {
        UILabel * label     = [[UILabel alloc]initWithFrame:CGRectMake(10+(50)*i, 5, 50, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor     = [UIColor whiteColor];
        label.font          = [UIFont systemFontOfSize:12];
        label.text          = [NSString stringWithFormat:@"%0.2f",timeSlice*i];
        [self.timeLabelView addSubview:label];
        label               = nil;
    }
    
    
    timeline =  [[UIView alloc]initWithFrame:CGRectMake(PlotViewOffset, 0, 1, rect.size.height)];
    [timeline setBackgroundColor:[UIColor yellowColor]];
    [self addObserver:self forKeyPath:@"currentPositionOfFile" options:NSKeyValueObservingOptionNew context:NULL];
    
    
    [self.contentScrollView addSubview:timeline];
    currentPositionOfFile = 0.0f;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(seekToPosition:)];
    [self.timeLineView addGestureRecognizer:tapGesture];
    tapGesture = nil;
    
    numberOfPlotView = 1;
    [self addSubview:self.contentScrollView];
    
    for (int i =0 ; i< number; i++) {
        [self addPlotViewWithNumber:i];
    }
}

-(void)dealloc
{
    [self stop];
}

#pragma mark - Public method
-(void)play
{
    if (currentType == OutputTypeDefautl) {
        if(![[EZOutput sharedOutput] isPlaying] ){
            if( self.eof ){
                [self.audioFile seekToFrame:0];
            }
            [EZOutput sharedOutput].outputDataSource = self;
            [[EZOutput sharedOutput] startPlayback];
        }
    }else
    {
        if(![[EZOutputHelper sharedOutput] isPlaying] ){
            if( self.eof ){
                [self.audioFile seekToFrame:0];
            }
            [EZOutputHelper sharedOutput].outputDataSource = self;
            [[EZOutputHelper sharedOutput] startPlayback];
        }
    }
   
}

-(void)pause
{
    if (currentType == OutputTypeDefautl) {
        [EZOutput sharedOutput].outputDataSource = nil;
        [[EZOutput sharedOutput] stopPlayback];
    }else
    {
        [EZOutputHelper sharedOutput].outputDataSource = nil;
        [[EZOutputHelper sharedOutput] stopPlayback];
    }
}

-(void)stop
{
    if (currentType == OutputTypeDefautl) {
        [EZOutput sharedOutput].outputDataSource = nil;
        [[EZOutput sharedOutput] stopPlayback];
    }else
    {
        [EZOutputHelper sharedOutput].outputDataSource = nil;
        [[EZOutputHelper sharedOutput] stopPlayback];
    }
}

#pragma mark - Private Method
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentPositionOfFile"]) {
        CGFloat position = currentPositionOfFile/totalLengthOfTheFile * 320;
        [self updateTimeLinePosition:position];
    }
}

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

-(void)addPlotViewWithNumber:(NSInteger)count
{
    count +=1;
    @autoreleasepool {
        CGRect rect = self.audioPlot.frame;
        rect.origin.x = rect.size.width * count +PlotViewOffset;
        
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
        
        __weak AudioPlotView * weakSelf = self;
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



#pragma mark - AudioPlot
-(void)openFileWithFilePathURL:(NSURL*)filePathURL {
    
    // Stop playback
    [[EZOutput sharedOutput] stopPlayback];
    self.audioFile                 = [EZAudioFile audioFileWithURL:filePathURL];
    self.audioFile.audioFileDelegate = self;
    self.eof                       = NO;
    
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
    
    if (currentType == OutputTypeDefautl) {
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

    }else
    {
        if( [EZOutputHelper sharedOutput].isPlaying ){
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
