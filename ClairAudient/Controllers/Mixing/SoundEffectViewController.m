//
//  SoundEffectViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-16.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "SoundEffectViewController.h"
#import "TMQuiltView.h"
#import "TMSoundEffectCell.h"
@interface SoundEffectViewController () <TMQuiltViewDataSource,TMQuiltViewDelegate>
@property (nonatomic,strong) TMQuiltView * tmQuiltView;
@property (nonatomic,strong) NSArray * dataSource;
@property (nonatomic,strong) NSArray * icons;
@end

@implementation SoundEffectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = @[@"网络链接",@"欢快",@"前奏",@"科幻音效",@"DJ音效",@"电子设备",@"办公音效",@"运动音效",@"卡通音效",@"生活音效",@"节日音效",@"交通音效",@"乐器音效",@"打斗音效",@"战争音效",@"人物音效",@"经典配音",@"配音星库",@"紧张音效",@""];
        _icons = @[@"hunyin_24",@"hunyin_25",@"hunyin_26",@"hunyin_29",@"hunyin_28",@"hunyin_27",@"hunyin_30",@"hunyin_31",@"hunyin_32",@"hunyin_36",@"hunyin_35",@"hunyin_33",@"hunyin_37",@"hunyin_38",@"hunyin_39",@"hunyin_42",@"hunyin_41",@"hunyin_40",@"hunyin_43",@"hunyin_44"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tmQuiltView = [[TMQuiltView alloc] initWithFrame:CGRectMake(10, 75, 300, _containView.frame.size.height - 75)];
    _tmQuiltView.dataSource = self;
    _tmQuiltView.delegate = self;
    _tmQuiltView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tmQuiltView.showsVerticalScrollIndicator = NO;
    [_tmQuiltView setBackgroundColor:[UIColor clearColor]];
    [_containView addSubview:_tmQuiltView];
    [_tmQuiltView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self setView:nil];
    _dataSource = nil;
    _icons = nil;
    _tmQuiltView.delegate = nil;
    _tmQuiltView.dataSource = nil;
    _tmQuiltView = nil;
}
#pragma mark - Action Methods
- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}



#pragma mark - TMQuiltViewDataSource Methods

-(CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}

-(NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView
{
    return 3;
}


-(NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView
{
    return [_dataSource count];
}


-(TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath
{
    TMSoundEffectCell * cell = (TMSoundEffectCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell = [[TMSoundEffectCell alloc] initWithReuseIdentifier:@"Cell"];
    }
    
    cell.iconImageView.image =[UIImage imageNamed:[_icons objectAtIndex:indexPath.row]];
    cell.titleLabel.text = [_dataSource objectAtIndex:indexPath.row];
    [[cell viewWithTag:5] removeFromSuperview];
    if(indexPath.row == [_dataSource count] - 1)
    {
        cell.iconImageView.image = nil;
        UIImageView * addView = [[UIImageView alloc] initWithFrame:CGRectMake(36, 10, 22, 22)];
        addView.image = [UIImage imageNamed:[_icons objectAtIndex:indexPath.row]];
        addView.contentMode = UIViewContentModeScaleAspectFit;
        addView.tag = 5;
        [cell addSubview:addView];
        addView = nil;
    }
    return cell;
}


#pragma mark - TMQuiltViewDelegate Methods
-(void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{

}
@end
