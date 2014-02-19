//
//  MyUploadDetailViewController.m
//  ClairAudient
//
//  Created by vedon on 11/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//


#import "MyUploadDetailViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "CycleScrollView.h"
#import "Voice.h"
#import "OSHelper.h"
#import "MyUploadDetailCell.h"
#import <objc/runtime.h>
#import "HWSDK.h"
#import "PlayItemView.h"
#import "AudioPlayer.h"
#import "AudioStreamer.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "GobalMethod.h"
#import "AudioReader.h"
#import "AudioManager.h"
#import "DownloadMusicInfo.h"
#import "PersistentStore.h"
static NSString * cellIdentifier = @"cellIdentifier";
@interface MyUploadDetailViewController ()<UITableViewDataSource,UITableViewDelegate,AudioReaderDelegate,UIAlertViewDelegate>
{
    CycleScrollView * advertisementImageView;
    NSArray * descriptionArray;
    NSArray * contentArray;
    
    UIView * headerView;
    
    AudioPlayer * streamPlayer;
    CGFloat currentPlayFileLength;
    NSThread * bufferingThread;
    BOOL isDowning;
    BOOL isPlayLocalFile;
    BOOL isPlayStreamFile;
    BOOL isPlaying;
}
@property (strong ,nonatomic) UISlider * currentPlaySlider;
@property (strong ,nonatomic) UIButton * currentControllBtn;
@property (strong ,nonatomic) PlayItemView * playView;
@property (strong ,nonatomic) AudioManager * audioMng;
@property (strong ,nonatomic) AudioReader  * reader;
@end

@implementation MyUploadDetailViewController
@synthesize currentPlaySlider,playView,currentControllBtn;

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
    [self setLeftAndRightBarItem];
    [self initializationInterface];
    
    currentPlaySlider = playView.playSlider;
    currentPlaySlider.maximumValue = 1.0;
    currentPlaySlider.minimumValue = 0.0;
    currentPlaySlider.value = 0.0;
    
    self.musicInfoTable.scrollEnabled = NO;
    descriptionArray = @[@"时长",@"比特率",@"采样率",@"录入时间",@"下载次数",@"用户"];
    if (self.voiceItem) {
        contentArray  = [self objectPropertyValueToArray:self.voiceItem];
    }else
    {
        //No music info
        [self showAlertViewWithMessage:@"读取音乐文件错误"];
    }
    isDowning = NO;
    isPlayLocalFile = NO;
    isPlayStreamFile= NO;
    isPlaying = NO;
    currentPlayFileLength = 0;
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (isPlayLocalFile) {
        [self.audioMng pause];
        if ([self.reader playing]) {
            [self.reader stop];
        }
    }else
    {
        if (streamPlayer) {
            [streamPlayer stop];
            streamPlayer = nil;
        }
    }
}
#pragma mark - Private Method
-(void)initializationInterface
{
    CGRect rect = self.scrollAdView.frame;
    rect.origin.x = rect.origin.y = 0;
    
    advertisementImageView = [[CycleScrollView alloc]initWithFrame:rect cycleDirection:CycleDirectionLandscape pictures:@[[UIImage imageNamed:@"testImage.png"],[UIImage imageNamed:@"testImage.png"]] autoScroll:YES];
    [self.scrollAdView addSubview:advertisementImageView];

    [self.contentScrollView setContentSize:CGSizeMake(420, 600)];
    self.contentScrollView.scrollEnabled = YES;
    
    [self.musicInfoTable setBackgroundView:nil];
    if ([OSHelper iOS7]) {
        self.musicInfoTable.separatorInset = UIEdgeInsetsZero;
    }
    
    UINib * cellNib = [UINib nibWithNibName:@"MyUploadDetailCell" bundle:[NSBundle bundleForClass:[MyUploadDetailCell class]]];
    [self.musicInfoTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    
    playView = [[[NSBundle mainBundle]loadNibNamed:@"PlayItemView" owner:self options:nil]objectAtIndex:0];
    [playView.playBtn addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView.downloadBtn addTarget:self action:@selector(downloadMusic:) forControlEvents:UIControlEventTouchUpInside];
}

-(NSArray *)objectPropertyValueToArray:(id)object
{
    NSMutableArray * tempPropertyList = [NSMutableArray array];

    [tempPropertyList addObject:[object valueForKey:@"time"]];
    [tempPropertyList addObject:[object valueForKey:@"bit_rate"]];
    [tempPropertyList addObject:[object valueForKey:@"sampling_rate"]];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:[[object valueForKey:@"upload_time"] integerValue]];
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString * dateStr = [format stringFromDate:date];
    [tempPropertyList addObject:dateStr];
    [tempPropertyList addObject:[object valueForKey:@"download_num"]];
    [tempPropertyList addObject:[object valueForKey:@"username"]];
    return tempPropertyList;
}

