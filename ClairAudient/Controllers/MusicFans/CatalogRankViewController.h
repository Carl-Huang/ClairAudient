//
//  CatalogRankViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-8.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface CatalogRankViewController : CommonViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@end
