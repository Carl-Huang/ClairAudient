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
    
    
    CGFloat         cuttedMusicLength;
    NSString        * edittingMusicFile;

    CGFloat         totalLengthOfTheFile;
    UIView          * timeline;
    NSInteger       roundDownRectWidth;
    OutputType      currentType;
    
    NSMutableDictionary    *locationInfo;
}

@property (strong, nonatomic) EZAudioPlotGL *audioPlot;
@property (strong, nonatomic) EZAudioPlot   * tempPlotView ;
@property (strong, nonatomic) UIView        *timeLabelView;
@property (strong, nonatomic) UIView        *maskView;
@property (strong, nonatomic) UIView        *timeLineView;
@property (strong, nonatomic) TrachBtn      *startBtn;
@property (strong, nonatomic) TrachBtn      *endBtn;
@property (strong, nonatomic) UIScrollView *contentScrollView;

@property (assign ,nonatomic) CGFloat currentPositionOfFile;
@property (assign ,nonatomic) CGFloat currentPositionOfTimeLine;
@property (nonatomic, strong) EZAudioFile *audioFile;
@property (nonatomic, assign) BOOL eof;
@property (assign ,nonatomic) CGFloat   musicLength;
@property (assign ,nonatomic) CGFloat   waveLength;
@property (assign ,nonatomic) CGFloat   startLocation;
@property (assign ,nonatomic) CGFloat   endLocation;
@property (assign ,nonatomic) CGFloat   cuttedMusicLength;
@property (assign ,nonatomic) NSInteger snapShotImageCount;
@property (assign ,nonatomic) CGRect    originalRect;
@property (assign ,nonatomic) NSInteger currentPage;
@end