-(void)playMusic:(id)sender
{
    currentControllBtn = (UIButton *)sender;
    [currentControllBtn setSelected:!currentControllBtn.selected];
    if (currentControllBtn.selected) {
        if (isPlaying) {
            [self updatePlayerStatus:currentControllBtn.selected];
        }else
        {
            [self playMusic];
        }
        
    }else
    {
        if (isPlayLocalFile) {
            [self.audioMng pause];
        }else if(isPlayStreamFile)
        {
            if (streamPlayer) {
                [streamPlayer stop];
            }
        }
    }
}

-(void)playMusic
{
    isPlaying = YES;
    __weak MyUploadDetailViewController * weakSelf = self;
    [GobalMethod getExportPath:[_voiceItem.vl_name stringByAppendingPathExtension:@"mp3"] completedBlock:^(BOOL isDownloaded, NSString *exportFilePath) {
        if (isDownloaded) {
            isPlayLocalFile = YES;
            [weakSelf startLocalPlayerWithPath:exportFilePath];
        }else
        {
            isPlayStreamFile = YES;
            [weakSelf startStreamPlayer];
        }
        
    }];
}

-(void)updatePlayerStatus:(BOOL)sign
{
    if (isPlayLocalFile) {
        if (self.audioMng) {
            [self.audioMng play];
        }
    }else if(isPlayStreamFile)
    {
        if (streamPlayer) {
            [streamPlayer play];
        }
    }
}

-(void)startLocalPlayerWithPath:(NSString *)path
{
    __weak MyUploadDetailViewController * weakSelf = self;
    weakSelf.audioMng = [AudioManager shareAudioManager];
    [weakSelf.audioMng pause];
    if ([weakSelf.reader playing]) {
        [weakSelf.reader stop];
    }
    
    NSURL *inputFileURL = [NSURL fileURLWithPath:path];
    
    //TODO:不知道是不是音乐文件问题，下面的方法读取文件长度不正确   :[
    currentPlayFileLength = [GobalMethod getMusicLength:inputFileURL];
    
    
    if (weakSelf.reader) {
        weakSelf.reader = nil;
    }
    weakSelf.reader = [[AudioReader alloc]
                       initWithAudioFileURL:inputFileURL
                       samplingRate:weakSelf.audioMng.samplingRate
                       numChannels:weakSelf.audioMng.numOutputChannels];
    currentPlayFileLength = floor([weakSelf.reader getDuration]);
    weakSelf.reader.delegate = self;
    
    //太累了，要记住一定要设置currentime = 0.0,表示开始时间   :]
    weakSelf.reader.currentTime = 0.0;
    
    
    [weakSelf.audioMng setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         [weakSelf.reader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
     }];
    [weakSelf.audioMng play];
}

