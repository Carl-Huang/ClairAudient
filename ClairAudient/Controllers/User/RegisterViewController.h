//
//  RegisterViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface RegisterViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UIButton *vipBtn;
@property (weak, nonatomic) IBOutlet UIButton *normalBtn;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *answerField;
@property (weak, nonatomic) IBOutlet UITextField *questionField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPswField;
@property (weak, nonatomic) IBOutlet UITextField *pswField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
- (IBAction)registerAction:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)selectNormalAction:(id)sender;
- (IBAction)selectionVipAction:(id)sender;

@end
