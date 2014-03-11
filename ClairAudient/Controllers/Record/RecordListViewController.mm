//
//  RecordListViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-18.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "RecordListViewController.h"
#import "RecordListCell.h"
#import "ShareViewController.h"
#import "RecordMusicInfo.h"
#import "PersistentStore.h"
#import "BorswerMusicTable.h"

#define Cell_Height 90.0f
@interface RecordListViewController ()
{
    NSArray * dataSource;
    
    BorswerMusicTable * borswerTable;
    
}
@end

@implementation RecordListViewController

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
    [self updateDataSource];
}

-(void)viewWillDisappear:(BOOL)animated
{
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self setView:nil];
}


#pragma mark - Private Methods

-(void)updateDataSource
{
    dataSource = [PersistentStore getAllObjectWithType:[RecordMusicInfo class]];
    
    NSInteger height = 504;
    NSInteger orginalY = 70;
    if (![OSHelper iPhone5]) {
        height  -=88;
    }
    if (![OSHelper iOS7]) {
        orginalY -=20;
    }
    borswerTable = [[BorswerMusicTable alloc]initWithFrame:CGRectMake(0,orginalY, 320, height)];
    [borswerTable initailzationDataSource:dataSource cellHeight:91.0f type:[RecordMusicInfo class] parentViewController:self];
    [self.view addSubview:borswerTable];
    
}

#pragma mark - Action Methods
- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}

- (IBAction)rightItemAction:(id)sender
{
    
}

@end
