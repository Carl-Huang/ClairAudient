//
//  UINavigationBar+Custom.m
//  ClairAudient
//
//  Created by Carl on 14-1-1.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "UINavigationBar+Custom.h"

@implementation UINavigationBar (Custom)
- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if(backgroundImage == nil)
    {
        NSLog(@"The background image is nil.");
    }
    UIImageView * backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    backgroundView.image = backgroundImage;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:backgroundView];
    [self bringSubviewToFront:backgroundView];
    backgroundView = nil;
}
@end
