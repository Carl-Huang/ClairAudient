//
//  SettingViewController.m
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "SettingViewController.h"
#import "ControlCenter.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "AccentTableViewController.h"
#import "UserDefaultMacro.h"
#import "DrawDownBtn.h"
@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    AccentTableViewController * popUpTable;
}
@property (nonatomic,strong) NSArray * dataSource;
@property (nonatomic,strong) NSDictionary * imageInfos;
@end

@implementation SettingViewController
#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = @[@"乡音模式",@"关于积分",@"个性主题",@"用户反馈",@"帮助",@"退出登陆"];
        _imageInfos = @{@"乡音模式":@"setting_3",@"关于积分":@"setting_5",@"个性主题":@"setting_6",@"帮助与反馈":@"setting_7",@"退出登陆":@"setting_8"};
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

-(void)dealloc
{
    popUpTable = nil;
}

#pragma mark - Private Methods
- (void)initUI
{
    [self.navigationController setNavigationBarHidden:NO];

    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设置";
    [self setLeftAndRightBarItem];

    [_tableView setBackgroundColor:[UIColor clearColor]];
    UIView * view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
    view = nil;

    
    
}

-(void)showAccentTable:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (popUpTable == nil) {
        popUpTable = [[AccentTableViewController alloc]initWithNibName:@"AccentTableViewController" bundle:nil];
        
        NSArray * array = @[@"普通话",@"合肥话",@"芜湖话",@"淮南话",@"安庆话",@"铜陵话",@"黄山话",@"池州话",@"宣城话",@"安话",@"宿州话",@"马鞍山话",@"徐州话",@"淮北话",@"阜阳话",@"毫州话"];
        
        [popUpTable setDataSource:array];
        array = nil;
        //设置位置
        CGRect originalRect = popUpTable.view.frame;
        originalRect.origin.x = btn.frame.origin.x + btn.frame.size.width/2.0 - originalRect.size.width/2;
        originalRect.origin.y = btn.frame.origin.y + btn.frame.size.height;
//        originalRect.size.width = btn.frame.size.width;
        [popUpTable.view setFrame:originalRect];
        
        [popUpTable setBlock:^(NSInteger index,NSString * title){
            [[NSUserDefaults standardUserDefaults]setObject:title forKey:DefaultAccent];
            [btn setTitle:title forState:UIControlStateNormal];
        }];
    }else
    {
        [self.view addSubview:popUpTable.view];
    }
   
    
}


#pragma mark - UIButton Actions
- (IBAction)pushBack:(id)sender
{
    [self popVIewController];
}

- (IBAction)rightItemAction:(id)sender
{

}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identify = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        UILabel * line = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, cell.bounds.size.width, 1)];
//        line.backgroundColor = [UIColor whiteColor];
//        [cell.contentView addSubview:line];
    }
    cell.imageView.image = [UIImage imageNamed:[_imageInfos objectForKey: [_dataSource objectAtIndex:indexPath.row]]];
    cell.textLabel.text = [_dataSource objectAtIndex:indexPath.row];
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    imageView.image = [UIImage imageNamed:@"setting_9"];
    if(indexPath.row == 0)
    {
        DrawDownBtn * button = [[[NSBundle mainBundle]loadNibNamed:@"DrawDownBtn" owner:self options:nil]objectAtIndex:0];
        [button setBackgroundColor:[UIColor whiteColor]];

        NSString * accent = [[NSUserDefaults standardUserDefaults]objectForKey:DefaultAccent];
        if (accent == nil) {
            accent = @"普通话";
        }
        [button setTitle:accent forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showAccentTable:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
        button = nil;
    }
    else if(indexPath.row == 1)
    {
        cell.accessoryView = imageView;
    }
    else if(indexPath.row == 2)
    {
        cell.accessoryView = imageView;
    }
    else if(indexPath.row == 3)
    {
        cell.accessoryView = imageView;
    }else if (indexPath.row == 4)
    {
        cell.accessoryView = imageView;
    }
    else if (indexPath.row == 5)
    {
        cell.accessoryView = nil;
    }
    
    
    return cell;
}

#pragma mark - UITableVIewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1)
    {
        [ControlCenter showAboutScoreVC];
    }
    else if(indexPath.row == 2)
    {
        [ControlCenter showThemeVC];
    }
    else if(indexPath.row == 3)
    {
        [ControlCenter showHelpVC];
    }else if (indexPath.row == 4)
    {
        //帮助
    }
    else if (indexPath.row == 5)
    {
        [User deleteUserInfo];
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"退出成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
    }
}

-(void)gotoRootViewController
{
    NSArray * viewControllers = self.navigationController.viewControllers;
    for (UIViewController * vc in viewControllers) {
        if ([vc isKindOfClass:[MainViewController class]]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self gotoRootViewController];
            break;
            
        default:
            break;
    }
}
@end
