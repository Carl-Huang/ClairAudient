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
#import "DownloadMusicInfo.h"
#import "PersistentStore.h"
#import "AppDelegate.h"
#import "HttpService.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface MyUploadDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    CycleScrollView * autoScrollView;
    NSArray * descriptionArray;
    NSArray * contentArray;
    
    UIView * headerView;
    
    AudioPlayer * streamPlayer;
    NSString * currentPlayFileLength;
    NSThread * bufferingThread;
    BOOL isDowning;
    BOOL isPlayLocalFile;
    BOOL isPlayStreamFile;
    BOOL isPlaying;
    
    AppDelegate * myDelegate;
    NSArray * upperDataSource;
}
@property (strong ,nonatomic) UISlider * currentPlaySlider;
@property (strong ,nonatomic) UIButton * currentControllBtn;
@property (strong ,nonatomic) PlayItemView * playView;
@property (strong ,nonatomic) NSMutableArray * productImages;
@end

@implementation MyUploadDetailViewController
@synthesize currentPlaySlider,playView,currentControllBtn,productImages;

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
    currentPlayFileLength = nil;
    myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    __weak MyUploadDetailViewController * weakSelf = self;
//    [GobalMethod getExportPath:[_voiceItem.vl_name stringByAppendingPathExtension:@"mp3"] completedBlock:^(BOOL isDownloaded, NSString *exportFilePath) {
//        if (isDownloaded) {
//            isPlayLocalFile = YES;
//            [weakSelf startLocalPlayerWithPath:exportFilePath];
//        }else
//        {
//            isPlayStreamFile = YES;
//            [weakSelf startStreamPlayer];
//        }
//    }];
    
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillDisappear:(BOOL)animated
{
    if ([myDelegate isPlaying]) {
        [myDelegate pause];
    }
    if (streamPlayer) {
        [streamPlayer stop];
    }
    streamPlayer = nil;
    
    [autoScrollView stopTimer];
    autoScrollView = nil;
    productImages = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Private Method
-(void)initializationInterface
{
    CGRect rect = self.scrollAdView.bounds;

    autoScrollView = [[CycleScrollView alloc] initWithFrame:rect animationDuration:2];
    autoScrollView.backgroundColor = [UIColor clearColor];
    productImages = [NSMutableArray array];
    //Placehoder Image
    if ([productImages count] == 0) {

        UIImageView * tempImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"first_2.png"]];
        [productImages addObject:tempImageView];
        tempImageView = nil;
    }
    __weak MyUploadDetailViewController * weakSelf = self;
    autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return weakSelf.productImages[pageIndex];
    };
    autoScrollView.totalPagesCount = ^NSInteger(void){
        return [weakSelf.productImages count];
    };
    autoScrollView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"点击了第%ld个",(long)pageIndex);
    };
    [self.scrollAdView addSubview:autoScrollView];
    

    [self.contentScrollView setContentSize:CGSizeMake(320, 800)];
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
    playView.playTimeLable.text = @"";
    

    [[HttpService sharedInstance]getMusicImageWithParams:@{@"vltId": @"2"} completionBlock:^(id object) {
        for (int j = 0;j < [object count]; ++j) {
            NSString * imgStr = [[object objectAtIndex:j]valueForKey:@"ad_image"];
            //获取图片
            NSInteger last = [self.productImages count] - [object count];
            if (last >=0) {
                for (int i = [productImages count]-1;i < last ; ++i) {
                    UIImageView * imageView = [weakSelf.productImages objectAtIndex:i];
                    [weakSelf.productImages removeObject:imageView];
                }
            }
            if (![imgStr isKindOfClass:[NSNull class]]) {
                [weakSelf getImage:imgStr withIndex:j];
            }
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
    
}

-(void)getImage:(NSString *)imgStr withIndex:(NSInteger )index
{
    __weak MyUploadDetailViewController * weakSelf = self;
    
    
    [[HttpService sharedInstance]getMusicImageWithResoucePath:imgStr CompletedBlock:^(id object) {
        if (object) {
            UIImageView * imageView = nil;
            
            if ([object isKindOfClass:[UIImage class]]) {
                imageView = [[UIImageView alloc]initWithImage:object];
                NSInteger count = weakSelf.productImages.count-1;
                NSLog(@"index:%d",index);
                if (index <= count) {
                    [weakSelf.productImages replaceObjectAtIndex:index withObject:imageView];
                }else
                {
                    [weakSelf.productImages addObject:imageView];
                }
            }
            [self updateAutoScrollViewItem];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
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
        if (isPlayLocalFile) {
            [self updatePlayerStatus:currentControllBtn.selected];
        }else
        {
            [self playMusic];
        }
        
    }else
    {
        if (isPlayLocalFile) {
            [myDelegate pause];
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
        [myDelegate play];
    }else if(isPlayStreamFile)
    {
        if (streamPlayer) {
            [streamPlayer play];
        }
    }
}

-(void)startLocalPlayerWithPath:(NSString *)path
{
    NSURL *inputFileURL = [NSURL fileURLWithPath:path];
    
    [myDelegate playItemWithURL:inputFileURL withMusicInfo:nil withPlaylist:nil];
    self.playView.playSlider.maximumValue = myDelegate.audioTotalFrame;
    [self.playView.playSlider addTarget:self action:@selector(updateCurrentPlayMusicPosition:) forControlEvents:UIControlEventTouchUpInside];
    self.playView.playSlider.continuous = NO;
    currentPlayFileLength = [GobalMethod convertSecondToMinute:myDelegate.currentPlayMusicLength];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateProcessingLocation:) name:CurrentPlayFilePostionInfo object:nil];
}

-(void)updateCurrentPlayMusicPosition:(id)sender
{
    UISlider * slider = (UISlider*)sender;
    if (slider.touchInside) {
        [myDelegate seekToPostion:slider.value];
    }
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
                myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                AFURLConnectionOperation *downloadOperation = [[AFURLConnectionOperation alloc]initWithRequest:request];
                downloadOperation.completionBlock = ^()
                {
                    //下载完成
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [GobalMethod localNotificationBody:[NSString stringWithFormat:@"%@下载完成",weakSelf.voiceItem.vl_name]];

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
                [myDelegate addnewOperation:downloadOperation];
                downloadOperation = nil;
            }
            
        }];
    }else
    {
        //文件路径错误
    }
}

