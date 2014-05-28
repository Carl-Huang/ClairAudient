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
#import <AVFoundation/AVFoundation.h>
#import "MusicCutter.h"
#import "MBProgressHUD.h"
#import "MixingEffectViewController.h"
#import "AudioPlotView.h"
#import "EditMusicInfo.h"
#import "MusicMixerOutput.h"
#import "GobalMethod.h"
#import "CopyMusicView.h"
#import "AppDelegate.h"
#import "SoundMakerView.h"
@interface MixingViewController ()

{
    BOOL isSimulator;
    BOOL isCopyMusic;
    CGFloat     cuttedMusicLength;
    NSString    * edittingMusicFile;
    AudioPlotView * plotView;
    
    MBProgressHUD * progressView;
    NSString * currentEditedFile;
}

@property (assign ,nonatomic)CGFloat currentPositionOfFile;
@property (nonatomic,assign) BOOL eof;
@end

@implementation MixingViewController
@synthesize currentPositionOfFile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isUseSoundMaker =  NO;
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
    if (isSimulator) {
        edittingMusicFile = testFile;
    }else
    {
        edittingMusicFile = [self.musicInfo valueForKey:@"musicURL"];;
    }
    edittingMusicFile = [self.musicInfo valueForKey:@"musicURL"];;
    NSDictionary * currentEditMusicInfo = @{@"musicURL": edittingMusicFile,@"count":@"1"};
    [[NSUserDefaults standardUserDefaults]setObject:currentEditMusicInfo forKey:@"currentEditingMusic"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    __weak MixingViewController * weakSelf =self;
    CGRect rect = CGRectMake(0, 60, 320, 245);
    if ([OSHelper iOS7]) {
        rect.origin.y +=20;
    }
    
    
    plotView = [[AudioPlotView alloc]initWithFrame:rect];
    [plotView setupAudioPlotViewWitnNimber:1 type:OutputTypeDefautl musicPath:edittingMusicFile withCompletedBlock:^(BOOL isFinish) {
        if (isFinish) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            });
        }
    }];
    
    [plotView setLocationBlock:^(NSDictionary * locationInfo)
     {
//         NSLog(@"%@",locationInfo);
         [weakSelf updateInterfaceWithInfo:locationInfo];
     }];
    self.endTime.text   = [NSString stringWithFormat:@"%0.2f",[plotView getMusicLength]];
    self.cutLength.text = self.endTime.text;
    [self.view addSubview:plotView];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    isCopyMusic = NO;

    [_bianyinBtn setHidden:!_isUseSoundMaker];
    [_editControlBtn setHidden:_isUseSoundMaker];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updatePlayBtnStatus) name:PlotViewDidStartPlay object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if ([plotView isPlaying]) {
        [plotView stop];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    NSLog(@"Plotview deallic");
    if (plotView) {
        plotView = nil;
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Private Method
-(void)updatePlayBtnStatus
{
    [self.playBtn setSelected:YES];
}

-(void)updateInterfaceWithInfo:(NSDictionary*)info
{
    @autoreleasepool {
        NSNumber * start = [info valueForKey:@"startLocation"];
        NSNumber * end   = [info valueForKey:@"endLocation"];
        self.startTime.text = [NSString stringWithFormat:@"%0.2f",start.floatValue];
        self.endTime.text   = [NSString stringWithFormat:@"%0.2f",end.floatValue];
        
        CGFloat cutLength = end.floatValue - start.floatValue;
        self.cutLength.text = [NSString stringWithFormat:@"%0.2f",cutLength];
    }
}

-(NSString *)getTimeAsFileName
{
    NSDate * date = [NSDate date];
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMddhhmmss"];
    NSString * tempFileName = [format stringFromDate:date];
    return tempFileName;
}

-(NSString *)getMakeTime;
{
    NSDate * currentDate = [NSDate date];
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyyMMddhhmmss"];
    NSString * dateStr = [format stringFromDate:currentDate];
    return dateStr;
}

-(CGFloat)convertMinuteToSecond:(CGFloat)time
{
    NSInteger minute = floor(time);
    CGFloat   second = time - minute;
    CGFloat totalTime = minute * 60 + second;
    return totalTime;
}

-(void)newPlotViewWithNumber:(NSInteger )number
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [plotView configureSnapShotImage:number completed:^(BOOL isCompleted) {
            ;
        }];
    });
  
}

