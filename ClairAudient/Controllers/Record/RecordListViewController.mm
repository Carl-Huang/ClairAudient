//
//  RecordListViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-18.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "RecordListViewController.h"
#import "RecordListCell.h"
#import "ShareViewController.h"
#import "RecordMusicInfo.h"
#import "PersistentStore.h"
#import "AudioReader.h"
#import "AudioManager.h"

#define Cell_Height 90.0f
@interface RecordListViewController ()<ItemDidSelectedDelegate,AudioReaderDelegate>
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

@implementation RecordListViewController

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
    self.audioMng = [AudioManager shareAudioManager];
    [self updateDataSource];
    sliderTimer = nil;
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
}

- (void)dealloc
{
    [self setView:nil];
}


#pragma mark - Private Methods
- (void)initUI
{
    [_tableView setBackgroundColor:[UIColor clearColor]];
    UINib * nib = [UINib nibWithNibName:@"RecordListCell" bundle:[NSBundle bundleForClass:[RecordListCell class]]];
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
    __weak RecordListViewController * weakSelf =self;
    
    [self.audioMng setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         [weakSelf.reader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
     }];

}


-(void)updateDataSource
{
    dataSource = [PersistentStore getAllObjectWithType:[RecordMusicInfo class]];
    [self.tableView reloadData];
}

#pragma mark - Action Methods
- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}

- (IBAction)rightItemAction:(id)sender
{
    
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
    @autoreleasepool {
        RecordListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        RecordMusicInfo * object  = [dataSource objectAtIndex:indexPath.row];
        
        cell.nameLabel.text         = object.title;
        cell.recordTimeLabel.text   = object.makeTime;
        cell.playTimeLabel.text     = object.length;
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
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShareViewController * vc = [[ShareViewController alloc] initWithNibName:nil bundle:nil];
    vc.view.frame = CGRectMake(0, 0, vc.view.frame.size.width, vc.view.frame.size.height);
    [self.view addSubview:vc.view];
    [self.view bringSubviewToFront:vc.view];
    [self addChildViewController:vc];
}


#pragma mark - Cell Delegate
-(void)playItem:(id)object
{
    RecordMusicInfo * info = object;
    for (int i =0; i < [dataSource count]; i++) {
        RecordMusicInfo * tempObj = [dataSource objectAtIndex:i];
        if ([tempObj.title isEqualToString:info.title]) {
            @autoreleasepool {
                NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0] ;
                RecordListCell * cell = (RecordListCell *)[self.tableView cellForRowAtIndexPath:index];
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
        }else
        {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0] ;
            RecordListCell * cell = (RecordListCell *)[self.tableView cellForRowAtIndexPath:index];
            [cell.controlBtn setSelected:NO];
            cell.playSlider.value = 0.0;
        }
    }
}

-(void)shareItem:(id)object
{
    RecordMusicInfo * info = object;
    NSLog(@"%@",info.title);
}

-(void)addToFavorite:(id)object
{
    RecordMusicInfo * info = object;
    NSLog(@"%@",info.title);
}

-(void)editItem:(id)object
{
    RecordMusicInfo * info = object;
    NSLog(@"%@",info.title);
}

-(void)deleteItem:(id)object
{
    RecordMusicInfo * info = object;

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
