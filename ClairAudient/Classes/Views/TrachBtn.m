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
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint  point = [touches.anyObject locationInView:self.locationView];
    NSLog(@"Touch Moved:%f",point.x
          );
    CGRect rect = self.frame;
    rect.origin.x = point.x - self.frame.size.width/2.0;
    self.frame = rect;
    
    
    if (self.block) {
        self.block(point.x);
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint  point = [touches.anyObject locationInView:self.locationView];
    NSLog(@"Touch Moved:%f",point.x
          );
    CGRect rect = self.frame;
    rect.origin.x = point.x - self.frame.size.width/2.0;
    self.frame = rect;
    
    
    if (self.endMoveBlock) {
        self.endMoveBlock(point.x);
    }

}
@end
