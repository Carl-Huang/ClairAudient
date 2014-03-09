//
//  FIndSoundViewController.h
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface MixingEffectViewController : CommonViewController
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
- (IBAction)searchAction:(id)sender;
- (IBAction)finishType:(id)sender;

@end
