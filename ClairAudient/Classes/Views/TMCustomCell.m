//
//  TMCustomCell.m
//  ClairAudient
//
//  Created by Carl on 14-1-10.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "TMCustomCell.h"
const CGFloat KTMViewCellMargin = 3;

@implementation TMCustomCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    _photoView = nil;
    _titleLabel = nil;
}

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}



-(UIImageView *)photoView
{
    if(!_photoView)
    {
        _photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photoView.contentMode = UIViewContentModeScaleAspectFill;
        _photoView.clipsToBounds = YES;
        [self addSubview:_photoView];
    }
    
    return _photoView;
}


-(UILabel *)titleLabel
{
    if(!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.hidden = NO;
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:_titleLabel];
        
    }
    
    return _titleLabel;
}

-(void)layoutSubviews
{
    self.photoView.frame = CGRectMake(0,20,115,115);
    self.titleLabel.frame = CGRectMake(45,16, self.bounds.size.width - 2 * KTMViewCellMargin, 20);
}
@end
