//
//  CatalogRankViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-8.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CatalogRankViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "CatalogRankCell.h"
#define Section_Height 54.0f
#define Cell_Height 55.0f
@interface CatalogRankViewController ()

@end

@implementation CatalogRankViewController
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.view = nil;
}

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"分类排行";
    [self setLeftAndRightBarItem];
    UINib * nib = [UINib nibWithNibName:@"CatalogRankCell" bundle:[NSBundle bundleForClass:[CatalogRankCell class]]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    _tableView.backgroundColor = [UIColor clearColor];

}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return Section_Height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Cell_Height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"CatalogRankSectionHeader" owner:nil options:nil];
    UIView * view = [views objectAtIndex:0];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CatalogRankCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
