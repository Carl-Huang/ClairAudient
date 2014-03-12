//
//  CommentView.h
//  ClairAudient
//
//  Created by vedon on 12/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UIBubbleTableView;
@interface CommentView : UIView

@property (weak, nonatomic) IBOutlet UIButton *shareToTenceBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToWeiboBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToWeixinBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToRenRenBtn;
@property (weak, nonatomic) IBOutlet UITextView *commentTextview;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UIView *tableViewContainer;


- (IBAction)submitCommentActon:(id)sender;

-(void)configureBubbleView:(NSArray *)dataSource;
@end
