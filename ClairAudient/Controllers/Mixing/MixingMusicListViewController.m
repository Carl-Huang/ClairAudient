//
//  MixingMusicListViewController.m
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "MixingMusicListViewController.h"
#import "MixingMusicListCell.h"
#import "ControlCenter.h"
#define Cell_Height 65.0f
@interface MixingMusicListViewController ()

@end

@implementation MixingMusicListViewController

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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _tableView.backgroundColor = [UIColor clearColor];
    UINib * nib = [UINib nibWithNibName:@"MixingMusicListCell" bundle:[NSBundle bundleForClass:[MixingMusicListCell class]]];
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
    MixingMusicListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    return cell;
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ControlCenter showSoundEffectVC];
}

#pragma mark -
- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}
@end
