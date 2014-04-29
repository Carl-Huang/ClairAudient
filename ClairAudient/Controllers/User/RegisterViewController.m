//
//  RegisterViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "RegisterViewController.h"
#import "ControlCenter.h"
#import "HttpService.h"
#import "LoginViewController.h"
@interface RegisterViewController ()

@end

@implementation RegisterViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Action Methods
- (IBAction)registerAction:(id)sender
{
    
    /*
{"userName":"","passWord":"","findQuestion":"","findAnswer":"","email":"","integral":100,"role":4,"name":"","sex":"","birthday":"","telphone":"","mobil":"","qq":"","workUnit":"","profession":"","workYears":0,"address":"","postCode":""}
     */
    /*
     @property (weak, nonatomic) IBOutlet UITextField *emailField;
     @property (weak, nonatomic) IBOutlet UITextField *answerField;
     @property (weak, nonatomic) IBOutlet UITextField *questionField;
     @property (weak, nonatomic) IBOutlet UITextField *repeatPswField;
     @property (weak, nonatomic) IBOutlet UITextField *pswField;
     @property (weak, nonatomic) IBOutlet UITextField *nameField;
     */
    if ([_emailField.text length] == 0 ||[_answerField.text length] == 0||[_questionField.text length] == 0||[_repeatPswField.text length] == 0||[_pswField.text length] == 0||[_nameField.text length]) {
        [self showAlertViewWithMessage:@"还有信息没有填哦，亲"];
        return;
    }
    
    if (![_pswField.text isEqualToString:_repeatPswField.text]) {
        [self showAlertViewWithMessage:@"密码不一致"];
    }
    
    
    if(_vipBtn.selected)
    {
        [ControlCenter showVipRegisterVC];
    }else
        
    {
        NSDictionary * params = @{@"userName":_nameField.text,@"passWord":_pswField.text,@"findQuestion":_questionField.text,@"findAnswer":_answerField.text,@"email":_emailField.text};
        __weak RegisterViewController * weakSelf = self;
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

- (IBAction)backAction:(id)sender
{
    [self popVIewController];
}

- (IBAction)selectNormalAction:(id)sender
{
    [_normalBtn setSelected:YES];
    [_vipBtn setSelected:NO];
}

- (IBAction)selectionVipAction:(id)sender
{
    [_normalBtn setSelected:NO];
    [_vipBtn setSelected:YES];
}

-(void)gotoLoginViewControllerWithParams:(NSDictionary *)dic
{
    LoginViewController * viewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    [viewController setInfo:dic];
    [self push:viewController];
    viewController = nil;
}
@end
