//
//  MixingMusicListViewController.m
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "MixingMusicListViewController.h"
#import "MixingMusicListCell.h"
#import "ControlCenter.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "TSLibraryImport.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MBProgressHUD.h"
#define Cell_Height 65.0f
@interface MixingMusicListViewController ()
{
    NSMutableArray * dataSource;
    
    //用importTool导出音乐库里面的文件
    TSLibraryImport* importTool;
    
    BOOL isSimulator;
}
@end

@implementation MixingMusicListViewController

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
    
    dataSource = [NSMutableArray array];
    importTool = [[TSLibraryImport alloc] init];
#if TARGET_IPHONE_SIMULATOR
    isSimulator = YES;
#else
    isSimulator = NO;
#endif
    if (isSimulator) {
         [dataSource addObject: @{@"Title":@"权利游戏",@"Artist":@"vedon",@"Album":@"权利游戏",@"musicTime":@"100",@"musicURL":@"空"}];
    }else
    {
        [self findArtistList];
        if ([dataSource count] == 0) {
            //没有歌曲
            [self showAlertViewWithMessage:@"本地没有音乐文件"];
        }
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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _tableView.backgroundColor = [UIColor clearColor];
    UINib * nib = [UINib nibWithNibName:@"MixingMusicListCell" bundle:[NSBundle bundleForClass:[MixingMusicListCell class]]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
}

-(void)modifyMusic:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSInteger index = btn.tag;
    NSDictionary * musicInfo = [dataSource objectAtIndex:index];
    
    if (isSimulator) {
        MixingViewController * viewController = [[MixingViewController alloc]initWithNibName:@"MixingViewController" bundle:nil];
        [viewController setMusicInfo:musicInfo];
        [self.navigationController pushViewController:viewController animated:YES];
        viewController = nil;

    }else
    {
        NSURL* assetURL = (NSURL *)[musicInfo valueForKey:@"musicURL"];
        __weak MixingMusicListViewController * weakSelf = self;
        [self exportAssetAtURL:assetURL withTitle:musicInfo[@"Title"] completedHandler:^(NSString *path) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableDictionary * tempMusicInfo = [NSMutableDictionary dictionaryWithDictionary:musicInfo];
                [tempMusicInfo setValue:path forKey:@"musicURL"];
                MixingViewController * viewController = [[MixingViewController alloc]initWithNibName:@"MixingViewController" bundle:nil];
                [viewController setMusicInfo:tempMusicInfo];
                [weakSelf.navigationController pushViewController:viewController animated:YES];
                viewController = nil;
            });
            
        }];

    }
}

-(void)findArtistList
{
    MPMediaQuery *listQuery = [MPMediaQuery playlistsQuery];
    //播放列表
    NSArray *playlist = [listQuery items];
    for (MPMediaItem * item in playlist) {
        NSDictionary * dic = [self getMPMediaItemInfo:item];
        [dataSource addObject:dic];
    }
}

- (NSDictionary *)getMPMediaItemInfo:(MPMediaItem *)item{
    NSString *title     = [item valueForProperty:MPMediaItemPropertyTitle];;
    NSString *artist    = [item valueForProperty:MPMediaItemPropertyArtist];
    NSString *albumName = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
    NSString *strTime   = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    NSURL *musicURL     = [item valueForProperty:MPMediaItemPropertyAssetURL];
    NSLog(@"%@",musicURL.absoluteString);
    //计算音乐文件所需要的时间
    
    int seconds = (int)[strTime integerValue];
    int minute = 0;
    if (seconds >= 60) {
        int index = seconds / 60;
        minute = index;
        seconds = seconds - index * 60;
    }
    NSString *musicTime = [NSString stringWithFormat:@"%02d:%02d", minute, seconds];
    //这里依次是 音乐名，艺术家，专辑名，音乐时间，音乐播放路径
    if (!albumName) {
        albumName = @"";
    }
    if (!artist) {
        artist = @"";
    }
    
    NSDictionary * musicInfo = @{@"Title":title,@"Artist":artist,@"Album":albumName,@"musicTime":musicTime,@"musicURL":musicURL};
    return musicInfo;
}

//读取本地音乐文件
-(NSMutableArray *)readLocalMusicFile
{
    NSMutableArray * array = [NSMutableArray array];
    
    
    return array;
}

- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title completedHandler:(void (^)(NSString * path))completedBlock
{
	
	NSString* ext = [TSLibraryImport extensionForAssetURL:assetURL];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString * filePath = [documentsDirectory stringByAppendingPathComponent:title];
    NSString * localFilePath = [filePath stringByAppendingPathExtension:ext];
	NSURL* outURL = [[NSURL fileURLWithPath:filePath] URLByAppendingPathExtension:ext];
	
    //已经存在就删除
    [[NSFileManager defaultManager] removeItemAtURL:outURL error:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [MBProgressHUD showHUDAddedTo: self.view animated:YES];
        __weak MixingMusicListViewController * weakSelf = self;
        [importTool importAsset:assetURL toURL:outURL completionBlock:^(TSLibraryImport* import) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            });
            if (import.status != AVAssetExportSessionStatusCompleted) {
                // something went wrong with the import
                NSLog(@"Error importing: %@", import.error);
                import = nil;
                return;
            }
            completedBlock (localFilePath);
        }];
        
    }else
    {
        //音频文件已经存在
        completedBlock (localFilePath);
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
    MixingMusicListCell * cell  = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary * dic          = [dataSource objectAtIndex:indexPath.row];

    [cell.editButton addTarget:self action:@selector(modifyMusic:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.bigTitleLabel.text     = [dic valueForKey:@"Artist"];
    cell.littleTitleLabel.text  = [dic valueForKey:@"Title"];
    cell.editButton.tag         = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [ControlCenter showSoundEffectVC];
    
}

#pragma mark -
- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}
@end