-(void)startStreamPlayer
{
    if (streamPlayer) {
        [streamPlayer stop];
        streamPlayer = nil;
    }
    __weak MyUploadDetailViewController * weakSelf = self;
    streamPlayer = [[AudioPlayer alloc]init];
    [streamPlayer setBlock:^(double processOffset,BOOL isFinished)
     {
         
         if (processOffset > 0) {
             NSLog(@"%f",processOffset);
             @try {
                 if (isFinished) {
                     weakSelf.playView.playSlider.value = 0.0;
                     weakSelf.currentControllBtn.selected = NO;
                 }else
                 {
                     weakSelf.playView.playSlider.value = processOffset;
                 }
             }
             @catch (NSException *exception) {
                 NSLog(@"%@",[exception description]);
             }
             @finally {
                 ;
             }
         }
     }];
    [streamPlayer stop];
    NSURL * musciURL = [GobalMethod getMusicUrl:self.voiceItem.url];
    if (musciURL) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        streamPlayer.url = musciURL;
        [streamPlayer play];
        
        if (bufferingThread) {
            if (![bufferingThread isCancelled]) {
                [bufferingThread cancel];
            }
            bufferingThread = nil;
        }
        bufferingThread = [[NSThread alloc]initWithTarget:self selector:@selector(buffering) object:nil];
        [bufferingThread start];
    }
}

-(void)downloadMusic:(id)sender
{
    if (!isDowning) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:_voiceItem.vl_name message:@"是否下载该声音" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"确定", nil];
        [alertView show];
        alertView = nil;
    }else
    {
        [self showAlertViewWithMessage:@"正在下载"];
    }
   
}

-(void)startDownloadMusic
{
    NSURLRequest * request = [NSURLRequest requestWithURL:[GobalMethod getMusicUrl:self.voiceItem.url]];
    if (request) {
        __weak MyUploadDetailViewController * weakSelf = self;
        
        [GobalMethod getExportPath:[[GobalMethod userCurrentTimeAsFileName] stringByAppendingPathExtension:@"mp3"] completedBlock:^(BOOL isDownloaded, NSString *exportFilePath) {
            if (isDownloaded) {
                [self showAlertViewWithMessage:@"已经下载"];
            }else
            {
                isDowning = YES;
                AFURLConnectionOperation * downloadOperation = [[AFURLConnectionOperation alloc]initWithRequest:request];
                downloadOperation.completionBlock = ^()
                {
                    //下载完成
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showAlertViewWithMessage:@"下载完成"];
                        isDowning = NO;
                        CGFloat musicLength = [GobalMethod getMusicLength:[NSURL fileURLWithPath:exportFilePath]];
                        DownloadMusicInfo * info = [DownloadMusicInfo MR_createEntity];
                        info.title = weakSelf.voiceItem.vl_name;
                        info.makeTime = [GobalMethod getMakeTime];
                        info.localPath= exportFilePath;
                        info.length   = [NSString stringWithFormat:@"%0.2f",musicLength];
                        info.isFavorite = @"0";
                        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
                        
                    });
                };
                downloadOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:exportFilePath append:NO];
                [downloadOperation start];
            }
            
        }];
    }else
    {
        //文件路径错误
    }
}

-(void)buffering
{
    do {
        if ([streamPlayer.streamer isPlaying]) {
            //stop chrysanthemum
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (![bufferingThread isCancelled]) {
                    [bufferingThread cancel];
                    bufferingThread = nil;
                }
            });
        }
    } while (bufferingThread);
    
}

#pragma mark - UITableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return playView.frame.size.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyUploadDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell configureCellWithDescription:[descriptionArray objectAtIndex:indexPath.row] content:[contentArray objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!headerView) {
        headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 280, playView.frame.size.height)];
        [headerView addSubview:playView];
        [headerView setBackgroundColor:[UIColor clearColor]];
    }
    return headerView;
}

#pragma mark - AudioReader Delegate
-(void)currentFileLocation:(CGFloat)location
{
    @autoreleasepool {
        if (location >= currentPlayFileLength) {
            [self.audioMng pause];
            //        [currentPlayItemControlBtn setSelected:NO];
            //        currentSelectedItemSlider.value = 0.0f;
            self.playView.playSlider.value = 0.0;
            [self.playView.playBtn setSelected:NO];
        }else
        {
            NSLog(@"%f",location);
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat process = [[NSString stringWithFormat:@"%0.2f",location/currentPlayFileLength]floatValue];
                self.playView.playSlider.value = process;
            });
        }
    }
   
}

#pragma mark - UIAlertView Deleagte
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self startDownloadMusic];
    }
}
@end
