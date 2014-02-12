//
//  MyUploadDetailViewController.m
//  ClairAudient
//
//  Created by vedon on 11/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

/*
 以voice_data开头的用http://app.hfapp.cn/soundValley这个前缀
 */
#define MusicVoiceDatePrefix @"http://app.hfapp.cn/soundValley/"
/*
 其他
 */
#define MusicOtherPrefix     @"http://s1.vocc.cc/"


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
static NSString * cellIdentifier = @"cellIdentifier";
@interface MyUploadDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    CycleScrollView * advertisementImageView;
    NSArray * descriptionArray;
    NSArray * contentArray;
    
    UIView * headerView;
    
    AudioPlayer * streamPlayer;
    
    NSThread * bufferingThread;
}
@property (strong ,nonatomic) UISlider * currentPlaySlider;
@property (strong ,nonatomic) PlayItemView * playView;
@end

@implementation MyUploadDetailViewController
@synthesize currentPlaySlider,playView;

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
    
    CGRect rect = self.scrollAdView.frame;
    rect.origin.x = rect.origin.y = 0;
    
    advertisementImageView = [[CycleScrollView alloc]initWithFrame:rect cycleDirection:CycleDirectionLandscape pictures:@[[UIImage imageNamed:@"testImage.png"],[UIImage imageNamed:@"testImage.png"]] autoScroll:YES];
    [self.scrollAdView addSubview:advertisementImageView];
    
    
    self.musicInfoTable.scrollEnabled = NO;
    descriptionArray = @[@"时长",@"比特率",@"采样率",@"录入时间",@"下载次数",@"用户"];
    
    if (self.voiceItem) {
        contentArray  = [self objectPropertyValueToArray:self.voiceItem];
    }else
    {
        //No music info
        [self showAlertViewWithMessage:@"读取音乐文件错误"];
    }
    
    [self.contentScrollView setContentSize:CGSizeMake(420, 600)];
    [self.contentScrollView setBackgroundColor:[UIColor clearColor]];
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
    currentPlaySlider = playView.playSlider;
    currentPlaySlider.maximumValue = 1.0;
    currentPlaySlider.minimumValue = 0.0;
    currentPlaySlider.value = 0.0;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [streamPlayer stop];
    streamPlayer = nil;
}
#pragma mark - Private Method
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
    UIButton * btn = (UIButton *)sender;
    [btn setSelected:!btn.selected];
    if (streamPlayer) {
        [streamPlayer stop];
        streamPlayer = nil;
    }
    __weak MyUploadDetailViewController * weakSelf = self;
    streamPlayer = [[AudioPlayer alloc]init];
    [streamPlayer setBlock:^(double processOffset)
     {
         
         if (processOffset > 0) {
             NSLog(@"%f",processOffset);
             @try {
                 weakSelf.playView.playSlider.value = processOffset;
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
    NSURL * musciURL = [self getMusicUrl:self.voiceItem.url];
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
    
}

-(NSURL *)getMusicUrl:(NSString *)path
{
    NSString * prefixStr = nil;
    if ([path rangeOfString:@"voice_data"].location!= NSNotFound) {
        prefixStr = MusicVoiceDatePrefix;
    }else
    {
        prefixStr = MusicOtherPrefix;
    }
    NSURL * url = [NSURL URLWithString:[prefixStr stringByAppendingString:path]];
    return url;
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
@end
