//
//  SearchResultViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-25.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "SearchResultViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "SoundCatalogCell.h"
#import "Voice.h"
#import "ControlCenter.h"
#define Cell_Height 44.0f
@interface SearchResultViewController ()

@end

@implementation SearchResultViewController
#pragma mark - Life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if(_voices == nil)
            _voices = [NSArray array];
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

#pragma mark - Private Methods

- (void)initUI
{
    self.title = @"搜索结果";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setLeftAndRightBarItem];
    _tableView.backgroundColor = [UIColor clearColor];
    UINib * nib = [UINib nibWithNibName:@"SoundCatalogCell" bundle:[NSBundle bundleForClass:[SoundCatalogCell class]]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    UIView * footView = [UIView new];
    footView.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:footView];
    footView = nil;
    
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [_voices count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Cell_Height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SoundCatalogCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Voice * voice = [_voices objectAtIndex:indexPath.row];
    cell.nameLabel.text = voice.vl_name;
    cell.downloadCountLabel.text = [NSString stringWithFormat:@"下载%@次",voice.download_num];
    return cell;
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    Voice * voice = [_voices objectAtIndex:indexPath.row];
    [ControlCenter showVoiceVC:voice];
}




@end
