//
//  SortPopoverViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-25.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"
@protocol SortPopoverViewControllerDelegate <NSObject>

- (void)sortItem:(NSString *)item;

@end
@interface SortPopoverViewController : UITableViewController
@property (nonatomic,strong) NSArray * dataSource;
@property (nonatomic,strong) id<SortPopoverViewControllerDelegate> delegate;
@end
