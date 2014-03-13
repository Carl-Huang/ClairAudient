//
//  SoundCatalogViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-10.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"
@class Catalog;
@interface MixingCatalogViewController : CommonViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *sortBtn_1;
@property (weak, nonatomic) IBOutlet UIButton *sortBtn_2;
@property (weak, nonatomic) IBOutlet UIButton *sortBtn_3;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) Catalog * parentCatalog;
@property (assign ,nonatomic) BOOL isMutiMixing;

@property (weak, nonatomic) IBOutlet UIImageView *bgView;


- (IBAction)sortByUpload:(id)sender;
- (IBAction)sourtByAction:(id)sender;
- (IBAction)sortBySampel:(id)sender;

@end
