//
//  SoundEffectViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-16.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "SoundEffectViewController.h"

@interface SoundEffectViewController ()
@property (nonatomic,strong) NSArray * dataSource;
@property (nonatomic,strong) NSArray * icons;
@end

@implementation SoundEffectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = @[@"网络链接",@"欢快",@"前奏",@"科幻音效",@"DJ音效",@"电子设备",@"办公音效",@"运动音效",@"卡通音效",@"生活音效",@"节日音效",@"交通音效",@"乐器音效",@"打斗音效",@"战争音效",@"人物音效",@"经典配音",@"配音星库",@"紧张音效"];
        _icons = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods
- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}
@end
