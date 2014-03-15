//
//  TrachBtn.m
//  ClairAudient
//
//  Created by vedon on 21/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "TrachBtn.h"

@implementation TrachBtn
@synthesize criticalValue;
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint  point = [touches.anyObject locationInView:self.locationView];
    previewOffsetX = point.x - self.frame.size.width/2.0;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint  point = [touches.anyObject locationInView:self.locationView];
    
    
    NSInteger offsetX = point.x;

    if (offsetX >= 0 && offsetX <= criticalValue) {
        CGRect rect     = self.frame;
        NSLog(@"OffsetX: %ld",(long)offsetX);
//        if (offsetX > criticalValue) {
//            rect.origin.x   = criticalValue - self.frame.size.width;
//        }else
//        {
//            rect.origin.x   = point.x;
//        }
        rect.origin.x   = point.x;
        self.frame      = rect;
        
        if (self.block) {
            self.block(offsetX,self.frame.origin.x);
        }

    }
}

-(void)dealloc
{
    if (self.block) {
        _block = nil;
    }
}
@end
