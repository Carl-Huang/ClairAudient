//
//  SettingViewController.h
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface SettingViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)pushBack:(id)sender;
- (IBAction)rightItemAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@end
