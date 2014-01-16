//
//  MessageInviteViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MessageInviteViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UITextView *msgText_1;
@property (weak, nonatomic) IBOutlet UITextView *msgText_2;

@property (weak, nonatomic) IBOutlet UIButton *msgBtn_1;
@property (weak, nonatomic) IBOutlet UIButton *msgBtn_2;
- (IBAction)selectFirstMsgAction:(id)sender;
- (IBAction)selectSectionSectionMsgAction:(id)sender;
- (IBAction)selectFriendAction:(id)sender;
- (IBAction)backAction:(id)sender;
@end
