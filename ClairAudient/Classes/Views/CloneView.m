//
//  CloneView.m
//  ClairAudient
//
//  Created by vedon on 24/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "CloneView.h"

@implementation CloneView
@synthesize srcView;
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
-(id)initWithView:(UIView *)src {
    self = [super initWithFrame:src.frame];
    if (self) {
        srcView = src;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(srcView.bounds.size);
    [srcView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * imageView = [[UIImageView alloc]initWithImage:resultingImage];
    [self addSubview:imageView];
    UIGraphicsEndImageContext();
//    [srcView.layer renderInContext:UIGraphicsGetCurrentContext()];
}
@end
