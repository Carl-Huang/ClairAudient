//
//  CloneView.h
//  ClairAudient
//
//  Created by vedon on 24/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloneView : UIView
@property(nonatomic, weak) UIView *srcView;
-(id)initWithView:(UIView *)src;
@end
