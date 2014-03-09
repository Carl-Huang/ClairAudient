//
//  MusicFansViewController.h
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MusicFansViewController : CommonViewController

- (IBAction)showIntegralChampionVC:(id)sender;
- (IBAction)showCatalogRankVC:(id)sender;
- (IBAction)showDownloadRankVC:(id)sender;
- (IBAction)showRecommendSoundVC:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@end
