//
//  CopyMusicView.m
//  ClairAudient
//
//  Created by vedon on 9/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CopyMusicView.h"

@implementation CopyMusicView

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
 */

-(void)initalizationContainerViewContent
{
    NSInteger width = self.containerView.frame.size.width;
    NSInteger orignalY = 40;
    NSInteger orignalX = 12;
    NSInteger btnWidth = 40;
    NSInteger btnHeight = 40;
    NSInteger numberPerRow = 5;
    NSInteger rowCount = 0;
    // Drawing code
    for (int i= 0; i<10; ++i) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i != 0) {
            if (i % numberPerRow == 0) {
                rowCount ++;
            }
        }
        [btn setFrame:CGRectMake(orignalX+(btnWidth + 16)*(i - rowCount * 5), orignalY+(20+btnHeight)*rowCount, btnWidth, btnHeight)];
        
        NSString * imageName = [NSString stringWithFormat:@"%d.png",i+1];
        [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        
        [self.containerView addSubview:btn];
    }
}

-(void)clickBtnAction:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (_block) {
        _block (btn.tag+1);
        _block = nil;
        [self removeFromSuperview];
    }
}
@end
