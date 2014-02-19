//
//  RecordListCell.m
//  ClairAudient
//
//  Created by Vedon on 14-1-18.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "MyDownloadCell.h"
#import "DownloadMusicInfo.h"
@implementation MyDownloadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)playMusicAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(playItem:)]) {
        [self.delegate playItem:self.musicInfo];
    }
}

- (IBAction)shareMusicAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(shareItem:)]) {
        [self.delegate shareItem:self.musicInfo];
    }
}

- (IBAction)addToFavoriteAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(addToFavorite:)]) {
        [self.delegate addToFavorite:self.musicInfo];
    }
}

- (IBAction)editMusicAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(editItem:)]) {
        [self.delegate editItem:self.musicInfo];
    }
}

- (IBAction)deleteMusicAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(deleteItem:)]) {
        [self.delegate deleteItem:self.musicInfo];
    }
}
@end
