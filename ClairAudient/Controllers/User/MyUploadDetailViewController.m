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
#import "AsynCycleView.h"
#import "CommentView.h"

static NSString * cellIdentifier = @"cellIdentifier";
@interface MyUploadDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    AsynCycleView * autoScrollView;
    NSArray * descriptionArray;
    NSArray * contentArray;
    
    UIView * headerView;
    
    AudioPlayer * streamPlayer;
    NSThread * bufferingThread;
    BOOL isDowning;
    BOOL isPlayLocalFile;
    BOOL isPlayStreamFile;
    BOOL isPlaying;
    
    AppDelegate * myDelegate;
    NSArray * upperDataSource;
    UIImageView * placeHolderImage;
    
    BOOL isGetFileLength;

}
@property (strong ,nonatomic) UISlider * currentPlaySlider;
@property (strong ,nonatomic) UIButton * currentControllBtn;
@property (strong ,nonatomic) PlayItemView * playView;
@property (strong ,nonatomic) NSString * fileLength;
@property (strong ,nonatomic) NSString * currentPlayFileLength;
@end

@implementation MyUploadDetailViewController
@synthesize currentPlaySlider,playView,currentControllBtn,fileLength,currentPlayFileLength;

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
    self.title = self.voiceItem.vl_name;
    [self setLeftAndRightBarItem];
    [self initializationInterface];
    
    [[HttpService sharedInstance]getCommentWithParams:@{@"Vl_id":self.voiceItem.vlt_id} completionBlock:^(id object) {
        ;
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
    
    __weak MyUploadDetailViewController * weakSelf = self;
    [[HttpService sharedInstance]getCommentWithParams:@{@"vlId":self.voiceItem.hw_id} completionBlock:^(id object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([object count]) {
                CommentView * commentView = [[[NSBundle mainBundle]loadNibNamed:@"CommentView" owner:self options:nil]objectAtIndex:0];
                [commentView setBackgroundColor:[UIColor clearColor]];
                [commentView setObject:weakSelf.voiceItem];
                CGRect rect = commentView.frame;
                rect.origin.y = 410;
                commentView.frame = rect;
                
                [commentView setBlock:^(NSInteger height)
                {
                    CGSize size = weakSelf.contentScrollView.contentSize;
                    size.height += height;
                    [weakSelf.contentScrollView setContentSize:size];
                }];
                
                [commentView configureBubbleView:object];
                [weakSelf.contentScrollView addSubview:commentView];
            }
        });
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didGetFileLength:) name:@"StreamPlayFileLength" object:nil];
    isGetFileLength = NO;
    fileLength = @"";
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewBeginEdit) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEndEdit) name:UITextViewTextDidEndEditingNotification object:nil];
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
    
    [autoScrollView cleanAsynCycleView];
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

-(void)textViewBeginEdit
{
    [UIView animateWithDuration:0.3 animations:^{
        self.contentScrollView.frame = CGRectOffset(self.contentScrollView.frame, 0, -120);
    }];
}

-(void)textViewEndEdit
{
    [UIView animateWithDuration:0.3 animations:^{
        self.contentScrollView.frame = CGRectOffset(self.contentScrollView.frame, 0, 120);
    }];
}

#pragma mark - Private Method
-(void)didGetFileLength:(NSNotification *)noti
{
    
    if (!isGetFileLength) {
        isGetFileLength = YES;
         NSLog(@"%@",noti.object);
        fileLength = noti.object;
        [self.musicInfoTable reloadData];
        
    }
   
    
}

-(void)initializationInterface
{
    CGRect rect = self.containerView.bounds;
    placeHolderImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"first_2.png"]];
    [placeHolderImage setFrame:rect];
    [self.containerView addSubview:placeHolderImage];
    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"first_2.png"] placeHolderNum:3 addTo:self.containerView];
    [autoScrollView initializationInterface];
    
    [self.contentScrollView setContentSize:CGSizeMake(320, 800)];
    self.contentScrollView.scrollEnabled = YES;
    
    [self.musicInfoTable setBackgroundView:nil];
#ifdef IOS7_SDK_AVAILABLE
    if ([OSHelper iOS7]) {
        self.musicInfoTable.separatorInset = UIEdgeInsetsZero;
    }
