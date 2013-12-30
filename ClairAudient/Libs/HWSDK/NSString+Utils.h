//
//  NSString+Utils.h
//  HWSDK
//
//  Created by Carl on 13-11-25.
//  Copyright (c) 2013年 HelloWorld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)
/**
   @desc 过滤html标签
   @return NSString 
  */
- (NSString *)filterHTML;
@end
