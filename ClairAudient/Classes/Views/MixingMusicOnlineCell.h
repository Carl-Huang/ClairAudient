//
//  MixingMusicListCell.h
//  ClairAudient
//
//  Created by Carl on 14-1-16.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MixingOnlineBtn.h"

@interface MixingMusicOnlineCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *littleTitleLabel;

@property (weak, nonatomic) IBOutlet MixingOnlineBtn *firstBtn;
@property (weak, nonatomic) IBOutlet MixingOnlineBtn *secondBtn;




@end
