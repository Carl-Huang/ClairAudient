//
//  RecordViewController.h
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface RecordViewController : CommonViewController


#pragma mark - Outlet Action
- (IBAction)startRecordAction:(id)sender;
- (IBAction)pauseBtnAction:(id)sender;
- (IBAction)stopRecordAction:(id)sender;
- (IBAction)cancelRecordAction:(id)sender;
- (IBAction)showRecordFileAction:(id)sender;

- (IBAction)backAction:(id)sender;
#pragma mark - Outlet
@property (weak, nonatomic) IBOutlet UILabel *clocker;
@property (weak, nonatomic) IBOutlet UIView *beginRecordView;

@property (weak, nonatomic) IBOutlet UIView *beforeRecordView;

@end
