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
#import "User.h"

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
}

-(void)configureBubbleView:(NSArray *)dataSource
{
    bubbleData = [NSMutableArray array];
    _contentTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    _contentTable.delegate = self;
    _contentTable.dataSource = self;
    [_contentTable setBackgroundColor:[UIColor clearColor]];
    [_contentTable setBackgroundView:nil];
    if ([OSHelper iOS7]) {
        _contentTable.separatorInset = UIEdgeInsetsZero;
    }
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
        }
        
        
        [_contentTable reloadData];
    }
    
    _commentTextview.delegate = self;
    


    [self.tableViewContainer addSubview:_contentTable];
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
