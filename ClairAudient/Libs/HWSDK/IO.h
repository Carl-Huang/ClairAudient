//
//  IO.h
//  HWSDK
//  
//  Created by Carl_Huang on 13-11-18.
//  Copyright (c) 2013年 HelloWorld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IO : NSObject
#pragma mark - Class Methods
/*
 * @desc 根据当前的时间生成字符串，精确到毫秒
 * @return NSString 时间字符串
 */
+ (NSString *)generateRndString;
/*
 * @desc 取得当前沙盒Document路径
 * @return NSString 当前沙盒Document路径
 */
+ (NSString *)documentPath;
/*
 * @desc 根据目录和文件名，取得对应URL,相对于沙盒document目录
 * 如果目录为nil，那么将返回沙盒document目录+文件名的URL
 * @param NSString name 文件名称
 * @param NSString directory 目录名称
 * @return NSURL 对应文件URL
 */
+ (NSURL *)URLForResource:(NSString *)name inDirectory:(NSString *)directory;
/*
 * @desc 获取沙盒document目录下面的所有文件，不包括目录
 * @return NSArray 包含沙盒目录下所有文件对应文件NSURL的数组
 */
+ (NSArray *)fecthFilesInDocPath;
/*
 * @desc 获取指定目录名称下的所有文件的路径，该目录需包含于沙盒document目录
 * @param NSString path 目录名称
 * @return NSArray 包含指定目录下所有文件的路径(NSString)的数组
 */
+ (NSArray *)fetchFilesInPath:(NSString *)path;
/*
 * @desc 获取沙盒目录下的所有子目录的名称
 * @return NSArray 包含所有子目录名称的(NSString)数据
 */
+ (NSArray *)fetchSubDirectoryInDoc;
/*
 * @desc 将图片保存到沙盒document目录下
 * @param NSData data 图片二进制数据
 * @return BOOL 是否成功
 */
+ (BOOL)writeImageToDocument:(NSData *)data;
/*
 * @desc 将图片保存到沙盒document目录下的directory目录里面
 * @param directory 目录名称,需位于沙盒document目录下面
 * @param NSData data 图片二进制数据
 * @return BOOL 是否成功
 */
+ (BOOL)writeImageToDirectory:(NSString *)directory withData:(NSData *)data;
/*
 * @desc 创建目录,位于沙盒document下
 * @param NSString dicrectoryName 目录名称
 * @return BOOL 是否创建成功
 */
+ (BOOL)createDirectoryInDocument:(NSString *)dicrectoryName;
/*
 * @desc 根据指定的目录跟文件名创建文件，相对于沙盒document目录
 * @param NSString directory 目录名称
 * @param NSString fileName 文件名称
 * @return BOOL 是否成功
 */
+ (BOOL)createFileInDirectory:(NSString *)directory withFileName:(NSString *)fileName;
@end
