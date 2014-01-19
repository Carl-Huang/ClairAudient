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
#import "ControlCenter.h"
#import "HttpService.h"
#import "MBProgressHUD.h"
#import "IntegralRankUser.h"
#define Cell_Height 50.0f
@interface IntegralChampionViewController ()
@property (nonatomic,strong) NSArray * sortImages;
@property (nonatomic,strong) NSArray * dataSource;
@end

@implementation IntegralChampionViewController
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance] findIntegralRankUserWithCompletionBlock:^(id object) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(object)
        {
            _dataSource = object;
            [_tableView reloadData];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"Request Failure!");
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
    IntegralChampionCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(indexPath.row <= [_sortImages count] - 1)
    {
        cell.sortImageView.image = [UIImage imageNamed:[_sortImages objectAtIndex:indexPath.row]];
    }
    IntegralRankUser * user = [_dataSource objectAtIndex:indexPath.row];
    cell.nameLabel.text = user.username;
    cell.integralLabel.text = [user.integral stringByAppendingString:@"分"];
    return cell;
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ControlCenter showChampionHomePageVC];
}

@end
