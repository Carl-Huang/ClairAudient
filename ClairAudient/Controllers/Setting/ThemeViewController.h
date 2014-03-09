//
//  ThemeViewController.h
//  ClairAudient
//
//  Created by Carl on 14-1-6.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "CommonViewController.h"

@interface ThemeViewController : CommonViewController

@property (weak, nonatomic) IBOutlet UIImageView *bgView;

- (IBAction)defaultTheme:(id)sender;
- (IBAction)simpleTheme:(id)sender;
- (IBAction)paowenTheme:(id)sender;
- (IBAction)froestTheme:(id)sender;
@end
