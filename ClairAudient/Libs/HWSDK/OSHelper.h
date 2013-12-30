//
//  OSHelper.h
//  HWSDK
//
//  Created by Carl_Huang on 13-11-18.
//  Copyright (c) 2013年 HelloWorld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSHelper : NSObject
/*
 * @desc 判断是否是iPad
 * @return BOOL
 */
+ (BOOL)iPad;
/*
 * @desc 判断是否是iPhone
 * @return BOOL
 */
+ (BOOL)iPhone;
/*
 * @desc 判断是否是iPhone
 * @return BOOL
 */
+ (BOOL)iPhone5;
/*
 * @desc 取得系统的版本号
 * @return float 系统版本
 */
+ (float)versionOfIOS;
/**
  * @desc 判断是否是iOS7
  * @return BOOL
  */
+ (BOOL)iOS7;

/*
 * @desc 判断是否是网络是否可达
 * @return BOOL
 */
+ (BOOL)isReachable;
/*
 * @desc 取得应用名称
 * @return NSString 应用名称
 */
+ (NSString *)appName;
/*
 * @desc 取得应用版本
 * @return NSString 应用版本
 */
+ (NSString *)appVersion;
/*
 * @desc 取得应用build版本
 * @return NSString 应用build版本
 */
+ (NSString *)appBuildVersion;
/*
 * @desc 取得设置网卡的mac地址
 * @return NSString mac地址
 */
+ (NSString *)macAddress;
/*
 * @desc 取得wifi的ssid
 * @return NSString Wifi的SSID
 */
+ (NSString *)macAddressOfWIFI;


@end
