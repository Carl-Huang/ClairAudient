//
//  FIndSoundViewController.m
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "FIndSoundViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "ControlCenter.h"
#import "TMQuiltView.h"
#import "TMCustomCell.h"
@interface FIndSoundViewController ()<TMQuiltViewDataSource,TMQuiltViewDelegate>
@property (nonatomic,strong) TMQuiltView * quiltView;
@property (nonatomic,strong) NSArray * titles;
@property (nonatomic,strong) NSArray * icons;
@end

@implementation FIndSoundViewController
#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _titles = @[@"自然音库",@"动物音库",@"海量音库",@"事件音库",@"武器大全",@"吆喝大全",@"配音地带",@"段子库",@"手机铃声",@"乡音大全"];
        _icons = @[@"FoundMusic_t",@"FoundMusic_u",@"FoundMusic_v",@"FoundMusic_w",@"FoundMusic_x",@"FoundMusic_y",@"FoundMusic_ef",@"FoundMusic_ab",@"FoundMusic_z",@"FoundMusic_cd"];
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
    [self setView:nil];
    _titles = nil;
    _icons = nil;
    _quiltView.dataSource = nil;
    _quiltView.delegate = nil;
    _quiltView = nil;
}

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"寻音";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setLeftAndRightBarItem];
    _quiltView = [[TMQuiltView alloc] initWithFrame:CGRectMake(0, 108, self.view.frame.size.width, self.view.frame.size.height - 108)];
    _quiltView.dataSource = self;
    _quiltView.delegate = self;
    _quiltView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _quiltView.showsVerticalScrollIndicator = NO;
    [_quiltView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_quiltView];
    [_quiltView reloadData];
    
}



#pragma mark - TMQuiltViewDataSource Methods

-(CGFloat)quiltView:(TMQuiltView *)quiltView heightForCellAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

-(NSInteger)quiltViewNumberOfColumns:(TMQuiltView *)quiltView
{
    return 2;
}


-(NSInteger)quiltViewNumberOfCells:(TMQuiltView *)TMQuiltView
{
    return [_titles count];
}


-(TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath
{
    
    TMCustomCell * cell = (TMCustomCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell = [[TMCustomCell alloc] initWithReuseIdentifier:@"Cell"];
    }
    
    cell.photoView.image = [UIImage imageNamed:[_icons objectAtIndex:indexPath.row]];
    cell.titleLabel.text = [_titles objectAtIndex:indexPath.row];
    return cell;
    
}


#pragma mark - TMQuiltViewDelegate Methods
-(void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    [ControlCenter showSoundCatalogVC];
}

@end
