//
//  CopyMusicView.h
//  ClairAudient
//
//  Created by vedon on 9/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^DidClickBlock)(NSInteger btnNumber);
@interface CopyMusicView : UIView

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong ,nonatomic) DidClickBlock block;
-(void)initalizationContainerViewContent;
@end