@implementation AudioPlotView
@synthesize currentPositionOfFile,currentPositionOfTimeLine;
@synthesize musicLength,waveLength,startLocation,endLocation,cuttedMusicLength,snapShotImage,tempPlotView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setupAudioPlotViewWitnNimber:(NSInteger)number type:(OutputType)type musicPath:(NSString *)path withCompletedBlock:(void (^)(BOOL isFinish))block
{

    
#if TARGET_IPHONE_SIMULATOR
    isSimulator = YES;
#else
    isSimulator = NO;
#endif
    currentType             = type;
    self.snapShotImageCount = number;
    self.currentPage        = 0;
    
    CGRect rect = self.frame;
    roundDownRectWidth = floor(self.frame.size.width);
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
    self.timeLabelView = [[UIView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width*number, 30)];
    [self.timeLabelView setBackgroundColor:[UIColor clearColor]];
    
    //遮罩
    self.maskView = [[UIView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * number, rect.size.height)];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0.5;
    
    
    //更新点击，更新时间
    self.timeLineView = [[UIView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * number, rect.size.height)];
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(seekToPosition:)];
    [self.timeLineView addGestureRecognizer:tapGesture];
    tapGesture = nil;
    self.timeLineView.backgroundColor = [UIColor clearColor];
    
    [self.contentScrollView addSubview:self.audioPlot];
    [self.contentScrollView addSubview:self.maskView];
    [self.contentScrollView addSubview:self.timeLineView];
    [self.contentScrollView addSubview:self.timeLabelView];
    if ([path length]) {
        edittingMusicFile = path;
    }else
    {
        edittingMusicFile = DefaultTextMusicFile;
    }
    
    musicLength = [self getMusicLength:[NSURL fileURLWithPath:edittingMusicFile]]*number;
    startLocation = 0.0f;
    endLocation = rect.size.width * number;
    
    
    NSURL * fileURL = [NSURL fileURLWithPath:edittingMusicFile];
    self.audioFile                 = [EZAudioFile audioFileWithURL:fileURL];
    self.audioFile.audioFileDelegate = self;
    self.eof                       = NO;
    
    totalLengthOfTheFile = (float)self.audioFile.totalFrames;
    
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    self.audioPlot.shouldFill      = YES;
    self.audioPlot.shouldMirror    = YES;
    
    [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
        [self.audioPlot updateBuffer:waveformData withBufferSize:length];
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_group_t group = dispatch_group_create();

            dispatch_group_async(group,dispatch_get_main_queue(), ^ {
                if (number > 1) {
                    [self addPlotViewWithNumber:number completed:^(BOOL isCompleted) {
                        if (isCompleted) {
                            block(YES);
                        }
                    }];
                }else
                {
                    block (YES);
                }
            });
            dispatch_group_notify(group,dispatch_get_main_queue(), ^ {
                //TODO: 如何保证嵌套的block 完成后执行到这里
//                block(YES);
            });
        });
        
    }];
    
    CGFloat slideNum = 6.0 * number;
    CGFloat timeSlice = musicLength / slideNum;
    NSInteger pageOffset = 0;
    for (int i =0; i< slideNum; i++) {
        NSInteger page = i;
        
        if (i != 0) {
            page = i % 6;
            if (page == 0) {
                pageOffset ++;
            }
        }else
        {
            page = 0;
        }
        UILabel * label     = [[UILabel alloc]initWithFrame:CGRectMake((50)*page+rect.size.width * pageOffset, 5, 50, 30)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor     = [UIColor whiteColor];
        label.font          = [UIFont systemFontOfSize:12];
        label.text          = [NSString stringWithFormat:@"%0.2f",timeSlice*i];
        [self.timeLabelView addSubview:label];
        label               = nil;
    }
    
    waveLength = rect.size.width * number;
    //startBtn ,endBtn
    self.startBtn = [[TrachBtn alloc]initWithFrame:CGRectMake(2.5, 10, 40, 30)];
    self.startBtn.criticalValue = rect.size.width * number;
    [self.startBtn setBackgroundImage:[UIImage imageNamed:@"sliderStart.png"] forState:UIControlStateNormal];
    
    self.endBtn   = [[TrachBtn alloc]initWithFrame:CGRectMake(rect.size.width*number, rect.size.height -30, 40, 30)];
    self.endBtn.criticalValue = rect.size.width * number;
    [self.endBtn setBackgroundImage:[UIImage imageNamed:@"sliderEnd.png"] forState:UIControlStateNormal];

    [self.contentScrollView addSubview:self.startBtn];
    [self.contentScrollView addSubview:self.endBtn];
    self.startBtn.locationView  = self.audioPlot;
    self.endBtn.locationView    = self.audioPlot;
    __weak AudioPlotView * weakSelf = self;
    [self.startBtn setBlock:^(CGFloat offset,CGFloat currentOffsetX)
     {
         CGRect rect         = weakSelf.maskView.frame;
         CGFloat offsetWidth = weakSelf.endBtn.frame.origin.x -currentOffsetX;
         if (offsetWidth < 0) {
             rect.size.width = 0;
         }else
         {
             rect.size.width     = offsetWidth;
         }
         rect.origin.x           = offset + weakSelf.startBtn.frame.size.width / 2.0;
         weakSelf.maskView.frame = rect;
         weakSelf.startLocation  = offset;
     }];
    
    [self.endBtn setBlock:^(CGFloat offset,CGFloat currentOffsetX)
     {
         CGRect rect        = weakSelf.maskView.frame;
         CGFloat offsetWidth = currentOffsetX - weakSelf.startBtn.frame.origin.x ;
         if (offsetWidth < 0) {
             rect.size.width = 0;
         }else
         {
             rect.size.width = offsetWidth;
         }
         weakSelf.maskView.frame= rect;
         weakSelf.endLocation = offset;
     }];

    
    timeline =  [[UIView alloc]initWithFrame:CGRectMake(PlotViewOffset, 0, 0.5, rect.size.height)];
    [timeline setBackgroundColor:[UIColor yellowColor]];
    [self addObserver:self forKeyPath:@"currentPositionOfFile" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"startLocation" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"endLocation" options:NSKeyValueObservingOptionNew context:NULL];
    
    
    locationInfo = [NSMutableDictionary dictionary];
    [locationInfo setObject:[NSNumber numberWithFloat:0.0] forKey:@"startLocation"];
    [locationInfo setObject:[NSNumber numberWithFloat:musicLength] forKey:@"endLocation"];
    
    
    [self.contentScrollView addSubview:timeline];
    currentPositionOfFile = 0.0f;
    currentPositionOfTimeLine = 0.0f;
    [self addSubview:self.contentScrollView];
    
    
}

