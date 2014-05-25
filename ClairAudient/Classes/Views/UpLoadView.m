//
//  UpLoadView.m
//  ClairAudient
//
//  Created by vedon on 13/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "UpLoadView.h"
#import "PopupTagViewController.h"
#import "HttpService.h"
#import "Catalog.h"
#import "MBProgressHUD.h"
#import "GobalMethod.h"
#import "User.h"

@interface UpLoadView()<UITextViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    PopupTagViewController * popUpTable;
    PopupTagViewController * childPopUpTable;
    
    BOOL isAddPopupTable;
    BOOL isAddChildPopUpTable;
}
@property (assign ,nonatomic) BOOL isResetChildrenDataSource;
@property (strong ,nonatomic) NSArray * parentCatalog;
@property (strong ,nonatomic) NSArray * childrenCatalog;
@property (assign ,nonatomic) NSString* currentSelectedParentID;
@property (assign ,nonatomic) NSString* currentSelectedChildID;
@end
@implementation UpLoadView
@synthesize parentCatalog,childrenCatalog,currentSelectedParentID,currentSelectedChildID;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)awakeFromNib
{
    [super awakeFromNib];
    _desTextView.delegate = self;
    _nameLabel.delegate = self;
    isAddPopupTable = NO;
    isAddChildPopUpTable = NO;
    currentSelectedParentID = @"-1";
}

-(void)showParentCatalog
{
    __weak UpLoadView * weakSelf = self;
    if (!popUpTable) {
        popUpTable = [[PopupTagViewController alloc]initWithNibName:@"PopupTagViewController" bundle:nil];
        
        NSMutableArray * array = [NSMutableArray array];
        for(Catalog * object in parentCatalog)
        {
            [array addObject:object.vlt_name];
        }
        [popUpTable setDataSource:array];
        array = nil;
        //设置位置
        CGRect originalRect = popUpTable.view.frame;
        originalRect.origin.x = _parentBtn.frame.origin.x + _parentBtn.frame.size.width/2.0 - originalRect.size.width/2;
        originalRect.origin.y = _parentBtn.frame.origin.y + _parentBtn.frame.size.height +50;
        originalRect.size.width = _parentBtn.frame.size.width;
        [popUpTable.view setFrame:originalRect];
        
        [popUpTable setBlock:^(NSInteger index,NSString * title){
         
            weakSelf.isResetChildrenDataSource = YES;
            
            [weakSelf.parentBtn setTitle:title forState:UIControlStateNormal];
            Catalog * object = [weakSelf.parentCatalog objectAtIndex:index];
            weakSelf.currentSelectedParentID = object.vlt_id;
            isAddPopupTable = NO;
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSubview:popUpTable.view];
            if (isAddChildPopUpTable&&childPopUpTable ) {
                [childPopUpTable.view removeFromSuperview];
            }
        });
    }else
    {
        if (!isAddPopupTable) {
            isAddPopupTable = YES;
            [self addSubview:popUpTable.view];
            if (isAddChildPopUpTable&&childPopUpTable ) {
                [childPopUpTable.view removeFromSuperview];
            }
        }else
        {
            isAddPopupTable = NO;
            [popUpTable.view removeFromSuperview];
        }
    
    }
}


-(void)showChildrenPopupview
{
    __weak UpLoadView * weakSelf = self;
    if (!childPopUpTable) {
        childPopUpTable = [[PopupTagViewController alloc]initWithNibName:@"PopupTagViewController" bundle:nil];
        
        NSMutableArray * array = [NSMutableArray array];
        for(Catalog * object in childrenCatalog)
        {
            [array addObject:object.vlt_name];
        }
        [childPopUpTable setDataSource:array];
        array = nil;
        //设置位置
        CGRect originalRect = childPopUpTable.view.frame;
        originalRect.origin.x = _childrenBtn.frame.origin.x + _childrenBtn.frame.size.width/2.0 - originalRect.size.width/2;
        originalRect.origin.y = _childrenBtn.frame.origin.y + _childrenBtn.frame.size.height +50;
        originalRect.size.width = _parentBtn.frame.size.width;
        [childPopUpTable.view setFrame:originalRect];
        
        [childPopUpTable setBlock:^(NSInteger index,NSString * title){
            
            [weakSelf.childrenBtn setTitle:title forState:UIControlStateNormal];
            Catalog * object = [weakSelf.parentCatalog objectAtIndex:index];
            weakSelf.currentSelectedChildID = object.vlt_id;
            isAddChildPopUpTable = NO;
        }];
        [self addSubview:childPopUpTable.view];
    }else
    {
        NSMutableArray * array = [NSMutableArray array];
        for(Catalog * object in childrenCatalog)
        {
            [array addObject:object.vlt_name];
        }
        [childPopUpTable updateDateSource:array];
        array = nil;
        
        
        if (!isAddChildPopUpTable) {
            isAddChildPopUpTable = YES;
            [self addSubview:childPopUpTable.view];
        }else
        {
            isAddChildPopUpTable = NO;
            [childPopUpTable.view removeFromSuperview];
        }
    }

}

