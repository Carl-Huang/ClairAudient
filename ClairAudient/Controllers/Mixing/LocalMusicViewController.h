//
//  LocalMusicViewController.h
//  ClairAudient
//
//  Created by vedon on 24/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface LocalMusicViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UITableView *contentTable;
@property (weak, nonatomic) IBOutlet UITextField *searchField;


- (IBAction)backAction:(id)sender;
@end
