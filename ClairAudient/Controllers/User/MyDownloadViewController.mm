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

#define Cell_Height 91.0f
@interface MyDownloadViewController ()<ItemDidSelectedDelegate,AudioReaderDelegate>
{
    NSArray * dataSource;
    CGFloat currentPlayFileLength;
    
    UISlider * currentSelectedItemSlider;
    UIButton * currentPlayItemControlBtn;
    NSTimer  * sliderTimer;
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
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.audioMng pause];
    if ([self.reader playing]) {
        [self.reader stop];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    currentPlayFileLength = length.floatValue;
    if (self.reader) {
        self.reader = nil;
    }
    self.reader = [[AudioReader alloc]
                   initWithAudioFileURL:inputFileURL
                   samplingRate:self.audioMng.samplingRate
                   numChannels:self.audioMng.numOutputChannels];
    self.reader.delegate = self;
    //太累了，要记住一定要设置currentime = 0.0,表示开始时间   :]
    self.reader.currentTime = 0.0;
    __weak MyDownloadViewController * weakSelf =self;
    
    [self.audioMng setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         [weakSelf.reader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
     }];
    
}

-(void)updateDataSource
{
    dataSource = [PersistentStore getAllObjectWithType:[DownloadMusicInfo class]];
    [self.tableView reloadData];
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
                currentSelectedItemSlider.value = 0.0;
                currentSelectedItemSlider.maximumValue = info.length.floatValue;
                currentPlayItemControlBtn = cell.controlBtn;
                if (cell.controlBtn.selected) {
                    [self playItemWithPath:info.localPath length:info.length];
                    [self.audioMng play];
                    NSLog(@"%@",info.title);
                }else
                {
                    [self.audioMng  pause];
                    if ([self.reader playing]) {
                        [self.reader stop];
                    }
                }
            }
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
            currentSelectedItemSlider.value = ceil(location);
        });
    }
    
}
@end