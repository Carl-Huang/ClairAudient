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
#import "MusicInfo.h"
#import "PersistentStore.h"
#import "AutoCompletedOperation.h"

#define Cell_Height 65.0f
@interface MixingMusicListViewController ()<UITextFieldDelegate,AutoCompleteOperationDelegate>
{
    NSMutableArray * dataSource;
    NSArray        * searchResultDataSource;
    //用importTool导出音乐库里面的文件
    TSLibraryImport* importTool;
    
    BOOL isSimulator;
    
    //当前选择文件的本地路径
    NSString * currentLocationPath;
    
    //控制使用哪个数据源
    BOOL isSearchResultDataSource;
}
@property (strong ,nonatomic) NSOperationQueue *autoCompleteQueue;
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
    searchResultDataSource = [NSArray array];
    importTool = [[TSLibraryImport alloc] init];
#if TARGET_IPHONE_SIMULATOR
    isSimulator = YES;
#else
    isSimulator = NO;
#endif
    NSString * path = [[NSBundle mainBundle] pathForResource:@"权利游戏" ofType:@"mp3"];
    if (isSimulator) {
         [dataSource addObject: @{@"Title":@"权利游戏",@"Artist":@"vedon",@"Album":@"权利游戏",@"musicTime":@"100",@"musicURL":path}];
    }else
    {
        [self findArtistList];
        if ([dataSource count] == 0) {
            //没有歌曲
            [self showAlertViewWithMessage:@"本地没有音乐文件"];
        }
    }
    
    
    //搜索框
    self.searchField.delegate   = self;
    
    isSearchResultDataSource    = NO;
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
    [self copyMusicToLocalAndPlay:musicInfo];
}

-(void)copyMusicToLocalAndPlay:(NSDictionary *)musicInfo
{
    if ([self isValidMusicName:[musicInfo valueForKey:@"Title"]]) {
        if (isSimulator) {
            MixingViewController * viewController = [[MixingViewController alloc]initWithNibName:@"MixingViewController" bundle:nil];
            [viewController setMusicInfo:musicInfo];
            [self.navigationController pushViewController:viewController animated:YES];
            viewController = nil;
            
        }else
        {
            NSURL* assetURL         = (NSURL *)[musicInfo valueForKey:@"musicURL"];
            NSString * musicTitle   = musicInfo[@"Title"];
            [self getLocationFilePath:assetURL title:musicTitle];
            __weak MixingMusicListViewController * weakSelf = self;
            
            //判断是否已经在本地有音乐库的文件
            NSArray * array =[PersistentStore getAllObjectWithType:[MusicInfo class]];
            if ([array count]) {
                for (MusicInfo * object in array) {
                    if ([object.title isEqualToString:musicTitle]) {
                        
                        NSMutableDictionary * tempMusicInfo     = [NSMutableDictionary dictionaryWithDictionary:musicInfo];
                        [tempMusicInfo setValue:currentLocationPath forKey:@"musicURL"];
                        
                        MixingViewController * viewController   = [[MixingViewController alloc]initWithNibName:@"MixingViewController" bundle:nil];
                        [viewController setMusicInfo:tempMusicInfo];
                        [weakSelf.navigationController pushViewController:viewController animated:YES];
                        viewController = nil;
                        return;
                    }
                }
            }
            
            //在数据库中没有找到已经读取的文件，执行一下操作：从ipd library 中复制音乐文件到用户document 目录下
            //1) 保存数据到数据库
            MusicInfo * info    = [MusicInfo MR_createEntity];
            info.title          =  musicTitle;
            info.artist         = [musicInfo valueForKey:@"Artist"];
            info.localFilePath  = currentLocationPath;
            [[NSManagedObjectContext MR_defaultContext]MR_saveOnlySelfAndWait];
            
            //复制文件到本地
            [self exportAssetAtURL:assetURL withTitle:musicInfo[@"Title"] completedHandler:^(NSString *path) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableDictionary * tempMusicInfo     = [NSMutableDictionary dictionaryWithDictionary:musicInfo];
                    [tempMusicInfo setValue:path forKey:@"musicURL"];
                    MixingViewController * viewController   = [[MixingViewController alloc]initWithNibName:@"MixingViewController" bundle:nil];
                    [viewController setMusicInfo:tempMusicInfo];
                    [weakSelf.navigationController pushViewController:viewController animated:YES];
                    viewController = nil;
                });
                
            }];
        }
    }else
    {
        [self showAlertViewWithMessage:@"音乐文件名有误"];
    }
}

-(BOOL)isValidMusicName:(NSString *)musicName
{
    //有可能会遇到像   泡沫/杨子琪.mp3 这样的文件。需要首先判断是否是合法的名称
    if ([musicName rangeOfString:@"/"].location != NSNotFound) {
        return NO;
    }
    return YES;
}


-(void)findArtistList
{
    MPMediaQuery *listQuery = [MPMediaQuery playlistsQuery];
    NSNumber *musicType = [NSNumber numberWithInteger:MPMediaTypeMusic];
    
    MPMediaPropertyPredicate *musicPredicate = [MPMediaPropertyPredicate predicateWithValue:musicType forProperty:MPMediaItemPropertyMediaType];
    [listQuery addFilterPredicate: musicPredicate];
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

-(void)getLocationFilePath:(NSURL*)assetURL title:(NSString *)title
{
    NSString* ext = [TSLibraryImport extensionForAssetURL:assetURL];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * filePath = [documentsDirectory stringByAppendingPathComponent:title];
    currentLocationPath = [filePath stringByAppendingPathExtension:ext];

}

- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title completedHandler:(void (^)(NSString * path))completedBlock
{
	NSURL* outURL = [NSURL fileURLWithPath:currentLocationPath];
    //已经存在就删除
    [[NSFileManager defaultManager] removeItemAtURL:outURL error:nil];
    
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:currentLocationPath]) {
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
            completedBlock (currentLocationPath);
        }];
        
    }else
    {
        //音频文件已经存在
        completedBlock (currentLocationPath);
    }
}

-(void)updateTableWithData:(NSArray *)data
{
    if (dataSource) {
        dataSource = nil;
    }
    dataSource = [data mutableCopy];
    [self.tableView reloadData];
}

-(void)fetchItemsResultsWithString:(NSString *)searchStr
{
    [self.autoCompleteQueue cancelAllOperations];
    if (self.autoCompleteQueue == nil) {
        self.autoCompleteQueue = [[NSOperationQueue alloc]init];
    }
    AutoCompletedOperation *operation = [[AutoCompletedOperation alloc]
                                         initWithDelegate:self
                                         incompleteString:searchStr
                                         possibleCompletions:dataSource];
    [self.autoCompleteQueue addOperation:operation];
    operation = nil;

}

#pragma mark - Outlet Action
- (IBAction)backAction:(id)sender
{
    [self popVIewController];
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
    NSDictionary * dic = nil;
    if (isSearchResultDataSource) {
        dic = [searchResultDataSource objectAtIndex:indexPath.row];
    }else
    {
        dic = [dataSource objectAtIndex:indexPath.row];
    }
    

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

#pragma mark - TextField Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self fetchItemsResultsWithString:textField.text];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }else
    {
        [self fetchItemsResultsWithString:string];
        return  YES;
    }
    
}

#pragma mark - AutoComplete Operation Delegate
- (void)autoCompleteItems:(NSArray *)autocompletions
{
    isSearchResultDataSource    = YES;
    searchResultDataSource      = autocompletions;
    [self.tableView reloadData];
}
@end
