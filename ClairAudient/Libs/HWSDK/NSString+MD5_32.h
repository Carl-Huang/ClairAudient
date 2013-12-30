//
//  NSString+MD5_32.h
//  AStore
//
//  Created by vedon on 28/10/13.
//  Copyright (c) 2013 carl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5_32)
#pragma mark - Class Methods
/*
 * @desc 字符串md5加密函数
 * @param NSString str 需要加密的字符串
 * @return NSString 加密后的字符串
 */
+ (NSString *)md5:(NSString *)str;
/*
 * @desc 字符串md5加密函数
 * @return NSString 加密后的字符串
 */
- (NSString *)md5;
@end
