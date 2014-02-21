//
//  SoundCatalogViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-10.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "MixingCatalogViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "SoundCatalogCell.h"
#import "Catalog.h"
#import "HttpService.h"
#import "MBProgressHUD.h"
#import "Voice.h"
#import "ControlCenter.h"
#import "TSPopoverController.h"
#import "SortPopoverViewController.h"
#import "DownloadMusicInfo.h"
#import "PersistentStore.h"
#import "GobalMethod.h"
#import "MixingMusicOnlineCell.h"



#define Section_Height 48.0f
#define Cell_Height 44.0f
@interface MixingCatalogViewController ()<SortPopoverViewControllerDelegate,UIAlertViewDelegate>
{
    Catalog * currentSelectedCatalog;
    Voice * currentSelectedItem;
    
    BOOL isDowning;
}
@property (nonatomic,strong) NSArray * catalogs;
@property (nonatomic,strong) NSMutableDictionary * catalogSoundsInfo;
@property (nonatomic,strong) Catalog * selectedCatalog;
@property (nonatomic,strong) TSPopoverController * tsPopoverController;
@property (nonatomic,strong) NSArray * sortArr_1, * sortArr_2, * sortArr_3;
@property (nonatomic,assign) BOOL isSortConditionChange;
@end

@implementation MixingCatalogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _catalogs = [NSArray array];
        _catalogSoundsInfo = [NSMutableDictionary dictionary];
        _sortArr_1 = @[@"上传时间",@"下载次数",@"星级排名"];
        _sortArr_2 = @[@"比特率",@"8-bit",@"16-bit"];
        _sortArr_3 = @[@"采样率",@"8000HZ",@"11025HZ",@"22050HZ",@"44100HZ"];
        self.isSortConditionChange = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    currentSelectedCatalog = nil;
    isDowning = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self dismissPopoverController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
- (void)initUI
{
    if(self.parentCatalog)
    {
        self.title = self.parentCatalog.vlt_name;
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setLeftAndRightBarItem];
    _tableView.backgroundColor = [UIColor clearColor];
    UINib * nib = [UINib nibWithNibName:@"MixingMusicOnlineCell" bundle:[NSBundle bundleForClass:[MixingMusicOnlineCell class]]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    UIView * footView = [UIView new];
    footView.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:footView];
    footView = nil;
    if(self.parentCatalog)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[HttpService sharedInstance] findCatalog:@{@"parentId":self.parentCatalog.vlt_id} completionBlock:^(id object) {
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
    
}

-(void)startDownloadMusicWithObj:(NSDictionary *)musicObj completedBlock:(void (^)(NSError * error,NSDictionary * info))block;
{
    NSString * url = [musicObj valueForKey:@"URL"];
    NSURLRequest * request = [NSURLRequest requestWithURL:[GobalMethod getMusicUrl:url]];
    NSString * fileExtention = [url pathExtension];
    
    NSString * fileName = [[musicObj valueForKey:@"Name"]stringByAppendingPathExtension:fileExtention];
    if (request) {
        __weak MixingCatalogViewController * weakSelf = self;
        
        [GobalMethod getExportPath:fileName completedBlock:^(BOOL isDownloaded, NSString *exportFilePath) {
            if (isDownloaded) {
                [self showAlertViewWithMessage:@"已经下载"];
            }else
            {
                AFURLConnectionOperation * downloadOperation = [[AFURLConnectionOperation alloc]initWithRequest:request];
                downloadOperation.completionBlock = ^()
                {
                    //下载完成
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showAlertViewWithMessage:@"下载完成"];
                        block (nil,nil);
                        CGFloat musicLength = [GobalMethod getMusicLength:[NSURL fileURLWithPath:exportFilePath]];
                        DownloadMusicInfo * info = [DownloadMusicInfo MR_createEntity];
                        info.title    = [musicObj valueForKey:@"Name"];
                        info.makeTime = [GobalMethod getMakeTime];
                        info.localPath= exportFilePath;
                        info.length   = [NSString stringWithFormat:@"%0.2f",musicLength];
                        info.isFavorite = @"0";
                        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
                        
                    });
                };
                downloadOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:exportFilePath append:NO];
                [downloadOperation start];
            }
            
        }];
    }else
    {
        //文件路径错误
    }
}

