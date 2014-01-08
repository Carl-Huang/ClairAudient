//
//  IntegralChampionViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-8.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "IntegralChampionViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "IntegralChampionCell.h"
#define Cell_Height 50.0f
@interface IntegralChampionViewController ()
@property (nonatomic,strong) NSArray * sortImages;
@end

@implementation IntegralChampionViewController
#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _sortImages = @[@"MusicFans_one",@"MusicFans_two",@"MusicFans_three",@"MusicFans_four",@"MusicFans_five",@"MusicFans_six",@"MusicFans_seven",@"MusicFans_eight",@"MusicFans_nine",@"MusicFans_ten"];
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
    self.title = @"积分冠军";
    [self setLeftAndRightBarItem];
    _tableView.backgroundColor = [UIColor clearColor];
    UINib * nib = [UINib nibWithNibName:@"IntegralChampionCell" bundle:[NSBundle bundleForClass:[IntegralChampionCell class]]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Cell_Height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IntegralChampionCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(indexPath.row <= [_sortImages count] - 1)
    {
        cell.sortImageView.image = [UIImage imageNamed:[_sortImages objectAtIndex:indexPath.row]];
    }
    return cell;
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
