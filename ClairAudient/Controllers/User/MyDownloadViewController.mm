//
//  MyDownloadViewController.m
//  ClairAudient
//
//  Created by vedon on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "MyDownloadViewController.h"
#import "MyDownloadCell.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "DownloadMusicInfo.h"
#import "GobalMethod.h"
#import "PersistentStore.h"
#define Cell_Height 91.0f

#import "BorswerMusicTable.h"
@interface MyDownloadViewController ()<ItemDidSelectedDelegate>
{
    NSArray * dataSource;
    CGFloat currentPlayFileLength;

    NSString * currentPlayItem;
    
    BorswerMusicTable * borswerTable;
}
@end

@implementation MyDownloadViewController
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
   
    dataSource = [PersistentStore getAllObjectWithType:[DownloadMusicInfo class]];
    
    NSInteger height = 504;
    if (![OSHelper iPhone5]) {
        height  -=88;
    }
    borswerTable = [[BorswerMusicTable alloc]initWithFrame:CGRectMake(0, 0, 320, height)];
    [borswerTable initailzationDataSource:dataSource cellHeight:91.0f type:[DownloadMusicInfo class] parentViewController:self];
    [self.view addSubview:borswerTable];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [borswerTable stopPlayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"我的下载";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setLeftAndRightBarItem];

}

@end