-(void)dealloc
{
    [self stop];
    [self removeObserver:self forKeyPath:@"currentPositionOfFile"];
    [self removeObserver:self forKeyPath:@"startLocation"];
    [self removeObserver:self forKeyPath:@"endLocation"];
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

-(void)fastForward:(NSInteger)sec
{
    CGFloat minute = (CGFloat)sec / 60.0f;
    self.currentPositionOfFile = minute / musicLength * totalLengthOfTheFile + self.currentPositionOfFile;
    [self seekToPostionWithValue:currentPositionOfFile];
}

-(void)backForward:(NSInteger)sec
{
    CGFloat minute = (CGFloat)sec / 60.0f;
    self.currentPositionOfFile =  self.currentPositionOfFile - minute / musicLength * totalLengthOfTheFile;
    if (self.currentPositionOfFile < 0) {
        self.currentPositionOfFile  = 0;
    }
    [self seekToPostionWithValue:currentPositionOfFile];
}

-(CGFloat)getMusicLength
{
    return musicLength;
}

-(NSDictionary *)getCropMusicLocationInfo
{
    NSDictionary * tempLocation = @{@"startLocation": [NSNumber numberWithFloat:self.startLocation],@"endLocation":[NSNumber numberWithFloat:self.endLocation]};
    return tempLocation;
}
#pragma mark - Private Method
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentPositionOfFile"]) {
        [self updateTimeLinePosition:currentPositionOfTimeLine];
    }else if ([keyPath isEqualToString:@"startLocation"])
    {
        if (self.locationBlock) {
            CGFloat time = [self getTimeFromRelativePosition:self.startLocation];
            [locationInfo setObject:[NSNumber numberWithFloat:time]forKey:@"startLocation"];
            self.locationBlock(locationInfo);
        }
    }else if ([keyPath isEqualToString:@"endLocation"])
    {
        if (self.locationBlock) {
            CGFloat time = [self getTimeFromRelativePosition:self.endLocation];
            [locationInfo setObject:[NSNumber numberWithFloat:time]forKey:@"endLocation"];
            self.locationBlock(locationInfo);
        }
    }
}

//获取音乐长度
-(CGFloat)getMusicLength:(NSURL *)url
{
    AVURLAsset* audioAsset =[AVURLAsset assetWithURL:url];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration)/60.0f;
    return audioDurationSeconds;
}

-(void)seekToPosition:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self.timeLineView];
    NSLog(@"%f",point.x);

    NSInteger roundDownPosition = floor(point.x);
    NSInteger relativePosition = roundDownPosition % roundDownRectWidth;
    
    CGFloat param1 = (CGFloat)relativePosition;
    CGFloat parma2 = (CGFloat)roundDownRectWidth;
    CGFloat position        = param1/parma2 * totalLengthOfTheFile;
    NSLog(@"position :%f totalLengthOfTheFile:%f ",position,totalLengthOfTheFile);
    
    
//    CGFloat position        = point.x / waveLength * totalLengthOfTheFile;
//    NSLog(@"position :%f totalLengthOfTheFile:%f ",position,totalLengthOfTheFile);
    self.currentPage = roundDownPosition / roundDownRectWidth;
    self.currentPositionOfTimeLine  = point.x;
    self.currentPositionOfFile      = position;
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

-(void)addPlotViewWithNumber:(NSInteger)count completed:(void (^)(BOOL isCompleted))completedBlock
{
    @autoreleasepool {
        CGRect rect = self.audioPlot.frame;
        rect.origin.x = rect.size.width * count +PlotViewOffset;
        
        tempPlotView = [[EZAudioPlot alloc]initWithFrame:rect];
        tempPlotView.backgroundColor = PlotViewBackgroundColor;
        tempPlotView.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        tempPlotView.plotType        = EZPlotTypeBuffer;
        tempPlotView.shouldFill      = YES;
        tempPlotView.shouldMirror    = YES;
        self.eof                     = NO;
        
        EZAudioFile *tempAudioFile  = [EZAudioFile audioFileWithURL:[NSURL fileURLWithPath:edittingMusicFile]];
        
        
        // Plot the whole waveform
        tempPlotView.plotType        = EZPlotTypeBuffer;
        tempPlotView.shouldFill      = YES;
        tempPlotView.shouldMirror    = YES;
        [tempPlotView setNeedsDisplay];
        __weak AudioPlotView * weakSelf = self;
        [tempAudioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
            [tempPlotView updateBuffer:waveformData withBufferSize:length];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.snapShotImage = [[UIImageView alloc]initWithImage:tempPlotView.snapShotImage];
                [weakSelf configureSnapShotImage:count completed:^(BOOL isCompleted) {
                    if (isCompleted) {
                        completedBlock(YES);
                    }
                }];
            });
            
        }];
        
        [self.contentScrollView addSubview:tempPlotView];
        tempPlotView.alpha = 0.0;
        tempAudioFile = nil;
    }
}