-(void)editMusic:(id)sender
{
    MixingOnlineBtn * btn = (MixingOnlineBtn *)sender;
    currentSelectedCatalog = [_catalogs objectAtIndex:btn.index.section];
     NSArray * voices = [_catalogSoundsInfo objectForKey:currentSelectedCatalog.vlt_name];
    currentSelectedItem = [voices objectAtIndex:btn.index.row];
    
    
    
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:currentSelectedItem.vl_name message:@"添加音效需要先下载，确定是否下载" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    alertView = nil;
}

-(void)playMusic:(id)sender
{
    NSLog(@"%s",__FUNCTION__);
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
        NSMutableDictionary * params = [NSMutableDictionary dictionary];
        [params setValue:self.selectedCatalog.vlt_id forKey:@"vltId"];
        if([self SortArg1] != nil)
        {
            [params setValue:[self SortArg1] forKey:@"arg1"];
        }
        if([self SortArg2] != nil)
        {
            [params setValue:[self SortArg2] forKey:@"arg2"];
        }
        if([self sortArg3] != nil)
        {
            [params setValue:[self sortArg3] forKey:@"arg3"];
        }
        [[HttpService sharedInstance] findVoiceByCatalog:params completionBlock:^(id object) {
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

- (IBAction)sortByUpload:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    SortPopoverViewController * sortVC = [[SortPopoverViewController alloc] initWithStyle:UITableViewStylePlain];
    sortVC.delegate = self;
    sortVC.dataSource = _sortArr_1;
    sortVC.view.frame = CGRectMake(0, 0, 180, 150);
    CGRect rect = btn.frame;
    rect.origin.y += 64;
    [self showPopoverWithController:sortVC atRect:rect];
}

- (IBAction)sourtByAction:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    SortPopoverViewController * sortVC = [[SortPopoverViewController alloc] initWithStyle:UITableViewStylePlain];
    sortVC.delegate = self;
    sortVC.dataSource = _sortArr_2;
    sortVC.view.frame = CGRectMake(0, 0, 180, 150);
    CGRect rect = btn.frame;
    rect.origin.y += 64;
    [self showPopoverWithController:sortVC atRect:rect];
}

- (IBAction)sortBySampel:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    SortPopoverViewController * sortVC = [[SortPopoverViewController alloc] initWithStyle:UITableViewStylePlain];
    sortVC.delegate = self;
    sortVC.dataSource = _sortArr_3;
    sortVC.view.frame = CGRectMake(0, 0, 180, 240);
    CGRect rect = btn.frame;
    rect.origin.y += 64;
    [self showPopoverWithController:sortVC atRect:rect];

}

#pragma mark - Private Methods
- (void)showPopoverWithController:(UIViewController *)vc atRect:(CGRect)frame
{
    if(_tsPopoverController)
        _tsPopoverController = nil;
    _tsPopoverController = [[TSPopoverController alloc] initWithContentViewController:vc];
    _tsPopoverController.titleText = nil;
    _tsPopoverController.popoverGradient = NO;
    _tsPopoverController.popoverBaseColor = [UIColor whiteColor];
    _tsPopoverController.cornerRadius = 5.0f;
    [_tsPopoverController showPopoverWithRect:frame];
}

- (void)dismissPopoverController
{
    if(_tsPopoverController)
        [_tsPopoverController dismissPopoverAnimatd:YES];
}

- (NSString *)SortArg1
{
    NSString * title = [_sortBtn_1 titleForState:UIControlStateNormal];
    NSString * arg;
    if(![_sortArr_1 containsObject:title]) arg = nil;
    int index = [_sortArr_1 indexOfObject:title];
    if(index == 0)
    {
        arg = nil;
    }
    else
    {
        arg = [NSString stringWithFormat:@"%i",index];
    }
    return arg;
}

- (NSString *)SortArg2
{
    NSString * title = [_sortBtn_2 titleForState:UIControlStateNormal];
    NSString * arg;
    if(![_sortArr_2 containsObject:title]) arg = nil;
    int index = [_sortArr_2 indexOfObject:title];
    if(index == 0)
    {
        arg = nil;
    }
    else
    {
        arg = [NSString stringWithFormat:@"%i",index];
    }
    return nil;
}