- (IBAction)parentBtnAction:(id)sender {
    __weak UpLoadView * weakSelf = self;
    
    if ([parentCatalog count] == 0) {
        [[HttpService sharedInstance]findCatalog:@{@"parentId":@"0"} completionBlock:^(id object) {
            if ([object count]) {
                parentCatalog = object;
                [weakSelf showParentCatalog];
            }
        } failureBlock:^(NSError *error, NSString *responseString) {
            ;
        }];

    }else
    {
        
        [self showParentCatalog];
    }
    
}

- (IBAction)childrenBtnAction:(id)sender {
    __weak UpLoadView * weakSelf = self;
    
    if (![currentSelectedParentID isEqualToString:@"-1"]) {
        if ([childrenCatalog count] == 0 || self.isResetChildrenDataSource) {
            [[HttpService sharedInstance]findCatalog:@{@"parentId":currentSelectedParentID} completionBlock:^(id object) {
                if ([object count]) {
                    childrenCatalog = object;
                    [weakSelf showChildrenPopupview];
                }
            } failureBlock:^(NSError *error, NSString *responseString) {
                ;
            }];
            
        }else
        {
            [self showChildrenPopupview];
        }
    }
    

}

- (IBAction)sureBtnAction:(id)sender {
    
    if ([_desTextView.text length]==0) {
        [self showAlertViewWithMessage:@"说明文字不能为空"];
        return;
    }
    if ([_nameLabel.text length]==0) {
        [self showAlertViewWithMessage:@"名称不能为空"];
        return;
    }
    
    
    if (_musicEncodeStr) {
        @autoreleasepool {
            [MBProgressHUD showHUDAddedTo:self animated:YES];
            __weak UpLoadView * weakSelf = self;
            
            NSString * musicName = [[self.musicInfo valueForKey:@"Title"]stringByAppendingString:@".mp3"];
            NSString * uploadTime = [GobalMethod getCurrentDateString];
            User *user = [User userFromLocal];
            NSString * user_id = user.hw_id;
            user = nil;
            NSDictionary * params = @{@"voiceLibrary": @{@"bit_rate": @"8-bit",@"vl_name":_nameLabel.text,@"explain":_desTextView.text,@"url":musicName,@"upload_time":uploadTime,@"sampling_rate":@"8000HZ",@"time":@"0",@"priority":@"0",@"parent_id":currentSelectedParentID,@"user_id":user_id,@"id":@"0",@"download_num":@"0",@"vlt_id":currentSelectedChildID,@"content":@"123"}};
            
            [[HttpService sharedInstance]uploadVoice:params completionBlock:^(BOOL isSuccess) {
                if (isSuccess) {
                    [weakSelf showAlertViewWithMessage:@"上传成功" withDelegate:self tag:1001];
                }else
                {
                    [weakSelf showAlertViewWithMessage:@"上传失败"];
                }
                
                [MBProgressHUD hideHUDForView:weakSelf animated:YES];
            } failureBlock:^(NSError *error, NSString *responseString) {
                [weakSelf showAlertViewWithMessage:@"上传失败"];
                [MBProgressHUD hideHUDForView:weakSelf animated:YES];
            }];
            params = nil;
        }
        
    }
    
}

- (IBAction)cancelBtnAction:(id)sender {
    [self removeFromSuperview];
    popUpTable = nil;
    childPopUpTable = nil;
    parentCatalog = nil;
    childrenCatalog = nil;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return  YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectOffset(self.frame, 0, -90);
    }];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectOffset(self.frame, 0, 90);
    }];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return  YES;
}

- (void)showAlertViewWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
    });
}

- (void)showAlertViewWithMessage:(NSString *)message withDelegate:(id)delegate tag:(NSInteger)tag
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:delegate cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        alertView.tag = tag;
        alertView = nil;
    });
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }
}
@end
