//
//  DownloadRankViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-8.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "DownloadRankViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "DownloadRankCell.h"
#import "HttpService.h"
#import "MBProgressHUD.h"
#import "Voice.h"
#import "MyUploadDetailViewController.h"
#define Cell_Height 50.0f
@interface DownloadRankViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray * sortImages;
@property (nonatomic,strong) NSArray * dataSource;
@end

@implementation DownloadRankViewController
#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _sortImages = @[@"MusicFans_one",@"MusicFans_two",@"MusicFans_three",@"MusicFans_four",@"MusicFans_five",@"MusicFans_six",@"MusicFans_seven",@"MusicFans_eight",@"MusicFans_nine",@"MusicFans_ten"];
        _dataSource = [NSArray array];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self setView:nil];
}

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"下载排行";
    [self setLeftAndRightBarItem];
    _tableView.backgroundColor = [UIColor clearColor];
    UINib * nib = [UINib nibWithNibName:@"DownloadRankCell" bundle:[NSBundle bundleForClass:[DownloadRankCell class]]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    UIView * view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
    view = nil;

    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance] findDownloadRankVoiceWithCompletionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(object)
        {
            _dataSource = object;
            [_tableView reloadData];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"Request Failure.");
    }];
}


#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_dataSource count] > 10)
    {
        return 10;
    }
    return [_dataSource count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Cell_Height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadRankCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(indexPath.row <= [_sortImages count] - 1)
    {
        cell.sortImageView.image = [UIImage imageNamed:[_sortImages objectAtIndex:indexPath.row]];
    }
    Voice * voice = [_dataSource objectAtIndex:indexPath.row];
    cell.nameLabel.text = voice.vl_name;
    cell.downloadCountLabel.text = [NSString stringWithFormat:@"下载%@次",voice.download_num];
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
