//
//  MyUploadDetailViewController.h
//  ClairAudient
//
//  Created by vedon on 11/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommonViewController.h"
@class Voice;
@interface MyUploadDetailViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UIView *scrollAdView;
@property (weak, nonatomic) IBOutlet UITableView *musicInfoTable;
@property (weak, nonatomic) IBOutlet UIView *shareContentView;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong ,nonatomic) Voice * voiceItem;
@end
