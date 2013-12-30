//
//  UIImage+Util.m
//  YouLa
//
//  Created by Carl on 13-12-5.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "UIImage+Util.h"
#import <QuartzCore/QuartzCore.h>
@implementation UIImage (Util)
+ (UIImage *)imageFromView:(UIView *)view
{
    CGRect rect = view.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


- (UIImage *)imageWithScale:(CGFloat)scale
{
    float scaleWith = self.size.width * scale;
    float scaleHeight = self.size.height * scale;
    UIGraphicsBeginImageContext(CGSizeMake(scaleWith, scaleHeight));
    [self drawInRect:CGRectMake(0, 0, scaleWith, scaleHeight)];
    UIImage * scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

- (UIImage *)imageWithSize:(CGSize)size
{
    float width = size.width;
    float height = size.height;
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, width, height)];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  image;
}
@end
