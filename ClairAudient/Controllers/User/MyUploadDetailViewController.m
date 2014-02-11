//
//  MyUploadDetailViewController.m
//  ClairAudient
//
//  Created by vedon on 11/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MyUploadDetailViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "CycleScrollView.h"
#import "Voice.h"
#import "OSHelper.h"
@interface MyUploadDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    CycleScrollView * advertisementImageView;
    NSArray * descriptionArray;
}
@end

@implementation MyUploadDetailViewController

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
    [self setLeftAndRightBarItem];
    
    CGRect rect = self.scrollAdView.frame;
    rect.origin.x = rect.origin.y = 0;
    
    advertisementImageView = [[CycleScrollView alloc]initWithFrame:rect cycleDirection:CycleDirectionLandscape pictures:@[[UIImage imageNamed:@"testImage.png"],[UIImage imageNamed:@"testImage.png"]] autoScroll:YES];
    [self.scrollAdView addSubview:advertisementImageView];
    
    
    self.musicInfoTable.scrollEnabled = NO;
    descriptionArray = @[@"时长",@"比特率",@"采样率",@"录入时间",@"下载次数",@"用户"];
    
    [self.contentScrollView setFrame:CGRectMake(0, 0, 320, 504)];
    [self.contentScrollView setContentSize:CGSizeMake(420, 600)];
    [self.contentScrollView setBackgroundColor:[UIColor redColor]];
    self.contentScrollView.scrollEnabled = YES;

    [self.musicInfoTable setBackgroundView:nil];
    if ([OSHelper iOS7]) {
        self.musicInfoTable.separatorInset = UIEdgeInsetsZero;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.textLabel.text = self.voiceItem.bit_rate;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 80)];
    [view setBackgroundColor:[UIColor blueColor]];
    return view;
}
@end
