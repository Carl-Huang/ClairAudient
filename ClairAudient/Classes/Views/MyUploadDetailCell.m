//
//  MyUploadDetailCell.m
//  ClairAudient
//
//  Created by vedon on 12/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "MyUploadDetailCell.h"

@implementation MyUploadDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithDescription:(NSString *)description content:(NSString *)content
{
    self.descriptionLabel.text  = description;
    self.contentLabel.text      = content;
}

@end
