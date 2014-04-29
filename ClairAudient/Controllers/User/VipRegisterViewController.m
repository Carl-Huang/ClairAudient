//
//  VipRegisterViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "VipRegisterViewController.h"
#import "HttpService.h"
#import "LoginViewController.h"
@interface VipRegisterViewController ()

@end

@implementation VipRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     {"userName":"","passWord":"","findQuestion":"","findAnswer":"","email":"","integral":100,"role":4,"name":"","sex":"","birthday":"","telphone":"","mobil":"","qq":"","workUnit":"","profession":"","workYears":0,"address":"","postCode":""}
     */
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods
- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}

- (IBAction)selectBoyAction:(id)sender
{
    [_boyBtn setSelected:YES];
    [_girlBtn setSelected:NO];
}

- (IBAction)selectGirlAction:(id)sender
{
    [_boyBtn setSelected:NO];
    [_girlBtn setSelected:YES];
}

- (IBAction)regiBtnAction:(id)sender {
    
    /*
     {"userName":"","passWord":"","findQuestion":"","findAnswer":"","email":"","integral":100,"role":4,"name":"","sex":"","birthday":"","telphone":"","mobil":"","qq":"","workUnit":"","profession":"","workYears":0,"address":"","postCode":""}
     */
    if(_info)
    {
       if([_nameField.text length]==0)
       {
           _nameField.text = @"";
       }
        /*
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
         */
        
        NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:_info];
        [params setValue:_nameField.text forKey:@"name"];
//        [params setValue:_nameField.text forKey:@"sex"];
        [params setValue:_birthdayField.text forKey:@"birthday"];
        [params setValue:_telField.text forKey:@"telphone"];
        [params setValue:_mobileField.text forKey:@"mobil"];
//        [params setValue:_nameField.text forKey:@"qq"];
//        [params setValue:_nameField.text forKey:@"workUnit"];
        [params setValue:_jobField.text forKey:@"profession"];
        [params setValue:_workYearsField.text forKey:@"workYears"];
        [params setValue:_departmentField.text forKey:@"address"];
        [params setValue:_codeField.text forKey:@"postCode"];
        
        
        __weak VipRegisterViewController * weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[HttpService sharedInstance]registerWithParams:params completionBlock:^(BOOL isSuccess) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if(isSuccess)
            {
                [weakSelf gotoLoginViewControllerWithParams:params];
            }else
            {
                //失败
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        }];

    }

}

-(void)gotoLoginViewControllerWithParams:(NSDictionary *)dic
{
    LoginViewController * viewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    [viewController setInfo:dic];
    [self push:viewController];
    viewController = nil;
}
@end
