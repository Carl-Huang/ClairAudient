//
//  MyDownloadViewController.h
//  ClairAudient
//
//  Created by Vedon on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MyDownloadViewController : CommonViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
