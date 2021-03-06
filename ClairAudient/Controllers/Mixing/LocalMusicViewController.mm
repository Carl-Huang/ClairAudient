//
//  LocalMusicViewController.m
//  ClairAudient
//
//  Created by vedon on 24/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//
#define Cell_Height 65.0f

#import "LocalMusicViewController.h"
#import "MixingMusicListCell.h"
#import "ControlCenter.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "TSLibraryImport.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MBProgressHUD.h"
#import "MusicInfo.h"
#import "PersistentStore.h"
#import "AudioReader.h"
#import "AudioManager.h"
#import "MutiMixingViewController.h"
#import <objc/runtime.h>
#import <Foundation/NSObjCRuntime.h>
#import <objc/message.h>
#import "AutoCompletedOperation.h"
@interface LocalMusicViewController ()<UITextFieldDelegate,AutoCompleteOperationDelegate>
{
    NSMutableArray * dataSource;
    
    //用importTool导出音乐库里面的文件
    TSLibraryImport* importTool;
    
    BOOL isSimulator;
    
    //当前选择文件的本地路径
    NSString * currentLocationPath;
    
    //控制使用哪个数据源
    BOOL isSearchResultDataSource;
    
    NSArray        * searchResultDataSource;
}

@property (strong ,nonatomic) AudioReader * reader;
@property (strong ,nonatomic) AudioManager * audioMng;
@property (strong ,nonatomic) NSOperationQueue *autoCompleteQueue;
@end

@implementation LocalMusicViewController

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
    [super viewDidLoad];
    [self initUI];
    
    dataSource = [NSMutableArray array];
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
    }    // Do any additional setup after loading the view from its nib.
    
    //搜索框
    self.searchField.delegate   = self;
    
    
    isSearchResultDataSource    = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.audioMng pause];
    if ([self.reader playing]) {
        [self.reader stop];
    }
}
#pragma mark - Private Methods
- (void)initUI
{
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.contentTable.backgroundColor = [UIColor clearColor];
    UINib * nib = [UINib nibWithNibName:@"MixingMusicListCell" bundle:[NSBundle bundleForClass:[MixingMusicListCell class]]];
    [self.contentTable registerNib:nib forCellReuseIdentifier:@"Cell"];
}

-(void)playMusic:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSInteger index = btn.tag;
    NSDictionary * musicInfo = [dataSource objectAtIndex:index];
    [self configureLibraryMusicWithSelector:@selector(playItemWithPath:) withInfo:musicInfo];
}

-(void)editMusic:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    NSDictionary * musicInfo = [dataSource objectAtIndex:btn.tag];
    [self configureLibraryMusicWithSelector:@selector(editItemWithPath:) withInfo:musicInfo];

}


-(void)configureLibraryMusicWithSelector:(SEL)action withInfo:(NSDictionary *)info
{
    if ([self isValidMusicName:[info valueForKey:@"Title"]])
    {
        if (isSimulator)
        {
            objc_msgSend(self, action,info[@"musicURL"]);
        }else
        {
            NSURL* assetURL         = (NSURL *)[info valueForKey:@"musicURL"];
            NSString * musicTitle   = info[@"Title"];
            [self getLocationFilePath:assetURL title:musicTitle];
            
            
            //判断是否已经在本地有音乐库的文件
            NSArray * array =[PersistentStore getAllObjectWithType:[MusicInfo class]];
            if ([array count]) {
                for (MusicInfo * object in array) {
                    if ([object.title isEqualToString:musicTitle]) {
                        objc_msgSend(self, action,object.localFilePath);
                        return;
                    }
                }
            }
            //在数据库中没有找到已经读取的文件，执行一下操作：从ipd library 中复制音乐文件到用户document 目录下
            //1) 保存数据到数据库
            MusicInfo * tempMusicInfo    = [MusicInfo MR_createEntity];
            tempMusicInfo.title          =  musicTitle;
            tempMusicInfo.artist         = [info valueForKey:@"Artist"];
            tempMusicInfo.localFilePath  = currentLocationPath;
            [[NSManagedObjectContext MR_defaultContext]MR_saveOnlySelfAndWait];
            
            //复制文件到本地
            [self exportAssetAtURL:assetURL withTitle:info[@"Title"] completedHandler:^(NSString *path) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (action) {
                        objc_msgSend(self, action,path);
                    }
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

//读取本地音乐文件
-(NSMutableArray *)readLocalMusicFile
{
    NSMutableArray * array = [NSMutableArray array];
    
    
    return array;
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
        __weak LocalMusicViewController * weakSelf = self;
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

-(void)playItemWithPath:(NSString *)localFilePath
{
    self.audioMng = [AudioManager shareAudioManager];
    [self.audioMng pause];
    if ([self.reader playing]) {
        [self.reader stop];
    }
    
    NSURL *inputFileURL = [NSURL fileURLWithPath:localFilePath];
    if (self.reader) {
        self.reader = nil;
    }
    self.reader = [[AudioReader alloc]
                   initWithAudioFileURL:inputFileURL
                   samplingRate:self.audioMng.samplingRate
                   numChannels:self.audioMng.numOutputChannels];
    
    //太累了，要记住一定要设置currentime = 0.0,表示开始时间   :]
    self.reader.currentTime = 0.0;
    __weak LocalMusicViewController * weakSelf =self;
    
    [self.audioMng setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         [weakSelf.reader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
     }];
    [self.audioMng play];
}

-(void)editItemWithPath:(NSString *)path
{
    MutiMixingViewController * viewController = [[MutiMixingViewController alloc]initWithNibName:@"MutiMixingViewController" bundle:nil];
    [viewController setMutiMixingInfo:@{@"musicURL":path}];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;
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
    NSDictionary * dic = nil;
    if (isSearchResultDataSource) {
        dic = [searchResultDataSource objectAtIndex:indexPath.row];
    }else
    {
        dic = [dataSource objectAtIndex:indexPath.row];
    }
    MixingMusicListCell * cell  = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell.firstBtn setImage:[UIImage imageNamed:@"hunyin_45.png"] forState:UIControlStateNormal];
    [cell.secondBtn setImage:[UIImage imageNamed:@"hunyin_46.png"] forState:UIControlStateNormal];
    [cell.firstBtn addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [cell.secondBtn addTarget:self action:@selector(editMusic:) forControlEvents:UIControlEventTouchUpInside];
    
    
    cell.firstBtn.tag           = indexPath.row;
    cell.secondBtn.tag          = indexPath.row;
    cell.bigTitleLabel.text     = [dic valueForKey:@"Artist"];
    cell.littleTitleLabel.text  = [dic valueForKey:@"Title"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    [ControlCenter showSoundEffectVC];
    
}


-(void)updateTableWithData:(NSArray *)data
{
    if (dataSource) {
        dataSource = nil;
    }
    dataSource = [data mutableCopy];
    [self.contentTable reloadData];
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
    }else if ([string length]==0)
    {
        isSearchResultDataSource = NO;
        [self.contentTable reloadData];
        return YES;
    }else
    {
        NSLog(@"%@",string);
        [self fetchItemsResultsWithString:string];
        return  YES;
    }
    
}

#pragma mark - AutoComplete Operation Delegate
- (void)autoCompleteItems:(NSArray *)autocompletions
{
    isSearchResultDataSource    = YES;
    searchResultDataSource      = autocompletions;
    if ([searchResultDataSource count]) {
        [self.contentTable reloadData];
    }
    
}
@end
