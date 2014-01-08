//
//  AboutScoreViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-6.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface AboutScoreViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UIButton *ruleButton;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;
- (IBAction)ruleAction:(id)sender;
- (IBAction)changeAction:(id)sender;

@end
