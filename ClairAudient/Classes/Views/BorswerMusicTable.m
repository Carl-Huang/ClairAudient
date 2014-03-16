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
#import <ShareSDK/ShareSDK.h>

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
    
//    UIImage *minImage =     [[UIImage imageNamed:@"sliderLine"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 30, 5, 200)];
    
    
    borswerDataSource = data;
    cell_Height = cellHeight;
    _type = objectType;
    
    UINib * nib = [UINib nibWithNibName:@"MyDownloadCell" bundle:[NSBundle bundleForClass:[MyDownloadCell class]]];
    [self registerNib:nib forCellReuseIdentifier:@"Cell"];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundView:nil];
    self.dataSource = self;
    self.delegate  = self;
#ifdef IOS7_SDK_AVAILABLE
    if ([OSHelper iOS7]) {
        self.separatorInset = UIEdgeInsetsZero;
    }
#endif
    
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
       
    }
//    [myDelegate playItemWithURL:inputFileURL withMusicInfo:nil withPlaylist:nil];
//    currentSelectedItemSlider.maximumValue = myDelegate.audioTotalFrame;
//    [currentSelectedItemSlider addTarget:self action:@selector(updateCurrentPlayMusicPosition:) forControlEvents:UIControlEventTouchUpInside];
//    currentSelectedItemSlider.continuous = NO;
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateProcessingLocation:) name:CurrentPlayFilePostionInfo object:nil];
    
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
        NSLog(@"seeking");
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
    cell.playTimeLabel.text     = [GobalMethod getMusicLength:musicURL];
    
    cell.delegate               = self;
    cell.musicInfo              = object;
    
    cell.playSlider.value = 0.0f;
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
        [uploadView setMusicInfo:@{@"Title": [info valueForKey:@"title"],@"musicLength":[info valueForKey:@"length"]}];
        encodeStr = nil;
        [myDelegate.window addSubview:uploadView];
    }else
    {
        //
    }
}

