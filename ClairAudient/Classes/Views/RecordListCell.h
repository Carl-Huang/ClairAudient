//
//  RecordListCell.h
//  ClairAudient
//
//  Created by Carl on 14-1-18.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RecordMusicInfo;

@protocol ItemDidSelectedDelegate <NSObject>
-(void)playItem:        (id )object;
-(void)shareItem:       (id)object;
-(void)addToFavorite:   (id)object;
-(void)editItem:        (id)object;
-(void)deleteItem:      (id)object;
@end

@interface RecordListCell : UITableViewCell



@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *controlBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet UIButton *favBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *rubbishBtn;
@property (weak, nonatomic) IBOutlet UISlider *playSlider;
@property (assign ,nonatomic) id<ItemDidSelectedDelegate> delegate;
@property (strong ,nonatomic) RecordMusicInfo * musicInfo;

- (IBAction)playMusicAction:(id)sender;
- (IBAction)shareMusicAction:(id)sender;
- (IBAction)addToFavoriteAction:(id)sender;
- (IBAction)editMusicAction:(id)sender;
- (IBAction)deleteMusicAction:(id)sender;


@end
