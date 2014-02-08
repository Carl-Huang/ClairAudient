//
//  MixingEffectViewController.h
//  ClairAudient
//
//  Created by vedon on 24/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MixingEffectViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong ,nonatomic) NSDictionary * musicInfo;
- (IBAction)backAction:(id)sender;
@end
