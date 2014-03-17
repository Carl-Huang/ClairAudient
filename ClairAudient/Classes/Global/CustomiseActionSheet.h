//
//  CustomiseActionSheet.h
//  iThermo
//
//  Created by vedon on 12/7/13.
//  Copyright (c) 2013 xtremeprog.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomiseActionSheet : NSObject<UIActionSheetDelegate>
@property(retain,nonatomic)NSArray *titles;
@property(nonatomic,assign)NSInteger destructiveButtonIndex;
@property(nonatomic,assign)NSInteger cancelButtonIndex;

-(id)initWithTitles:(NSArray *)_array;
-(NSInteger)showInView:(UIView *)_view;
@end
