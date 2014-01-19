//
//  ShareViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-19.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface ShareViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UIView *containView;
- (IBAction)shareAction:(id)sender;

- (IBAction)backAction:(id)sender;
@end