-(void)addToFavorite:(id)object
{
    id sender = [object valueForKey:@"Sender"];
    NSString * CONTENT = @"hello";
    //分享
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"" ofType:@"png"];
        
        //构造分享内容
        id<ISSContent> publishContent = [ShareSDK content:CONTENT
                                           defaultContent:@""
                                                    image:[ShareSDK imageWithPath:imagePath]
                                                    title:@"ShareSDK"
                                                      url:@"http://www.sharesdk.cn"
                                              description:@"这是一条测试信息"
                                                mediaType:SSPublishContentMediaTypeNews];
        
        ///////////////////////
        //以下信息为特定平台需要定义分享内容，如果不需要可省略下面的添加方法
        
        //定制人人网信息
        [publishContent addRenRenUnitWithName:@"Hello 人人网"
                                  description:INHERIT_VALUE
                                          url:INHERIT_VALUE
                                      message:INHERIT_VALUE
                                        image:INHERIT_VALUE
                                      caption:nil];
        //定制QQ空间信息
        [publishContent addQQSpaceUnitWithTitle:@"Hello QQ空间"
                                            url:INHERIT_VALUE
                                           site:nil
                                        fromUrl:nil
                                        comment:INHERIT_VALUE
                                        summary:INHERIT_VALUE
                                          image:INHERIT_VALUE
                                           type:INHERIT_VALUE
                                        playUrl:nil
                                           nswb:nil];
        
        //定制微信好友信息
        [publishContent addWeixinSessionUnitWithType:INHERIT_VALUE
                                             content:INHERIT_VALUE
                                               title:@"Hello 微信好友!"
                                                 url:INHERIT_VALUE
                                          thumbImage:[ShareSDK imageWithUrl:@"http://img1.bdstatic.com/img/image/67037d3d539b6003af38f5c4c4f372ac65c1038b63f.jpg"]
                                               image:INHERIT_VALUE
                                        musicFileUrl:nil
                                             extInfo:nil
                                            fileData:nil
                                        emoticonData:nil];
        
        //定制微信朋友圈信息
        [publishContent addWeixinTimelineUnitWithType:[NSNumber numberWithInteger:SSPublishContentMediaTypeMusic]
                                              content:INHERIT_VALUE
                                                title:@"Hello 微信朋友圈!"
                                                  url:@"http://y.qq.com/i/song.html#p=7B22736F6E675F4E616D65223A22E4BDA0E4B88DE698AFE79C9FE6ADA3E79A84E5BFABE4B990222C22736F6E675F5761704C69766555524C223A22687474703A2F2F74736D7573696332342E74632E71712E636F6D2F586B303051563558484A645574315070536F4B7458796931667443755A68646C2F316F5A4465637734356375386355672B474B304964794E6A3770633447524A574C48795333383D2F3634363232332E6D34613F7569643D32333230303738313038266469723D423226663D312663743D3026636869643D222C22736F6E675F5769666955524C223A22687474703A2F2F73747265616D31382E71716D757369632E71712E636F6D2F33303634363232332E6D7033222C226E657454797065223A2277696669222C22736F6E675F416C62756D223A22E5889BE980A0EFBC9AE5B08FE5B7A8E89B8B444E414C495645EFBC81E6BC94E594B1E4BC9AE5889BE7BAAAE5BD95E99FB3222C22736F6E675F4944223A3634363232332C22736F6E675F54797065223A312C22736F6E675F53696E676572223A22E4BA94E69C88E5A4A9222C22736F6E675F576170446F776E4C6F616455524C223A22687474703A2F2F74736D757369633132382E74632E71712E636F6D2F586C464E4D31354C5569396961495674593739786D436534456B5275696879366A702F674B65356E4D6E684178494C73484D6C6A307849634A454B394568572F4E3978464B316368316F37636848323568413D3D2F33303634363232332E6D70333F7569643D32333230303738313038266469723D423226663D302663743D3026636869643D2673747265616D5F706F733D38227D"
                                           thumbImage:[ShareSDK imageWithUrl:@"http://img1.bdstatic.com/img/image/67037d3d539b6003af38f5c4c4f372ac65c1038b63f.jpg"]
                                                image:INHERIT_VALUE
                                         musicFileUrl:@"http://mp3.mwap8.com/destdir/Music/2009/20090601/ZuiXuanMinZuFeng20090601119.mp3"
                                              extInfo:nil
                                             fileData:nil
                                         emoticonData:nil];
        
        //定制QQ分享信息
        [publishContent addQQUnitWithType:INHERIT_VALUE
                                  content:INHERIT_VALUE
                                    title:@"Hello QQ!"
                                      url:INHERIT_VALUE
                                    image:INHERIT_VALUE];
        
        //定制邮件信息
        [publishContent addMailUnitWithSubject:@"Hello Mail"
                                       content:INHERIT_VALUE
                                        isHTML:[NSNumber numberWithBool:YES]
                                   attachments:INHERIT_VALUE
                                            to:nil
                                            cc:nil
                                           bcc:nil];
        
        //定制短信信息
        [publishContent addSMSUnitWithContent:@"Hello SMS"];
        
        //定制有道云笔记信息
        [publishContent addYouDaoNoteUnitWithContent:INHERIT_VALUE
                                               title:@"Hello 有道云笔记"
                                              author:@"ShareSDK"
                                              source:nil
                                         attachments:INHERIT_VALUE];
        
        //定制Instapaper信息
        [publishContent addInstapaperContentWithUrl:INHERIT_VALUE
                                              title:@"Hello Instapaper"
                                        description:INHERIT_VALUE];
        
        //定制搜狐随身看信息
        [publishContent addSohuKanUnitWithUrl:INHERIT_VALUE];
        
        //定制Pinterest信息
        [publishContent addPinterestUnitWithImage:[ShareSDK imageWithUrl:@"http://img1.bdstatic.com/img/image/67037d3d539b6003af38f5c4c4f372ac65c1038b63f.jpg"]
                                              url:INHERIT_VALUE
                                      description:INHERIT_VALUE];
        
        //定制易信好友信息
        [publishContent addYiXinSessionUnitWithType:INHERIT_VALUE
                                            content:INHERIT_VALUE
                                              title:INHERIT_VALUE
                                                url:INHERIT_VALUE
                                         thumbImage:[ShareSDK imageWithUrl:@"http://img1.bdstatic.com/img/image/67037d3d539b6003af38f5c4c4f372ac65c1038b63f.jpg"]
                                              image:INHERIT_VALUE
                                       musicFileUrl:INHERIT_VALUE
                                            extInfo:INHERIT_VALUE
                                           fileData:INHERIT_VALUE];
        
        
        //定义易信朋友圈信息
        [publishContent addYiXinTimelineUnitWithType:INHERIT_VALUE
                                             content:INHERIT_VALUE
                                               title:INHERIT_VALUE
                                                 url:INHERIT_VALUE
                                          thumbImage:[ShareSDK imageWithUrl:@"http://img1.bdstatic.com/img/image/67037d3d539b6003af38f5c4c4f372ac65c1038b63f.jpg"]
                                               image:INHERIT_VALUE
                                        musicFileUrl:INHERIT_VALUE
                                             extInfo:INHERIT_VALUE
                                            fileData:INHERIT_VALUE];
        
        //结束定制信息
        ////////////////////////
        
        
        //创建弹出菜单容器
        id<ISSContainer> container = [ShareSDK container];
        [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
        
        id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                             allowCallback:NO
                                                             authViewStyle:SSAuthViewStyleFullScreenPopup
                                                              viewDelegate:nil
                                                   authManagerViewDelegate:nil];
        //在授权页面中添加关注官方微博
        [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                        SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                        [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                        SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                        nil]];
        
        id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:@"内容分享"
                                                                  oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                                   qqButtonHidden:YES
                                                            wxSessionButtonHidden:YES
                                                           wxTimelineButtonHidden:YES
                                                             showKeyboardOnAppear:NO
                                                                shareViewDelegate:nil
                                                              friendsViewDelegate:nil
                                                            picViewerViewDelegate:nil];
        
        //弹出分享菜单
        [ShareSDK showShareActionSheet:container
                             shareList:nil
                               content:publishContent
                         statusBarTips:YES
                           authOptions:authOptions
                          shareOptions:shareOptions
                                result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                    
                                    if (state == SSResponseStateSuccess)
                                    {
                                        NSLog(@"分享成功");
                                    }
                                    else if (state == SSResponseStateFail)
                                    {
                                        NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                    }
                                }];
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
