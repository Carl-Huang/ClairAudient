//
//  PersonalHomePageViewController.m
//  ClairAudient
//
//  Created by Carl on 14-1-12.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "PersonalHomePageViewController.h"
#import "UIViewController+CustomBarItemPosition.h"
#import "User.h"
#import "PhotoManager.h"
#import "AppDelegate.h"
#import "CustomiseActionSheet.h"
#import "GobalMethod.h"
@interface PersonalHomePageViewController ()
@property (nonatomic,strong) User * user;
@end

@implementation PersonalHomePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _user = [User userFromLocal];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
- (void)initUI
{
    self.title = @"她的主页";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setLeftAndRightBarItem];
    if(self.user)
    {
        _nameField.text = _user.userName;
        _passwordField.text = _user.passWord;
        _birthdayField.text = _user.birthday;
        _jobField.text = _user.workUnit;
        _emailField.text = _user.email;
        
    }
    UIImage * image= [GobalMethod getImageFromLocalWithKey:DefaultUserImage];
    if (image) {
        self.userPhoto.image = image;
    }
}

- (IBAction)choosePhotoAction:(id)sender {
    
    __weak PersonalHomePageViewController * weakSelf = self;
    [[PhotoManager shareManager]setConfigureBlock:^(UIImage * image)
     {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             weakSelf.userPhoto.image = image;

             [GobalMethod saveImageToUserDefault:image key:DefaultUserImage];
             
         });
         
     }];
    
    CustomiseActionSheet * synActionSheet = [[CustomiseActionSheet alloc] init];
    synActionSheet.titles = [NSArray arrayWithObjects:@"拍照", @"从相册选择",@"取消", nil];
    synActionSheet.destructiveButtonIndex = -1;
    synActionSheet.cancelButtonIndex = 2;
    NSUInteger result = [synActionSheet showInView:self.view];
    if (result==0) {
        //拍照
        NSLog(@"From Camera");
        [self presentViewController:[PhotoManager shareManager].camera animated:YES completion:nil];
        
    }else if(result ==1)
    {
        //从相册选择
        NSLog(@"From Album");
        [self presentViewController:[PhotoManager shareManager].pickingImageView animated:YES completion:nil];
        
    }else
    {
        NSLog(@"Cancel");
    }
    
   
}
@end