#endif
    self.musicInfoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UINib * cellNib = [UINib nibWithNibName:@"MyUploadDetailCell" bundle:[NSBundle bundleForClass:[MyUploadDetailCell class]]];
    [self.musicInfoTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    
    playView = [[[NSBundle mainBundle]loadNibNamed:@"PlayItemView" owner:self options:nil]objectAtIndex:0];
    [playView.playBtn addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView.downloadBtn addTarget:self action:@selector(downloadMusic:) forControlEvents:UIControlEventTouchUpInside];
//    playView.playTimeLable.text = @"";
    [self.playViewContainer addSubview:playView];
    
    

    [[HttpService sharedInstance]getMusicImageWithParams:@{@"vltId": @"2"} completionBlock:^(id object) {
        NSMutableArray * tempLinks = [NSMutableArray array];
        for (int j = 0;j < [object count]; ++j) {
            NSString * imgStr = [[object objectAtIndex:j]valueForKey:@"ad_image"];
            [tempLinks addObject:imgStr];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [autoScrollView updateNetworkImagesLink:tempLinks];
        });
        
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
    
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
    
//    beijign.png
//    UIImage * strecthImage = [[UIImage imageNamed:@"beijign.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(20, 0, 500, 0)];
//    _musicInfoBg.image = strecthImage;
}


-(NSArray *)objectPropertyValueToArray:(id)object
{
    NSMutableArray * tempPropertyList = [NSMutableArray array];

    [tempPropertyList addObject:[object valueForKey:@"time"]];
    [tempPropertyList addObject:[object valueForKey:@"bit_rate"]];
    [tempPropertyList addObject:[object valueForKey:@"sampling_rate"]];
    //垃圾接口，竟然要减掉2位。
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:[[[object valueForKey:@"upload_time"]substringToIndex:10] integerValue]];
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
        streamPlayer.block = nil;
        streamPlayer = nil;
    }
    
    __weak MyUploadDetailViewController * weakSelf = self;
    streamPlayer = [[AudioPlayer alloc]init];
    
    [streamPlayer setBlock:^(double processOffset,BOOL isFinished)
     {
         
         if (processOffset > 0) {
             @try {
                 
                 if (isFinished) {
                     weakSelf.playView.playSlider.value = 0.0;
                     weakSelf.currentControllBtn.selected = NO;
                 }else
                 {
                     
                     weakSelf.playView.playSlider.value = processOffset;
                     if (weakSelf.fileLength) {
                         
                         CGFloat time = weakSelf.fileLength.floatValue* processOffset;
                         weakSelf.playView.playTimeLable.text =[NSString stringWithFormat:@"%@/%@",[GobalMethod convertSecondToMinute:weakSelf.fileLength.floatValue],[GobalMethod convertSecondToMinute:time]];
                     }
                    
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
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:_voiceItem.vl_name message:@"是否下载该声音" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
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
                        DownloadMusicInfo * info = [DownloadMusicInfo MR_createEntity];
                        info.title = weakSelf.voiceItem.vl_name;
                        info.makeTime = [GobalMethod getMakeTime];
                        info.localPath= exportFilePath;
                        info.length   = [GobalMethod getMusicLength:[NSURL fileURLWithPath:exportFilePath]];
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
                        DownloadMusicInfo * info = [DownloadMusicInfo MR_createEntity];
                        info.title    = [musicObj valueForKey:@"Name"];
                        info.makeTime = [GobalMethod getMakeTime];
                        info.localPath= exportFilePath;
                        info.length   = [GobalMethod getMusicLength:[NSURL fileURLWithPath:exportFilePath]];
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
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return playView.frame.size.height;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyUploadDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ([[descriptionArray objectAtIndex:indexPath.row] isEqualToString:@"时长"]) {
        [cell configureCellWithDescription:[descriptionArray objectAtIndex:indexPath.row] content:[GobalMethod convertSecondToMinute:fileLength.floatValue]];
    }else
    {
        [cell configureCellWithDescription:[descriptionArray objectAtIndex:indexPath.row] content:[contentArray objectAtIndex:indexPath.row]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (!headerView) {
//        headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 280, playView.frame.size.height)];
//        [headerView addSubview:playView];
//        [headerView setBackgroundColor:[UIColor clearColor]];
//    }
//    return headerView;
//}

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
