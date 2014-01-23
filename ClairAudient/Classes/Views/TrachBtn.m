//
//  TrachBtn.m
//  ClairAudient
//
//  Created by vedon on 21/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "TrachBtn.h"

@implementation TrachBtn

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
    
    
    NSInteger X         = point.x + self.frame.size.width/2.0;

    NSLog(@"Touch Moved:%ld",(long)X);
    NSInteger offsetX = 0;
    offsetX         = X;
    CGRect rect     = self.frame;
    NSLog(@"Offset: %ld",(long)offsetX);
    if (X > 320) {
        rect.origin.x   = 320 - self.frame.size.width/2.0;
    }else
    {
        rect.origin.x   = point.x;
    }
    self.frame      = rect;

    if (self.block) {
        self.block(offsetX,self.frame.origin.x);
    }

   
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  
}
@end
