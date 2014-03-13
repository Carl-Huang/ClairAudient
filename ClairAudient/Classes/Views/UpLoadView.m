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

@interface UpLoadView()<UITextViewDelegate,UITextFieldDelegate>
{
    PopupTagViewController * popUpTable;
    PopupTagViewController * childPopUpTable;

    
    
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
        }];
        [self addSubview:popUpTable.view];
    }else
    {
        [self addSubview:popUpTable.view];
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
        [self addSubview:childPopUpTable.view];
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
    if (_musicEncodeStr) {
        [MBProgressHUD showHUDAddedTo:self animated:YES];
        __weak UpLoadView * weakSelf = self;
        
        NSDictionary * params = @{@"voiceLibrary": @{@"bit_rate": @"",@"vl_name":@"",@"explain":@"",@"url":@"",@"upload_time":@"",@"sampling_rate":@"",@"time":@"",@"priority":@"",@"user_id":@"",@"id":@"",@"download_num":@"",@"vlt_id":@"",@"content":_musicEncodeStr}};
        
        [[HttpService sharedInstance]uploadVoice:params completionBlock:^(BOOL isSuccess) {
            ;
            [MBProgressHUD hideHUDForView:weakSelf animated:YES];
        } failureBlock:^(NSError *error, NSString *responseString) {
            [MBProgressHUD hideHUDForView:weakSelf animated:YES];
        }];
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
@end
