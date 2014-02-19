//
//  MyProductionViewController.h
//  ClairAudient
//
//  Created by vedon on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MyProductionViewController : CommonViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
