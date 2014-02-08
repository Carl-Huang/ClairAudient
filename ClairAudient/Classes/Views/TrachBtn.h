//
//  TrachBtn.h
//  ClairAudient
//
//  Created by vedon on 21/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^BtnDidMoveBlock) (CGFloat offset,CGFloat currentOffsetX);
@interface TrachBtn : UIButton
{
    NSInteger previewOffsetX;
}

@property (strong ,nonatomic) BtnDidMoveBlock  block;
@property (assign ,nonatomic) CGFloat criticalValue;
@property (weak ,nonatomic) UIView * locationView;
@end
