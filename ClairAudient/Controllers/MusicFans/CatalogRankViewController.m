//
//  CatalogRankViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-8.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CatalogRankViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "CatalogRankCell.h"
#import "HttpService.h"
#import "MBProgressHUD.h"
#import "Catalog.h"
#import "Voice.h"
#define Section_Height 54.0f
#define Cell_Height 55.0f
@interface CatalogRankViewController ()
@property (nonatomic,strong) NSArray * catalogs;
@property (nonatomic,strong) NSMutableDictionary * catalogSoundsInfo;
@property (nonatomic,strong) Catalog * selectedCatalog;
@end

@implementation CatalogRankViewController
#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _catalogs = [NSArray array];
        _catalogSoundsInfo = [NSMutableDictionary dictionary];
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
    self.title = @"分类排行";
    [self setLeftAndRightBarItem];
    UINib * nib = [UINib nibWithNibName:@"CatalogRankCell" bundle:[NSBundle bundleForClass:[CatalogRankCell class]]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    _tableView.backgroundColor = [UIColor clearColor];
    UIView * view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
    view = nil;

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[HttpService sharedInstance] findCatalog:@{@"parentId":@"0"} completionBlock:^(id object) {
        if(object)
        {
            _catalogs = object;
            for(Catalog * catalog in _catalogs)
            {
                [_catalogSoundsInfo setObject:[NSArray array] forKey:catalog.vlt_name];
            }
            
            [_tableView reloadData];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failureBlock:^(NSError *error, NSString *responseString) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];

}

#pragma mark - Action Methods
- (void)tapSection:(UITapGestureRecognizer *)gesture
{
    UIView * view = gesture.view;
    int section = view.tag;
    Catalog * catalog = [_catalogs objectAtIndex:section];
    if(catalog == self.selectedCatalog)
    {
        self.selectedCatalog = nil;
        [_tableView reloadData];
        return;
    }
    
    self.selectedCatalog = catalog;
    NSArray * voices = [_catalogSoundsInfo objectForKey:self.selectedCatalog.vlt_name];
    if([voices count] == 0)
    {
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"正在加载";
        [[HttpService sharedInstance] findCatalogRankVoice:@{@"parentId":self.selectedCatalog.vlt_id} completionBlock:^(id object) {
            [hud hide:YES];
            
            if(object)
            {
                [_catalogSoundsInfo setObject:object forKey:self.selectedCatalog.vlt_name];
                [_tableView reloadData];
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            hud.labelText = @"加载失败";
            [hud hide:YES afterDelay:2];
        }];
    }
    
    [_tableView reloadData];
}


#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_catalogs count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Catalog * catalog = [_catalogs objectAtIndex:section];
    if(catalog == self.selectedCatalog)
    {
        NSArray * voices = [_catalogSoundsInfo objectForKey:self.selectedCatalog.vlt_name];
        return [voices count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return Section_Height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Cell_Height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"CatalogRankSectionHeader" owner:nil options:nil];
    UIView * view = [views objectAtIndex:0];
    view.tag = section;
    UILabel * label = (UILabel *)[view viewWithTag:1001];
    UIImageView * imageView = (UIImageView *)[view viewWithTag:1002];
    Catalog * catalog = [_catalogs objectAtIndex:section];
    if(catalog == self.selectedCatalog)
    {
        imageView.image = [UIImage imageNamed:@"MusicFans_ij"];
    }
    else
    {
        imageView.image = [UIImage imageNamed:@"MusicFans_cv"];
    }
    label.text = catalog.vlt_name;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSection:)];
    [view addGestureRecognizer:tapGesture];
    view.userInteractionEnabled = YES;
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CatalogRankCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Catalog * catalog = [_catalogs objectAtIndex:indexPath.section];
    NSArray * voices = [_catalogSoundsInfo objectForKey:catalog.vlt_name];
    Voice * voice = [voices objectAtIndex:indexPath.row];
    cell.soundNameLabel.text = voice.vl_name;
    cell.downloadCountLabel.text = [NSString stringWithFormat:@"下载%@次",voice.download_num];
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
