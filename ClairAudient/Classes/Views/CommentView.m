//
//  CommentView.m
//  ClairAudient
//
//  Created by vedon on 12/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommentView.h"
#import "UIBubbleTableView.h"
#import "MusicComment.h"
#import "GobalMethod.h"
#import "MusicCommentItem.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "CommentCell.h"
#import "HttpService.h"
#import "Voice.h"
#import "User.h"
#import "ShareManager.h"


static NSString * cellIdentifier = @"cellIdentifier";
@interface CommentView ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>
{
    NSMutableArray *bubbleData;
}
@property (strong ,nonatomic) UITableView * contentTable;
@end

@implementation CommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)submitCommentActon:(id)sender {
    User * user = [User userFromLocal];
    if ([_commentTextview.text length]) {
        if (user) {
            NSInteger  interval = [[NSDate date]timeIntervalSinceNow];
            NSString * intervalStr = [NSString stringWithFormat:@"%d",interval];
            [[HttpService sharedInstance]commentOnMusicWithParams:@{@"content": _commentTextview.text,@"vl_id":self.object.vlt_id,@"user_id":user.hw_id,@"quote_content":@"",@"date":intervalStr,@"recive_name":@""} completionBlock:^(BOOL isSuccess) {
                ;
            } failureBlock:^(NSError * error, NSString * responsed) {
                ;
            }];
        }
    }else
    {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"评论内容不能为空" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
    }
    
}

-(void)configureBubbleView:(NSArray *)dataSource
{
    bubbleData = [NSMutableArray array];
    _contentTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    _contentTable.delegate = self;
    _contentTable.dataSource = self;
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    [_contentTable setBackgroundView:nil];
    
#ifdef IOS7_SDK_AVAILABLE
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
#endif
    _contentTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UINib *cellNib = [UINib nibWithNibName:@"CommentCell" bundle:[NSBundle bundleForClass:[CommentCell class]]];
    [_contentTable registerNib:cellNib forCellReuseIdentifier:cellIdentifier];
    
    if ([dataSource count]) {
        for (MusicCommentItem * commentObject in [[dataSource objectAtIndex:0]valueForKey:@"items"]) {
            [bubbleData addObject:commentObject];
        }
        
        CGRect rect = self.tableViewContainer.frame;
        NSInteger totalHeight = [bubbleData count] * 110;
        if (totalHeight > self.tableViewContainer.frame.size.height) {
            NSInteger offset = totalHeight - self.tableViewContainer.frame.size.height;
            rect.size.height = totalHeight;
            [self.tableViewContainer setFrame:rect];
            
            rect.origin.x = 0;
            rect.origin.y = 0;
            [_contentTable setFrame:rect];
            
            CGRect baiceRect = self.frame;
            baiceRect.size.height +=offset;
            self.frame = baiceRect;
            
            if (_block) {
                _block(rect.size.height + self.tableViewContainer.frame.origin.y);
                _block =  nil;
            }
        }
        
        
        [_contentTable reloadData];
    }
    
    _commentTextview.delegate = self;
    


    [self.tableViewContainer addSubview:_contentTable];
}


#pragma mark - Outlet Action
- (IBAction)shareToTencAction:(id)sender {
    [[ShareManager shareManager]shareToTencentWeiboWithTitle:@"TencentWeibo" content:@"shareToWeiboActioin" image:nil];
}

- (IBAction)shareToWeiboActioin:(id)sender {
    [[ShareManager shareManager]shareToSinaWeiboWithTitle:@"sinaWEibo" content:@"hell" image:nil];
}

- (IBAction)shareToWeixinAction:(id)sender {
    [[ShareManager shareManager]shareToWeiXinContentWithTitle:@"weixin" content:@"hello weixin" image:nil];
}

- (IBAction)shareToRenRenAction:(id)sender {
    [[ShareManager shareManager]shareToRenRenWithTitle:@"renren" content:@"hell" image:nil];
}


#pragma mark - Table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [bubbleData count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setBackgroundColor:[UIColor clearColor]];
    MusicCommentItem * object = [bubbleData objectAtIndex:indexPath.row];
    cell.contentLabel.text = object.content;
    
    long long interval = object.date.longLongValue;
    cell.timeLabel.text = [GobalMethod timeIntervalToDate:interval];
    cell.userNameLabel.text = object.username;
    
    return cell;
}


#pragma mark - TextView
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
