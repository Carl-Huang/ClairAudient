//
//  MyDownloadViewController.m
//  ClairAudient
//
//  Created by vedon on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "MyDownloadViewController.h"
#import "MyDownloadCell.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "PersistentStore.h"
#import "DownloadMusicInfo.h"
#import "GobalMethod.h"
#import "AudioManager.h"
#import "AudioReader.h"
#import "MixingViewController.h"
#import "AppDelegate.h"
#define Cell_Height 91.0f
@interface MyDownloadViewController ()<ItemDidSelectedDelegate,AudioReaderDelegate>
{
    NSArray * dataSource;
    CGFloat currentPlayFileLength;
    
    UISlider * currentSelectedItemSlider;
    UIButton * currentPlayItemControlBtn;
    NSTimer  * sliderTimer;
    
    AppDelegate * myDelegate;
    NSString * currentPlayItem;
}
@property (strong ,nonatomic) AudioReader   * reader;
@property (strong ,nonatomic) AudioManager  * audioMng;
@end

@implementation MyDownloadViewController
#pragma mark - Life Cycle
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
    [self initUI];
    sliderTimer = nil;
    self.audioMng = [AudioManager shareAudioManager];
    dataSource = [PersistentStore getAllObjectWithType:[DownloadMusicInfo class]];
    myDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if ([myDelegate isPlaying]) {
        [myDelegate pause];
    }
    
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

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"我的下载";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setLeftAndRightBarItem];
    _tableView.backgroundColor = [UIColor clearColor];
    UINib * nib = [UINib nibWithNibName:@"MyDownloadCell" bundle:[NSBundle bundleForClass:[MyDownloadCell class]]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
}

-(void)playItemWithPath:(NSString *)localFilePath length:(NSString *)length
{
    
    NSURL *inputFileURL = [NSURL fileURLWithPath:localFilePath];
    if([inputFileURL.absoluteString isEqualToString:[myDelegate currentPlayFilePath]])
    {
        //同一文件
        [myDelegate play];
    }else
    {
        [myDelegate playItemWithURL:inputFileURL withMusicInfo:nil withPlaylist:nil];
        currentSelectedItemSlider.maximumValue = myDelegate.audioTotalFrame;
        [currentSelectedItemSlider addTarget:self action:@selector(updateCurrentPlayMusicPosition:) forControlEvents:UIControlEventTouchUpInside];
        currentSelectedItemSlider.continuous = NO;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateProcessingLocation:) name:CurrentPlayFilePostionInfo object:nil];
    }
    
    
}

-(void)updateCurrentPlayMusicPosition:(id)sender
{
    UISlider * slider = (UISlider*)sender;
    if (slider.touchInside) {
        [myDelegate seekToPostion:slider.value];
    }
}

-(void)updateDataSource
{
    dataSource = [PersistentStore getAllObjectWithType:[DownloadMusicInfo class]];
    [self.tableView reloadData];
}
#pragma  mark - Audio Notification
-(void)updateProcessingLocation:(NSNotification *)noti
{
    if (!currentSelectedItemSlider.touchInside) {
        dispatch_async(dispatch_get_main_queue(), ^{
            currentSelectedItemSlider.value = [noti.object floatValue];
        });
    }
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Cell_Height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyDownloadCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    DownloadMusicInfo * object = [dataSource objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = object.title;
//    cell.downloadTimeLabel.text = [GobalMethod customiseTimeFormat:object.makeTime];
    cell.nameLabel.text         = object.title;
    cell.recordTimeLabel.text   = object.makeTime;
    
    NSURL * musicURL = [NSURL fileURLWithPath:object.localPath];
    cell.playTimeLabel.text     = [NSString stringWithFormat:@"%0.2f",[GobalMethod getMusicLength:musicURL]];
    
    cell.delegate               = self;
    cell.musicInfo              = object;
    
    cell.playSlider.value = 0.0f;
    [cell.playSlider setThumbImage:[UIImage imageNamed:@"record_20"] forState:UIControlStateNormal];
    [cell.playSlider setThumbImage:[UIImage imageNamed:@"record_20"] forState:UIControlStateHighlighted];
    [cell.playSlider setMinimumTrackImage:[UIImage imageNamed:@"MinimumTrackImage"] forState:UIControlStateNormal];
    [cell.playSlider setMaximumTrackImage:[UIImage imageNamed:@"record_19"] forState:UIControlStateNormal];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Cell Delegate
-(void)playItem:(id)object
{
    DownloadMusicInfo * info = object;
    for (int i =0; i < [dataSource count]; i++) {
        DownloadMusicInfo * tempObj = [dataSource objectAtIndex:i];
        if ([tempObj.title isEqualToString:info.title]) {
            @autoreleasepool {
                NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0] ;
                MyDownloadCell * cell = (MyDownloadCell *)[self.tableView cellForRowAtIndexPath:index];
                [cell.controlBtn setSelected:!cell.controlBtn.selected];
                currentSelectedItemSlider = cell.playSlider;
                currentPlayItemControlBtn = cell.controlBtn;
                if (cell.controlBtn.selected) {
                    
                    [self playItemWithPath:info.localPath length:info.length];
                    NSLog(@"%@",info.title);
                }else
                {
                    [myDelegate pause];
                }
            }
        }else
        {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0] ;
            MyDownloadCell * cell = (MyDownloadCell *)[self.tableView cellForRowAtIndexPath:index];
            cell.playSlider.value = 0.0;
            [cell.controlBtn setSelected:NO];
        }
    }
}

-(void)shareItem:(id)object
{
    DownloadMusicInfo * info = object;
    NSLog(@"%@",info.title);
}

-(void)addToFavorite:(id)object
{
    DownloadMusicInfo * info = object;
    NSLog(@"%@",info.title);
}

-(void)editItem:(id)object
{
    DownloadMusicInfo * info = object;
    NSLog(@"%@",info.title);
    MixingViewController * viewController = [[MixingViewController alloc]initWithNibName:@"MixingViewController" bundle:nil];

    [viewController setMusicInfo:@{@"Title": info.title,@"musicURL":info.localPath}];
    [self push:viewController];
    viewController = nil;
    

}

-(void)deleteItem:(id)object
{
    DownloadMusicInfo * info = object;
    if ([GobalMethod removeItemAtPath:info.localPath]) {
        NSLog(@"删除本地文件成功");
    }else
    {
        NSLog(@"删除本地文件失败");
    }
    
    if ([PersistentStore deleteObje:info]) {
        //删除成功
        [self updateDataSource];
    }
    NSLog(@"%@",info.title);
}

#pragma mark - AudioReader Delegate
-(void)currentFileLocation:(CGFloat)location
{
    if (location == currentPlayFileLength) {
        [self.audioMng pause];
        [currentPlayItemControlBtn setSelected:NO];
        currentSelectedItemSlider.value = 0.0f;
    }else
    {
        NSLog(@"%f",location);
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat process = [[NSString stringWithFormat:@"%0.3f",location/currentPlayFileLength]floatValue];
            currentSelectedItemSlider.value = process;
        });
    }
    
}
@end
