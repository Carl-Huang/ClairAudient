//
//  FIndSoundViewController.m
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "MixingEffectViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "ControlCenter.h"
#import "TMQuiltView.h"
#import "TMCustomCell.h"
#import "MBProgressHUD.h"
#import "HttpService.h"
#import "Catalog.h"
#import "MixingCatalogViewController.h"
#import "LocalMusicViewController.h"

@interface MixingEffectViewController ()<TMQuiltViewDataSource,TMQuiltViewDelegate>
@property (nonatomic,strong) TMQuiltView * quiltView;
@property (nonatomic,strong) NSMutableArray * catalogs;
@property (nonatomic,strong) NSArray * icons;
@end

@implementation MixingEffectViewController
#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //_catalogs = @[@"自然音库",@"动物音库",@"海量音库",@"事件音库",@"武器大全",@"吆喝大全",@"配音地带",@"段子库",@"手机铃声",@"乡音大全"];
        _catalogs = [NSMutableArray arrayWithObject:@"本地音乐"];
        _icons = @[@"FoundMusic_t",@"catalog_icon_gpng",@"catalog_icon_hpng",@"catalog_icon_bpng",@"catalog_icon_kpng",@"catalog_icon_fpng",@"catalog_icon_epng",@"catalog_icon_jpng",@"catalog_icon_cpng",@"catalog_icon_apng",@"catalog_icon_lpng",@"catalog_icon_dpng"];
    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    [self initUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self setView:nil];
    _catalogs = nil;
    _icons = nil;
    _quiltView.dataSource = nil;
    _quiltView.delegate = nil;
    _quiltView = nil;
}

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"寻音";

    [self setLeftAndRightBarItem];
    _quiltView = [[TMQuiltView alloc] initWithFrame:CGRectMake(0, 108, self.view.frame.size.width, self.view.frame.size.height - 108)];
    _quiltView.dataSource = self;
    _quiltView.delegate = self;
    _quiltView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _quiltView.showsVerticalScrollIndicator = NO;
    [_quiltView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_quiltView];
    //[_quiltView reloadData];
    
    if ([OSHelper isReachable]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[HttpService sharedInstance] findCatalog:@{@"parentId":@"0"} completionBlock:^(id obj) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(obj)
            {
                [_catalogs addObjectsFromArray:obj];
                [_quiltView reloadData];
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }else
    {
        //网络问题

    }
   
    
}

- (IBAction)searchAction:(id)sender
{
    [_searchField resignFirstResponder];
    NSString * text = [[_searchField text] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if([text length] == 0) return;
    
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在加载数据";
    [[HttpService sharedInstance] searchVocie:@{@"vlName":text} completionBlock:^(id object) {
        if(object == nil || [object count] == 0)
        {
            hud.labelText = @"无相关资源";
            [hud hide:YES afterDelay:1.5];
            return ;
        }
        [hud hide:YES];
        [ControlCenter showSearchResultVC:object];
    } failureBlock:^(NSError *error, NSString *responseString) {
        hud.labelText = @"加载失败";
        [hud hide:YES afterDelay:1.5];
    }];
}

- (IBAction)finishType:(id)sender
{
    [_searchField resignFirstResponder];
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
    if([_catalogs count] <= [_icons count])
    {
        return [_catalogs count];
    }
    return [_icons count];
}


-(TMQuiltViewCell *)quiltView:(TMQuiltView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath
{
    
    TMCustomCell * cell = (TMCustomCell *)[quiltView dequeueReusableCellWithReuseIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell = [[TMCustomCell alloc] initWithReuseIdentifier:@"Cell"];
    }
    if (indexPath.row == 0) {
        cell.photoView.image = [UIImage imageNamed:[_icons objectAtIndex:indexPath.row]];
        //cell.photoView.image = [UIImage imageNamed:@"FoundMusic_t"];
        cell.titleLabel.text = [_catalogs objectAtIndex:indexPath.row];

    }else
    {
        cell.photoView.image = [UIImage imageNamed:[_icons objectAtIndex:indexPath.row]];
        //cell.photoView.image = [UIImage imageNamed:@"FoundMusic_t"];
        Catalog * catalog = [_catalogs objectAtIndex:indexPath.row];
        cell.titleLabel.text = catalog.vlt_name;
    }
    
    return cell;
    
}


#pragma mark - TMQuiltViewDelegate Methods
-(void)quiltView:(TMQuiltView *)quiltView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        LocalMusicViewController * viewController = [[LocalMusicViewController alloc]initWithNibName:@"LocalMusicViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
        viewController = nil;
    }else
    {
        Catalog * catalog = [_catalogs objectAtIndex:indexPath.row];
        MixingCatalogViewController * vc = [[MixingCatalogViewController alloc]initWithNibName:@"MixingCatalogViewController" bundle:nil];
        [vc setParentCatalog:catalog];
        [self push:vc];
        vc = nil;
    }

}

@end
