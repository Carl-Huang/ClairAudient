//
//  MyUploadDetailCell.h
//  ClairAudient
//
//  Created by vedon on 12/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyUploadDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

-(void)configureCellWithDescription:(NSString *)description content:(NSString *)content;
@end
