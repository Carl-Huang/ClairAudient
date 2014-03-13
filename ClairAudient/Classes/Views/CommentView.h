//
//  CommentView.h
//  ClairAudient
//
//  Created by vedon on 12/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UIBubbleTableView;
@class Voice;

typedef void(^UpdateContentHeightBlock) (NSInteger height);

@interface CommentView : UIView

@property (weak, nonatomic) IBOutlet UIButton *shareToTenceBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToWeiboBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToWeixinBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareToRenRenBtn;
@property (weak, nonatomic) IBOutlet UITextView *commentTextview;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UIView *tableViewContainer;
@property (strong ,nonatomic) UpdateContentHeightBlock block;
@property (strong ,nonatomic) Voice * object;

- (IBAction)submitCommentActon:(id)sender;

-(void)configureBubbleView:(NSArray *)dataSource;
@end