-(void)synthesizeNewAudioFileWithNumber:(NSInteger)copyNumber
{
    __weak MixingViewController * weakSelf = self;
    
    
    currentEditedFile = [GobalMethod getDocumentPath:@"tempCopyFile.mov"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [MusicMixerOutput appendAudioFile:edittingMusicFile toFile:edittingMusicFile compositionPath:currentEditedFile compositionTimes:copyNumber withCompletedBlock:^(NSError *error, BOOL isFinish) {
            if (isFinish) {
                
                //更改文件的格式
                NSFileManager *manage   = [NSFileManager defaultManager];
                NSString * convertedFilePath = [NSString stringWithString:currentEditedFile];
                NSString *mp3Path       = [[convertedFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp3"];
                NSError *error = nil;
                [manage moveItemAtPath:currentEditedFile toPath:mp3Path error:&error];
                currentEditedFile = nil;
                
                //建立新的plotView
                [weakSelf newPlotViewWithNumber:copyNumber];
            }
        }];
    });
}

#pragma mark - Outlet Action
- (IBAction)playMusic:(id)sender {
    UIButton * btn = sender;
    
    if (![plotView isPlaying]) {
        [plotView play];
        [btn setSelected:NO];
    }else
    {
        [btn setSelected:YES];
        [plotView pause];
    }
    
 }

- (IBAction)startCutting:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak MixingViewController * weakSelf = self;
    
    // * Synthesis the music according to the length of the file
    // * Crop the music
    NSString * tempFileName = [self getTimeAsFileName];
    CGFloat musicLength = self.endTime.text.floatValue  - self.startTime.text.floatValue;
    NSString * sourceFilePath = nil;
    if (isCopyMusic) {
        sourceFilePath = currentEditedFile;
    }else
    {
        sourceFilePath = edittingMusicFile;
    }
    
    if (tempFileName) {
        tempFileName = [tempFileName stringByAppendingPathExtension:@"mov"];
        [MusicCutter cropMusic:sourceFilePath exportFileName:tempFileName withStartTime:self.startTime.text.floatValue*60 endTime:self.endTime.text.floatValue*60 withCompletedBlock:^(AVAssetExportSessionStatus status, NSError *error,NSString * localPath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (status == AVAssetExportSessionStatusCompleted) {
                    //保存信息到数据库
                    EditMusicInfo * info    = [EditMusicInfo MR_createEntity];
                    info.title              = [weakSelf.musicInfo valueForKey:@"Title"];;
                    info.artist             = [weakSelf.musicInfo valueForKey:@"Artist"];
                    info.makeTime           = [self getMakeTime];
                    info.localPath      = localPath;
                    info.length             = [NSString stringWithFormat:@"%0.2f",[self convertMinuteToSecond:musicLength]];
                    [[NSManagedObjectContext MR_defaultContext]MR_saveOnlySelfAndWait];
                    
                    //删除临时数据
                    NSError * error = nil;
                    [[NSFileManager defaultManager]removeItemAtPath:currentEditedFile error:&error];
                    
                    
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    [self showAlertViewWithMessage:@"裁剪成功"];
                }else
                {
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    [self showAlertViewWithMessage:@"裁剪失败"];
                }
                
               
            });
            
        }];
    }
   
}

- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}

- (IBAction)fastForwardAction:(id)sender {
    //快进10秒
    [plotView fastForward:10];
}

- (IBAction)backForwardAction:(id)sender {
    //后退10秒
    [plotView backForward:10];
}

- (IBAction)copyMusicAction:(id)sender {
    
     AppDelegate * myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (_isUseSoundMaker) {
        SoundMakerView * makerView = [[[NSBundle mainBundle]loadNibNamed:@"SoundMakerView" owner:self options:nil]objectAtIndex:0];
        makerView.audioFilePath = edittingMusicFile;
        [myDelegate.window addSubview:makerView];
        makerView = nil;
    }else
    {
        CopyMusicView * copyView = [[[NSBundle mainBundle]loadNibNamed:@"CopyMusicView" owner:self options:nil]objectAtIndex:0];
        [copyView initalizationContainerViewContent];
        __weak MixingViewController * weakSelf = self;
        [copyView setBlock:^(NSInteger number)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf synthesizeNewAudioFileWithNumber:number];
             });
         }];
       
        [myDelegate.window addSubview:copyView];
        copyView = nil;
    }
    
    
    
}

- (IBAction)addMixingMusicAction:(id)sender {
    
    MixingEffectViewController * viewController = [[MixingEffectViewController alloc]initWithNibName:@"MixingEffectViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
}



@end
