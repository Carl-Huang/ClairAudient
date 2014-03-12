//
//  MyProductionViewController.m
//  ClairAudient
//
//  Created by vedon on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "MyProductionViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "MyProductionCell.h"
#import "EditListCell.h"
#import "PersistentStore.h"
#import "EditMusicInfo.h"
#import "BorswerMusicTable.h"

#define Cell_Height 90.0f
@interface MyProductionViewController ()
{
    NSArray * dataSource;
    BorswerMusicTable * borswerTable;
}

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
    [self updateDataSource];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"我的制作";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setLeftAndRightBarItem];

}


-(void)updateDataSource
{
    dataSource = [PersistentStore getAllObjectWithType:[EditMusicInfo class]];
    NSInteger height = 504;
    borswerTable = [[BorswerMusicTable alloc]initWithFrame:CGRectMake(0,0, 320, height)];
    [borswerTable initailzationDataSource:dataSource cellHeight:91.0f type:[EditMusicInfo class] parentViewController:self];
    [self.view addSubview:borswerTable];
}

//
//-(void)readMusicInfo
//{
//    NSBundle* bundle = [NSBundle mainBundle];
//    NSString* path = [bundle bundlePath];
//    NSURL * fileURL=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/akon、be - you - with.mp3", path]];
//    AudioFileTypeID fileTypeHint = kAudioFileMP3Type;
//    NSString *fileExtension = [[fileURL path] pathExtension];
//    if ([fileExtension isEqual:@"mp3"]||[fileExtension isEqual:@"m4a"])
//    {
//        AudioFileID fileID  = nil;
//        OSStatus err        = noErr;
//
//        err = AudioFileOpenURL( (__bridge CFURLRef) fileURL, kAudioFileReadPermission, 0, &fileID );
//        if( err != noErr ) {
//            NSLog( @"打开文件失败" );
//        }
//        UInt32 id3DataSize  = 0;
//        err = AudioFileGetPropertyInfo( fileID, kAudioFilePropertyID3Tag, &id3DataSize, NULL );
//
//        if( err != noErr ) {
//            NSLog( @"AudioFileGetPropertyInfo failed for ID3 tag" );
//        }
//        NSDictionary *piDict = nil;
//        UInt32 piDataSize   = sizeof( piDict );
//        err = AudioFileGetProperty( fileID, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict );
//        if( err != noErr ) {
//            piDict  = nil;
//            NSLog( @"AudioFileGetProperty failed for property info dictionary" );
//        }
//        CFDataRef AlbumPic= nil;
//        UInt32 picDataSize = sizeof(picDataSize);
//        err =AudioFileGetProperty( fileID,   kAudioFilePropertyAlbumArtwork, &picDataSize, &AlbumPic);
//        if( err != noErr ) {
//            NSLog( @"Get picture failed" );
//        }
//        NSData* imagedata= (__bridge NSData*)AlbumPic;
//        UIImage* image=[[UIImage alloc]initWithData:imagedata];
//        NSString * Album = [(NSDictionary*)piDict objectForKey:
//                            [NSString stringWithUTF8String: kAFInfoDictionary_Album]];
//        NSString * Artist = [(NSDictionary*)piDict objectForKey:
//                             [NSString stringWithUTF8String: kAFInfoDictionary_Artist]];
//        NSString * Title = [(NSDictionary*)piDict objectForKey:
//                            [NSString stringWithUTF8String: kAFInfoDictionary_Title]];
//        NSLog(@"%@",Title);
//
//        NSLog(@"%@",Artist);
//
//        NSLog(@"%@",Album);
//
//    }
//}

@end
