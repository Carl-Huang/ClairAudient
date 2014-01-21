//
//  TrachBtn.h
//  ClairAudient
//
//  Created by vedon on 21/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^BtnDidMoveBlock) (NSInteger offset);
typedef void(^BtnDidEndMoveBlock) (NSInteger offset);
@interface TrachBtn : UIButton

@property (strong ,nonatomic) BtnDidMoveBlock  block;
@property (strong ,nonatomic) BtnDidEndMoveBlock  endMoveBlock;
@property (weak ,nonatomic) UIView * locationView;
@end
