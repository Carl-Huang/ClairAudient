//
//  VipRegisterViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface VipRegisterViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UIButton *boyBtn;
@property (weak, nonatomic) IBOutlet UIButton *girlBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *telField;
@property (weak, nonatomic) IBOutlet UITextField *mobileField;
@property (weak, nonatomic) IBOutlet UIImageView *msnField;
@property (weak, nonatomic) IBOutlet UITextField *departmentField;
@property (weak, nonatomic) IBOutlet UITextField *jobField;
@property (weak, nonatomic) IBOutlet UITextField *workYearsField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayField;

@property (strong ,nonatomic)NSDictionary * info;
- (IBAction)backAction:(id)sender;
- (IBAction)selectBoyAction:(id)sender;
- (IBAction)selectGirlAction:(id)sender;
- (IBAction)regiBtnAction:(id)sender;
@end
