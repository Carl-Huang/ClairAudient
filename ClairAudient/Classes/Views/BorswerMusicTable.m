//
//  BorswerMusicTable.m
//  ClairAudient
//
//  Created by vedon on 11/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "BorswerMusicTable.h"
#import "MyDownloadCell.h"
#import "GobalMethod.h"
#import "AppDelegate.h"
#import "PersistentStore.h"
#import "MixingViewController.h"
#import "OSHelper.h"
#import "UpLoadView.h"
#import "Base64.h"

@interface BorswerMusicTable()<ItemDidSelectedDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UISlider * currentSelectedItemSlider;
    UIButton * currentPlayItemControlBtn;
    
    AppDelegate * myDelegate;
    UpLoadView * uploadView;
}
@end


@implementation BorswerMusicTable
@synthesize borswerDataSource;
@synthesize cell_Height;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

-(void)initailzationDataSource:(NSArray *)data cellHeight:(CGFloat)cellHeight type:(Class)objectType parentViewController:(UIViewController *)parent
{
    borswerDataSource = data;
    cell_Height = cellHeight;
    _type = objectType;
    
    UINib * nib = [UINib nibWithNibName:@"MyDownloadCell" bundle:[NSBundle bundleForClass:[MyDownloadCell class]]];
    [self registerNib:nib forCellReuseIdentifier:@"Cell"];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundView:nil];
    self.dataSource = self;
    self.delegate  = self;
    
    if ([OSHelper iOS7]) {
        self.separatorInset = UIEdgeInsetsZero;
    }
    _parentController = parent;
    myDelegate = [[UIApplication sharedApplication]delegate];
    
    uploadView = [[[NSBundle mainBundle]loadNibNamed:@"UpLoadView" owner:self options:nil]objectAtIndex:0];
    uploadView.parentController = parent;
}

-(void)stopPlayer
{
    if ([myDelegate isPlaying]) {
        [myDelegate pause];
    }
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

#pragma  mark - Audio Notification
-(void)updateProcessingLocation:(NSNotification *)noti
{
    if (!currentSelectedItemSlider.touchInside) {
        dispatch_async(dispatch_get_main_queue(), ^{
            currentSelectedItemSlider.value = [noti.object floatValue];
        });
    }
}

-(void)updateCurrentPlayMusicPosition:(id)sender
{
    UISlider * slider = (UISlider*)sender;
    if (slider.touchInside) {
        [myDelegate seekToPostion:slider.value];
    }
}
#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [borswerDataSource count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cell_Height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyDownloadCell * cell   = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    id  object              = [borswerDataSource objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = [object valueForKey:@"title"];
    //    cell.downloadTimeLabel.text = [GobalMethod customiseTimeFormat:object.makeTime];
    cell.recordTimeLabel.text   =[GobalMethod customiseTimeFormat:[object valueForKey:@"makeTime"]];
    
    NSURL * musicURL = [NSURL fileURLWithPath:[object valueForKey:@"localPath"]];
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
    id  info = object;
    for (int i =0; i < [borswerDataSource count]; i++) {
        id tempObj = [borswerDataSource objectAtIndex:i];
        if ([[tempObj valueForKey:@"makeTime"] isEqualToString:[info valueForKey:@"makeTime"]]) {
            @autoreleasepool {
                NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0] ;
                MyDownloadCell * cell = (MyDownloadCell *)[self cellForRowAtIndexPath:index];
                [cell.controlBtn setSelected:!cell.controlBtn.selected];
                currentSelectedItemSlider = cell.playSlider;
                currentPlayItemControlBtn = cell.controlBtn;
                if (cell.controlBtn.selected) {
                    
                    [self playItemWithPath:[info valueForKey:@"localPath"] length:[info valueForKey:@"length"]];
                    NSLog(@"%@",[info valueForKey:@"title"]);
                }else
                {
                    [myDelegate pause];
                }
            }
        }else
        {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0] ;
            MyDownloadCell * cell = (MyDownloadCell *)[self cellForRowAtIndexPath:index];
            cell.playSlider.value = 0.0;
            [cell.controlBtn setSelected:NO];
        }
    }
}

-(void)shareItem:(id)object
{
    //上传
    //base64 编码
    id  info = object;
    NSData * rawData = [[NSData alloc]initWithContentsOfFile:[info valueForKey:@"localPath"]];
    if (rawData) {
        NSString * encodeStr =    [rawData base64EncodedString];
        [uploadView setMusicEncodeStr:encodeStr];
        encodeStr = nil;
        [myDelegate.window addSubview:uploadView];
    }else
    {
        //
    }
}

-(void)addToFavorite:(id)object
{
    //分享
}

-(void)editItem:(id)object
{
    MixingViewController * viewController = [[MixingViewController alloc]initWithNibName:@"MixingViewController" bundle:nil];
    
    [viewController setMusicInfo:@{@"Title":[object valueForKey:@"title"],@"musicURL":[object valueForKey:@"localPath"]}];
    [_parentController.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
    
    
}

-(void)deleteItem:(id)object
{
    if ([GobalMethod removeItemAtPath:[object valueForKey:@"localPath"]]) {
        NSLog(@"删除本地文件成功");
    }else
    {
        NSLog(@"删除本地文件失败");
    }
    
    if ([PersistentStore deleteObje:object]) {
        //删除成功
        [self updateDataSource];
    }
}

-(void)updateDataSource
{
    borswerDataSource = [PersistentStore getAllObjectWithType:_type];
    [self reloadData];
}


@end
