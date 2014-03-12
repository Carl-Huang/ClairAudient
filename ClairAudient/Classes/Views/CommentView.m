//
//  CommentView.m
//  ClairAudient
//
//  Created by vedon on 12/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CommentView.h"
#import "UIBubbleTableView.h"

@interface CommentView ()<UIBubbleTableViewDataSource>
{
    NSMutableArray *bubbleData;
}
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

-(void)configureBubbleView
{
    bubbleData = [NSMutableArray array];
    _contentTable.bubbleDataSource = self;
    _contentTable.snapInterval = 120;
    _contentTable.showAvatars = NO;
    _contentTable.bubbleDataSource = self;
    
    

    [_contentTable reloadData];
    [_contentTable scrollBubbleViewToBottomAnimated:YES];
}

//-(NSBubbleData *)toIDBubble:(MessageObject *)object
//{
//    NSBubbleData *sayBubble = [NSBubbleData dataWithText:object.content date:[self timeIntervalToDate:object.add_time.integerValue] type:BubbleTypeSomeoneElXse];
//    UIImageView * imageView = [[UIImageView alloc]init];
//    [imageView setImageWithURLRequest:[self constructImageUrlWith:_to_id] placeholderImage:[UIImage imageNamed:@"mtxx110.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//        sayBubble.avatar = image;
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        ;
//    }];
//    
//    return sayBubble;
//}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
