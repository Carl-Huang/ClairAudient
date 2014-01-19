//
//  MixingViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-18.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MixingViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UILabel *littleTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bigTitleLabel;

- (IBAction)backAction:(id)sender;
@end
