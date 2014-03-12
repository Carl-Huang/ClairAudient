//
//  HelpViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-6.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface HelpViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UIImageView *bgView;

@property (weak, nonatomic) IBOutlet UITextView *contentView;
- (IBAction)submitCommentAction:(id)sender;
@end
