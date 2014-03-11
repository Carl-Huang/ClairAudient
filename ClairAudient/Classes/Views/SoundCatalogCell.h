//
//  SoundCatalogCell.h
//  ClairAudient
//
//  Created by Carl on 14-1-10.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MixingOnlineBtn.h"
@interface SoundCatalogCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadCountLabel;

@property (weak, nonatomic) IBOutlet MixingOnlineBtn *playBtn;
@end
