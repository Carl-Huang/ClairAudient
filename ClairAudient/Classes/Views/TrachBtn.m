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
    NSLog(@"PreviousOffsetX :%ld",(long)previewOffsetX);

    NSInteger offsetX   = 0;
    
    CGRect rect     = self.frame;
    offsetX = X;
    NSLog(@"Offset: %ld",(long)offsetX);
    previewOffsetX  = offsetX;
    rect.origin.x   = offsetX - self.frame.size.width/2.0;
    self.frame      = rect;
    
    if (self.block) {
        self.block(offsetX,self.frame.origin.x);
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  
}
@end
