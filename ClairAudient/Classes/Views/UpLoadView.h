//
//  UpLoadView.h
//  ClairAudient
//
//  Created by vedon on 13/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpLoadView : UIView

@property (weak, nonatomic) IBOutlet UIButton *parentBtn;

@property (weak, nonatomic) IBOutlet UIButton *childrenBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *desTextView;
@property (weak, nonatomic) UIViewController * parentController;

@property (strong ,nonatomic) NSString * musicEncodeStr;
@property (strong ,nonatomic) NSDictionary * musicInfo;

- (IBAction)parentBtnAction:(id)sender;
- (IBAction)childrenBtnAction:(id)sender;
- (IBAction)sureBtnAction:(id)sender;
- (IBAction)cancelBtnAction:(id)sender;
@end
