//
//  MyUploadViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-12.
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
#define Cell_Height 65.0f
@interface MyUploadViewController ()
@property (nonatomic,strong) NSMutableArray * dataSource;
@end

@implementation MyUploadViewController
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
