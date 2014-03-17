//
//  CustomiseActionSheet.m
//  iThermo
//
//  Created by vedon on 12/7/13.
//  Copyright (c) 2013 xtremeprog.com. All rights reserved.
//

#import "CustomiseActionSheet.h"

@implementation CustomiseActionSheet
{
    UIActionSheet * _actionSheet;
    NSInteger _selectedIndex;
}
@synthesize titles=_titles;
@synthesize destructiveButtonIndex=_destructiveButtonIndex;
@synthesize cancelButtonIndex=_cancelButtonIndex;

-(id)initWithTitles:(NSArray *)_array
{
    self=[super init];
    if (self) {
        _titles=_array;
        _destructiveButtonIndex = 0;
        _cancelButtonIndex = _array.count - 1;
    }
    return self;
    
}

- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    _cancelButtonIndex = titles.count - 1;
}
-(NSInteger)showInView:(UIView *)_view
{
    _actionSheet=[[UIActionSheet alloc]init];
    [_actionSheet setDelegate:self];
    for (NSString *title in _titles) {
        [_actionSheet addButtonWithTitle:title];
    }
    if (_destructiveButtonIndex != -1) {
        _actionSheet.destructiveButtonIndex = _destructiveButtonIndex;
    }
    if (_cancelButtonIndex != -1) {
        _actionSheet.cancelButtonIndex = _cancelButtonIndex;
    }
    [_actionSheet showInView:_view];
    CFRunLoopRun();
    return _selectedIndex;

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    _selectedIndex = buttonIndex;
    _actionSheet = nil;
    CFRunLoopStop(CFRunLoopGetCurrent());
}
@end
