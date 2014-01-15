//
//  LoginViewController.h
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface LoginViewController : CommonViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *mobileField;
- (IBAction)backAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)registerAction:(id)sender;

@end
