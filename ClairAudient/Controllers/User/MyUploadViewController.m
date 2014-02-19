//
//  MyUploadViewController.m
//  ClairAudient
//
//  Created by vedon on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "MyUploadViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "MyUploadCell.h"
#import "Voice.h"
#import "User.h"
#import "HttpService.h"
#import "MBProgressHUD.h"
#import "MyUploadDetailViewController.h"
#import "AudioStreamer.h"
#import "AudioPlayer.h"
#define Cell_Height 40.0f
@interface MyUploadViewController ()
{
    AudioPlayer * streamPlayer;
    NSThread * bufferingThread;
    NSInteger currentPlayItemIndex;
}
@property (nonatomic,strong) NSMutableArray * dataSource;
@property (strong ,nonatomic) UISlider * currentSlider;
@property (strong ,nonatomic) UIButton * currentControllBtn;
@end

@implementation MyUploadViewController
@synthesize currentSlider;
@synthesize currentControllBtn;
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
    currentPlayItemIndex = -1;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [streamPlayer stop];
    streamPlayer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"我的上传";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setLeftAndRightBarItem];
    _tableView.backgroundColor = [UIColor clearColor];
    UINib * nib = [UINib nibWithNibName:@"MyUploadCell" bundle:[NSBundle bundleForClass:[MyUploadCell class]]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    UIView * view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
    view = nil;

    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    User * user = [User userFromLocal];
    [[HttpService sharedInstance] findMyUploadByUser:@{@"userId":user.hw_id} completionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(object)
        {
            _dataSource = object;
            [_tableView reloadData];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"Request Failure");
    }];
}

-(void)playMusic:(id)sender
{
    if (currentControllBtn) {
        [currentControllBtn setSelected:NO];
    }
    currentControllBtn = (UIButton *)sender;
    [currentControllBtn setSelected:!currentControllBtn.selected];
    if (currentControllBtn.selected) {
        currentPlayItemIndex = currentControllBtn.tag;
        Voice * voice = [_dataSource objectAtIndex:currentPlayItemIndex];
        MyUploadCell * cell  = (MyUploadCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentPlayItemIndex inSection:0]];
        currentSlider = cell.playSlider;
        [self playMusicStreamWithData:voice];
    }else
    {
        if (streamPlayer) {
            [streamPlayer stop];
            streamPlayer = nil;
        }
    }
}

-(void)playMusicStreamWithData:(Voice *)object
{
    if (streamPlayer) {
        [streamPlayer stop];
        streamPlayer = nil;
    }

    __weak MyUploadViewController * weakSelf = self;
    streamPlayer = [[AudioPlayer alloc]init];
    [streamPlayer setBlock:^(double processOffset,BOOL isFinished)
     {
         
         if (processOffset > 0) {
             @try {
                 if (isFinished) {
                     weakSelf.currentSlider.value = 0.0;
                     weakSelf.currentControllBtn.selected = NO;
                 }else
                 {
                     weakSelf.currentSlider.value = processOffset;
                 }
             }
             @catch (NSException *exception) {
                 NSLog(@"%@",[exception description]);
             }
             @finally {
                 ;
             }
         }
     }];
    [streamPlayer stop];
    NSURL * musciURL = [self getMusicUrl:object.url];
    if (musciURL) {
        streamPlayer.url = musciURL;
        [streamPlayer play];
        
        if (bufferingThread) {
            if (![bufferingThread isCancelled]) {
                [bufferingThread cancel];
            }
            bufferingThread = nil;
        }
        bufferingThread = [[NSThread alloc]initWithTarget:self selector:@selector(buffering) object:nil];
        [bufferingThread start];
    }
}

-(void)buffering
{
    do {
        if ([streamPlayer.streamer isPlaying]) {
            //stop chrysanthemum
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if (![bufferingThread isCancelled]) {
                    [bufferingThread cancel];
                    bufferingThread = nil;
                }
            });
        }
    } while (bufferingThread);
    
}

-(NSURL *)getMusicUrl:(NSString *)path
{
    NSString * prefixStr = nil;
    if ([path rangeOfString:@"voice_data"].location!= NSNotFound) {
        prefixStr = SoundValleyPrefix;
    }else
    {
        prefixStr = VoccPrefix;
    }
    NSURL * url = [NSURL URLWithString:[prefixStr stringByAppendingString:path]];
    return url;
}
#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Cell_Height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyUploadCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell.playSlider setThumbImage:[UIImage imageNamed:@"record_20"] forState:UIControlStateNormal];
    [cell.playSlider setThumbImage:[UIImage imageNamed:@"record_20"] forState:UIControlStateHighlighted];
    [cell.playSlider setMinimumTrackImage:[UIImage imageNamed:@"record_19"] forState:UIControlStateNormal];
    [cell.playSlider setMaximumTrackImage:[UIImage imageNamed:@"record_19"] forState:UIControlStateNormal];
    Voice * voice = [_dataSource objectAtIndex:indexPath.row];
    cell.nameLabel.text = voice.vl_name;
    cell.controlButton.tag = indexPath.row;
    cell.downloadNumberCount.text = voice.download_num;
    
    if (indexPath.row != currentPlayItemIndex) {
        cell.playSlider.value = 0.0;
        cell.controlButton.selected = NO;
    }else
    {
        cell.playSlider.value = currentSlider.value;
        currentSlider = cell.playSlider;
        cell.controlButton.selected = YES;
    }
    
    [cell.controlButton addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Voice * voice = [_dataSource objectAtIndex:indexPath.row];
    MyUploadDetailViewController * viewController = [[MyUploadDetailViewController alloc]initWithNibName:@"MyUploadDetailViewController" bundle:nil];
    [viewController setVoiceItem:voice];
    [self push:viewController];
    viewController = nil;
}


@end