-(void)startDownloadMusicWithObj:(NSDictionary *)musicObj completedBlock:(void (^)(NSError * error,NSDictionary * info))block;
{
    NSString * url = [musicObj valueForKey:@"URL"];
    NSURLRequest * request = [NSURLRequest requestWithURL:[GobalMethod getMusicUrl:url]];
    NSString * fileExtention = [url pathExtension];
    
    NSString * fileName = [[musicObj valueForKey:@"Name"]stringByAppendingPathExtension:fileExtention];
    if (request) {
        __weak MyUploadDetailViewController * weakSelf = self;
        
        [GobalMethod getExportPath:fileName completedBlock:^(BOOL isDownloaded, NSString *exportFilePath) {
            if (isDownloaded) {
                [self showAlertViewWithMessage:@"已经下载"];
            }else
            {
                AFURLConnectionOperation * downloadOperation = [[AFURLConnectionOperation alloc]initWithRequest:request];
                downloadOperation.completionBlock = ^()
                {
                    //下载完成
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showAlertViewWithMessage:@"下载完成"];
                        block (nil,nil);
                        CGFloat musicLength = [GobalMethod getMusicLength:[NSURL fileURLWithPath:exportFilePath]];
                        DownloadMusicInfo * info = [DownloadMusicInfo MR_createEntity];
                        info.title    = [musicObj valueForKey:@"Name"];
                        info.makeTime = [GobalMethod getMakeTime];
                        info.localPath= exportFilePath;
                        info.length   = [NSString stringWithFormat:@"%0.2f",musicLength];
                        info.isFavorite = @"0";
                        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
                        
                    });
                };
                downloadOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:exportFilePath append:NO];
                [myDelegate addnewOperation:downloadOperation];
                downloadOperation = nil;
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

-(void)downloadUpperImage
{
    NSMutableArray * imageArray = [NSMutableArray array];
    NSInteger last = [self.productImages count] - [upperDataSource count];
    if (last >=0) {
        for (int i = [upperDataSource count]-1;i < last ; ++i) {
            UIImageView * imageView = [self.productImages objectAtIndex:i];
            [self.productImages removeObject:imageView];
        }
    }
    
    for (int i =0 ;i<[upperDataSource count];i++) {
//        UIImageView * info = [[UIImageView alloc]initWithImage:image];
//        info.tag = tagNum;
//        
//        NSInteger count = weakSelf.autoScrollviewDataSource.count;
//        if (i < count) {
//            [weakSelf.autoScrollviewDataSource replaceObjectAtIndex:i withObject:info];
//        }else
//        {
//            [weakSelf.autoScrollviewDataSource addObject:info];
//        }
        
        [self updateAutoScrollViewItem];
    }
}

-(void)updateAutoScrollViewItem
{
    __weak MyUploadDetailViewController * weakSelf = self;
    autoScrollView.totalPagesCount = ^NSInteger(void){
        return [weakSelf.productImages count];
    };
    autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return weakSelf.productImages[pageIndex];
    };
}
#pragma  mark - Audio Notification
-(void)updateProcessingLocation:(NSNotification *)noti
{
    
    
    if (!self.playView.playSlider.touchInside) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.playView.playTimeLable.text = [NSString stringWithFormat:@"%@/%@",currentPlayFileLength,[GobalMethod convertSecondToMinute:[myDelegate currentPlayTime]]];
            self.playView.playSlider.value = [noti.object floatValue];
        });
    }
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

#pragma mark - UIAlertView Deleagte
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self startDownloadMusicWithObj:@{@"URL": self.voiceItem.url,@"Name":self.voiceItem.vl_name} completedBlock:^(NSError *error, NSDictionary *info) {
            ;
        }];
    }
}
@end
