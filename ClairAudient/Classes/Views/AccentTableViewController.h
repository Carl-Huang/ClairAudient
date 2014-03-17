//
//  PopupTagViewController.h
//  TeaMall
//
//  Created by vedon on 13/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

typedef void (^DidSelectedItem)(NSInteger index,NSString * title);

@interface AccentTableViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong ,nonatomic) NSArray * dataSource;
@property (strong ,nonatomic) DidSelectedItem block;

-(void)updateDateSource:(NSArray *)array;
@end