- (NSString *)sortArg3
{
    NSString * title = [_sortBtn_3 titleForState:UIControlStateNormal];
    NSString * arg;
    if(![_sortArr_3 containsObject:title]) arg = nil;
    int index = [_sortArr_3 indexOfObject:title];
    if(index == 0)
    {
        arg = nil;
    }
    else
    {
        arg = [NSString stringWithFormat:@"%i",index];
    }
    return arg;
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Cell_Height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return Section_Height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"SoundCatalogSectionHeader" owner:nil options:nil];
    UIView * view = [views firstObject];
    view.tag = section;
    UILabel * label = (UILabel *)[view viewWithTag:1001];
    UIImageView * imageView = (UIImageView *)[view viewWithTag:1002];
    Catalog * catalog = [_catalogs objectAtIndex:section];
    if(catalog == self.selectedCatalog)
    {
        imageView.image = [UIImage imageNamed:@"FoundMusic_mn"];
    }
    else
    {
       imageView.image = [UIImage imageNamed:@"FoundMusic_op"];
    }
    label.text = catalog.vlt_name;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSection:)];
    [view addGestureRecognizer:tapGesture];
    view.userInteractionEnabled = YES;
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Catalog * catalog = [_catalogs objectAtIndex:indexPath.section];
    NSArray * voices = [_catalogSoundsInfo objectForKey:catalog.vlt_name];
    Voice * voice = [voices objectAtIndex:indexPath.row];
    
    MixingMusicOnlineCell * cell  = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell.firstBtn setImage:[UIImage imageNamed:@"hunyin_45.png"] forState:UIControlStateNormal];
    [cell.secondBtn setImage:[UIImage imageNamed:@"hunyin_46.png"] forState:UIControlStateNormal];
    [cell.firstBtn addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [cell.secondBtn addTarget:self action:@selector(editMusic:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.secondBtn.index          = indexPath;
    cell.firstBtn.index           = indexPath;
    cell.littleTitleLabel.text  = voice.vl_name;
    cell.selectionStyle         = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - SortPopoverViewControllerDelegate Methods
- (void)sortItem:(NSString *)item
{
    NSLog(@"%@",item);
    [self dismissPopoverController];
    if([_sortArr_1 containsObject:item])
    {
        NSString * condition_1 = [_sortBtn_1 titleForState:UIControlStateNormal];
        if(![condition_1 isEqualToString:item])
        {
            [_sortBtn_1 setTitle:item forState:UIControlStateNormal];
            self.isSortConditionChange = YES;
        }
    }
    else if([_sortArr_2 containsObject:item])
    {
        NSString * condition_2 = [_sortBtn_2 titleForState:UIControlStateNormal];
        if(![condition_2 isEqualToString:item])
        {
            [_sortBtn_2 setTitle:item forState:UIControlStateNormal];
            self.isSortConditionChange = YES;
        }
    }
    else if([_sortArr_3 containsObject:item])
    {
        NSString * condition_3 = [_sortBtn_3 titleForState:UIControlStateNormal];
        if(![condition_3 isEqualToString:item])
        {
            [_sortBtn_3 setTitle:item forState:UIControlStateNormal];
            self.isSortConditionChange = YES;
        }
    }
    
//    if(self.selectedCatalog == nil) return;
    if(self.isSortConditionChange)
    {
        self.isSortConditionChange = NO;
        for(Catalog * catalog in _catalogs)
        {
            [_catalogSoundsInfo setObject:[NSArray array] forKey:catalog.vlt_name];
        }
        if(self.selectedCatalog == nil)
        {
            [_tableView reloadData];
            return ;
        }
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"正在加载";
        NSMutableDictionary * params = [NSMutableDictionary dictionary];
        [params setValue:self.selectedCatalog.vlt_id forKey:@"vltId"];
        if([self SortArg1] != nil)
        {
            [params setValue:[self SortArg1] forKey:@"arg1"];
        }
        if([self SortArg2] != nil)
        {
            [params setValue:[self SortArg2] forKey:@"arg2"];
        }
        if([self sortArg3] != nil)
        {
            [params setValue:[self sortArg3] forKey:@"arg3"];
        }
        [[HttpService sharedInstance] findVoiceByCatalog:params completionBlock:^(id object) {
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
}

#pragma mark - UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //do nothing
            break;
        case 1:
            {
                //下载音频文件

                [self startDownloadMusicWithObj:@{@"URL": currentSelectedItem.url,@"Name":currentSelectedItem.vl_name} completedBlock:^(NSError *error, NSDictionary *info) {
                    ;
                }];

            }
            break;
        default:
            break;
    }
}



@end
