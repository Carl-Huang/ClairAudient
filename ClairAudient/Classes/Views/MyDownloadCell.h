//
//  MyDownloadCell.h
//  ClairAudient
//
//  Created by Carl on 14-1-16.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyDownloadCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *rubbishButton;
@property (weak, nonatomic) IBOutlet UIButton *controlButton;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
