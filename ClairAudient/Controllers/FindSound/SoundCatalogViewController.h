//
//  SoundCatalogViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-10.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"
@class Catalog;
@interface SoundCatalogViewController : CommonViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) Catalog * parentCatalog;
@end