-(void)configureSnapShotImage:(NSInteger)number completed:(void (^)(BOOL isCompleted))completedBlock
{
    tempPlotView = nil;
    CGRect plotViewRect = self.audioPlot.frame;
    
    for (int i= 1; i< number; i++) {
        plotViewRect.origin.x = plotViewRect.size.width * i + PlotViewOffset;
        UIImageView * tempImage = [[UIImageView alloc]initWithImage:self.snapShotImage.image];
        [tempImage setFrame:plotViewRect];
        [self.contentScrollView addSubview:tempImage];
        [self.contentScrollView sendSubviewToBack:tempImage];
        tempImage = nil;
    }
    completedBlock(YES);
}

-(CGFloat)getTimeFromRelativePosition:(CGFloat)sec
{
    CGFloat relativePosition = sec/(roundDownRectWidth * self.snapShotImageCount);
    CGFloat minute = relativePosition * musicLength;
    return minute;
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
        SInt64  framePos = framePosition;
        if (framePosition > totalLengthOfTheFile) {
            framePos = totalLengthOfTheFile;
        }
//        NSInteger roundDownPosition = floor(self.currentPositionOfFile);
//        NSInteger relativePosition = roundDownPosition / roundDownRectWidth;
//        CGFloat param1 = (CGFloat)relativePosition * roundDownRectWidth;
//        CGFloat fileOffset = (float)framePos /totalLengthOfTheFile * roundDownRectWidth;
//        
//        CGFloat tempCurrentPosition = fileOffset + param1;
//        if (tempCurrentPosition > roundDownRectWidth) {
//            tempCurrentPosition = roundDownRectWidth;
//        }
//        self.currentPositionOfFile = tempCurrentPosition;
//        NSLog(@"%f",self.currentPositionOfFile);
        if (self.currentPositionOfFile > totalLengthOfTheFile) {
            self.currentPositionOfFile = totalLengthOfTheFile;
        }
        
        //获取已经播放文件的位置
        NSInteger  tempOffset = floor(self.currentPositionOfFile)/totalLengthOfTheFile * roundDownRectWidth;
        self.currentPositionOfTimeLine = self.currentPage * roundDownRectWidth + tempOffset;
        
        
        self.currentPositionOfFile = framePos;
       
    });
}

#pragma mark - EZOutputDataSource
-(AudioBufferList *)output:(EZOutput *)output
 needsBufferListWithFrames:(UInt32)frames
            withBufferSize:(UInt32 *)bufferSize {
    
    if( self.audioFile ){
        if (self.currentPositionOfTimeLine >= self.endLocation||self.eof ) {
            //获取位置在音乐文件中的相对位置
//            NSInteger roundDownPosition = floor(self.currentPositionOfTimeLine);
//            NSInteger relativePosition = roundDownPosition % roundDownRectWidth;
//            CGFloat param1      = (CGFloat)relativePosition;
//            CGFloat parma2      = (CGFloat)roundDownRectWidth;
//            CGFloat position    = param1/parma2 * totalLengthOfTheFile;
            CGFloat position    = self.startLocation/roundDownRectWidth * totalLengthOfTheFile;
            
            [self.audioFile seekToFrame:position];
            self.eof = NO;
            
            //更新当前时间轴的位置
            self.currentPositionOfTimeLine = self.currentPage * roundDownRectWidth + self.currentPositionOfTimeLine;
            
            //判断时间轴的x 坐标
            self.currentPage +=1;
            if (self.currentPositionOfTimeLine >= self.endLocation) {
                self.currentPositionOfTimeLine  = self.startLocation;
                self.currentPage = self.startLocation/roundDownRectWidth;
            }
            
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
