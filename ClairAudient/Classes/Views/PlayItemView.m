//
//  PlayItemView.m
//  ClairAudient
//
//  Created by vedon on 12/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "PlayItemView.h"

@implementation PlayItemView

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
-(void)awakeFromNib
{
    [super awakeFromNib];
    
    
    UIImage *minImage =     [[UIImage imageNamed:@"MinimumTrackImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    UIImage *maxImage =     [UIImage imageNamed:@"record_19"];
    UIImage *thumbImage =   [UIImage imageNamed:@"record_20"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateHighlighted];
    
    
//    [self.playSlider setThumbImage:[UIImage imageNamed:@"record_20"] forState:UIControlStateNormal];
//    [self.playSlider setThumbImage:[UIImage imageNamed:@"record_20"] forState:UIControlStateHighlighted];
//    [self.playSlider setMinimumTrackImage:[UIImage imageNamed:@"MinimumTrackImage"] forState:UIControlStateNormal];
//    [self.playSlider setMaximumTrackImage:[UIImage imageNamed:@"record_19"] forState:UIControlStateNormal];

}
@end
