//
//  MutiMixingViewController.h
//  ClairAudient
//
//  Created by vedon on 24/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MutiMixingViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong ,nonatomic) NSDictionary * mutiMixingInfo;

- (IBAction)backAction:(id)sender;
- (IBAction)playAction:(id)sender;
- (IBAction)startMixingAction:(id)sender;
@end
