//
//  MixingMusicListCell.h
//  ClairAudient
//
//  Created by Carl on 14-1-16.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MixingMusicListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *littleTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bigTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
