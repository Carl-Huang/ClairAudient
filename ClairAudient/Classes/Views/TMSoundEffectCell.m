//
//  TMSoundEffectCell.m
//  ClairAudient
//
//  Created by Carl on 14-1-17.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "TMSoundEffectCell.h"
#define KTMViewCellMargin 3
@implementation TMSoundEffectCell

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
    _backgroundImageView = nil;
    _iconImageView = nil;
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

- (UIImageView *)backgroundImageView
{
    if(!_backgroundImageView)
    {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        _backgroundImageView.image = [UIImage imageNamed:@"hunyin_23"];
        [self addSubview:_backgroundImageView];
    }
    return _backgroundImageView;
}


- (UIImageView *)iconImageView
{
    if(!_iconImageView)
    {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        [self addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel
{
    if(!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.hidden = NO;
        _titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [self addSubview:_titleLabel];
        
    }
    
    return _titleLabel;
}

- (void)layoutSubviews
{
    self.backgroundImageView.frame = CGRectMake(KTMViewCellMargin, KTMViewCellMargin, self.bounds.size.width - KTMViewCellMargin * 2, self.bounds.size.height - KTMViewCellMargin * 2);
    self.iconImageView.frame = CGRectMake(KTMViewCellMargin + 5, (self.bounds.size.height - 22) * 0.5, 22, 22);
    self.titleLabel.frame = CGRectMake(KTMViewCellMargin + 5 + 22,  (self.bounds.size.height - 22) * 0.5, 58, 22);
}


@end
