//
//  MyDownloadViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "MyDownloadViewController.h"
#import "MyDownloadCell.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "PersistentStore.h"
#import "DownloadMusicInfo.h"
#import "GobalMethod.h"
#define Cell_Height 65.0f
@interface MyDownloadViewController ()
{
    NSArray * dataSource;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"我的下载";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setLeftAndRightBarItem];
    _tableView.backgroundColor = [UIColor clearColor];
    UINib * nib = [UINib nibWithNibName:@"MyDownloadCell" bundle:[NSBundle bundleForClass:[MyDownloadCell class]]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
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
    MyDownloadCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    DownloadMusicInfo * object = [dataSource objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = object.title;
    cell.downloadTimeLabel.text = [GobalMethod customiseTimeFormat:object.makeTime];
    
    return cell;
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
