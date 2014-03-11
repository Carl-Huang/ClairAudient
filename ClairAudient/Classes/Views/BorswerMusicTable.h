//
//  BorswerMusicTable.h
//  ClairAudient
//
//  Created by vedon on 11/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BorswerMusicTable : UITableView

@property (strong ,nonatomic) NSArray * dataSource;
@property (assign ,nonatomic) CGFloat cell_Height;
@property (assign ,nonatomic) Class   type;
@property (strong ,nonatomic) id info;

@property (weak ,nonatomic) UIViewController * parentController;
@end
