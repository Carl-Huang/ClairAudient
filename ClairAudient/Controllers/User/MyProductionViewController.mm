//
//  MyProductionViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "MyProductionViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "MyProductionCell.h"
#import "EditListCell.h"
#import <AudioToolbox/AudioToolbox.h>
#import "PersistentStore.h"
#import "EditMusicInfo.h"
#import "AudioReader.h"
#import "AudioManager.h"

#define Cell_Height 90.0f
@interface MyProductionViewController ()<ItemDidSelectedDelegate>
{
    NSArray * dataSource;
    UISlider * currentSelectedItemSlider;
    NSTimer  * sliderTimer;
    UIButton * currentPlayItemControlBtn;
    CGFloat currentPlayFileLength;
}
@property (strong ,nonatomic) AudioReader   * reader;
@property (strong ,nonatomic) AudioManager  * audioMng;

@end

@implementation MyProductionViewController

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
    dataSource = [PersistentStore getAllObjectWithType:[EditMusicInfo class]];
    if ([dataSource count]) {
        [self.tableView reloadData];
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
    self.title = @"我的制作";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setLeftAndRightBarItem];
    _tableView.backgroundColor = [UIColor clearColor];
    UINib * nib = [UINib nibWithNibName:@"EditListCell" bundle:[NSBundle bundleForClass:[EditListCell class]]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
}

-(void)readMusicInfo
{
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* path = [bundle bundlePath];
    NSURL * fileURL=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/akon、be - you - with.mp3", path]];
    AudioFileTypeID fileTypeHint = kAudioFileMP3Type;
    NSString *fileExtension = [[fileURL path] pathExtension];
    if ([fileExtension isEqual:@"mp3"]||[fileExtension isEqual:@"m4a"])
    {
        AudioFileID fileID  = nil;
        OSStatus err        = noErr;
        
        err = AudioFileOpenURL( (__bridge CFURLRef) fileURL, kAudioFileReadPermission, 0, &fileID );
        if( err != noErr ) {
            NSLog( @"打开文件失败" );
        }
        UInt32 id3DataSize  = 0;
        err = AudioFileGetPropertyInfo( fileID, kAudioFilePropertyID3Tag, &id3DataSize, NULL );
        
        if( err != noErr ) {
            NSLog( @"AudioFileGetPropertyInfo failed for ID3 tag" );
        }
        NSDictionary *piDict = nil;
        UInt32 piDataSize   = sizeof( piDict );
        err = AudioFileGetProperty( fileID, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict );
        if( err != noErr ) {
            piDict  = nil;
            NSLog( @"AudioFileGetProperty failed for property info dictionary" );
        }
        CFDataRef AlbumPic= nil;
        UInt32 picDataSize = sizeof(picDataSize);
        err =AudioFileGetProperty( fileID,   kAudioFilePropertyAlbumArtwork, &picDataSize, &AlbumPic);
        if( err != noErr ) {
            NSLog( @"Get picture failed" );
        }
        NSData* imagedata= (__bridge NSData*)AlbumPic;
        UIImage* image=[[UIImage alloc]initWithData:imagedata];
        NSString * Album = [(NSDictionary*)piDict objectForKey:
                            [NSString stringWithUTF8String: kAFInfoDictionary_Album]];
        NSString * Artist = [(NSDictionary*)piDict objectForKey:
                             [NSString stringWithUTF8String: kAFInfoDictionary_Artist]];
        NSString * Title = [(NSDictionary*)piDict objectForKey:
                            [NSString stringWithUTF8String: kAFInfoDictionary_Title]];
        NSLog(@"%@",Title);
        
        NSLog(@"%@",Artist);
        
        NSLog(@"%@",Album);
        
    }
}

-(void)updateDataSource
{
    dataSource = [PersistentStore getAllObjectWithType:[EditMusicInfo class]];
    [self.tableView reloadData];
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
    
    //太累了，要记住一定要设置currentime = 0.0,表示开始时间   :]
    self.reader.currentTime = 0.0;
    __weak MyProductionViewController * weakSelf =self;
    
    [self.audioMng setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         [weakSelf.reader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
     }];
    
    if (sliderTimer) {
        [sliderTimer invalidate];
        sliderTimer = nil;
    }
    sliderTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateSliderPositon) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:sliderTimer forMode:NSRunLoopCommonModes];
    [sliderTimer fire];
}

-(void)updateSliderPositon
{
    
    CGFloat postionInSec = self.reader.currentTime / 100.0;
    if (postionInSec == currentPlayFileLength) {
        [self.audioMng pause];
        [currentPlayItemControlBtn setSelected:NO];
        currentSelectedItemSlider.value = 0.0f;
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            currentSelectedItemSlider.value = postionInSec;
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
    EditListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    EditMusicInfo * object = [dataSource objectAtIndex:indexPath.row];
    cell.nameLabel.text         = object.title;
    cell.recordTimeLabel.text   = object.makeTime;
    cell.playTimeLabel.text     = object.length;
    cell.delegate               = self;
    cell.musicInfo              = object;
    [cell.playSlider setThumbImage:[UIImage imageNamed:@"record_20"] forState:UIControlStateNormal];
    [cell.playSlider setThumbImage:[UIImage imageNamed:@"record_20"] forState:UIControlStateHighlighted];
    [cell.playSlider setMinimumTrackImage:[UIImage imageNamed:@"record_19"] forState:UIControlStateNormal];
    [cell.playSlider setMaximumTrackImage:[UIImage imageNamed:@"record_19"] forState:UIControlStateNormal];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

    return cell;
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Cell Delegate
-(void)playItem:(id)object
{
    EditMusicInfo * info = object;
    for (int i =0; i < [dataSource count]; i++) {
        EditMusicInfo * tempObj = [dataSource objectAtIndex:i];
        if ([tempObj.title isEqualToString:info.title]) {
            @autoreleasepool {
                NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0] ;
                EditListCell * cell = (EditListCell *)[self.tableView cellForRowAtIndexPath:index];
                [cell.controlBtn setSelected:!cell.controlBtn.selected];
                currentSelectedItemSlider = cell.playSlider;
                currentSelectedItemSlider.value = 0.0;
                currentSelectedItemSlider.maximumValue = info.length.floatValue;
                currentPlayItemControlBtn = cell.controlBtn;
                if (cell.controlBtn.selected) {
                    [self playItemWithPath:info.localFilePath length:info.length];
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
    EditMusicInfo * info = object;
    NSLog(@"%@",info.title);
}

-(void)addToFavorite:(id)object
{
    EditMusicInfo * info = object;
    NSLog(@"%@",info.title);
}

-(void)editItem:(id)object
{
    EditMusicInfo * info = object;
    NSLog(@"%@",info.title);
}

-(void)deleteItem:(id)object
{
    EditMusicInfo * info = object;
    
    if ([PersistentStore deleteObje:info]) {
        //删除成功
        [self updateDataSource];
    }
    NSLog(@"%@",info.title);
}

@end
