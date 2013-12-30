//
//  OSHelper.m
//  HWSDK
//
//  Created by Carl_Huang on 13-11-18.
//  Copyright (c) 2013年 HelloWorld. All rights reserved.
//

#import "OSHelper.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <SystemConfiguration/SCNetworkReachability.h>
@implementation OSHelper
+ (BOOL)iPad
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? YES : NO;
}
//判断是否是iPhone
+ (BOOL)iPhone
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? YES : NO;
}
//判断是否是iPhone5
+ (BOOL)iPhone5
{
    return [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO;
}
//取得ios的版本
+ (float)versionOfIOS
{
    return [[UIDevice currentDevice].systemVersion floatValue];
}

+ (BOOL)iOS7
{
    float version = [[self class] versionOfIOS];
    return version >= 7.0;
}

//判断是否网络可用
+ (BOOL)isReachable
{
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    /*
     struct sockaddr_in zeroAddress;
     bzero(&zeroAddress,sizeof(zeroAddress));  //初始化结构体
     zeroAddress.sin_len = sizeof(zeroAddress);
     zeroAddress.sin_family = AF_INET;  //设置地址家族
     zeroAddress.sin_port = htons(8421);  //设置端口
     zeroAddress.sin_addr.s_addr = inet_addr("192.168.117.186");  //设置地址
     */
    struct sockaddr_storage zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.ss_len = sizeof(zeroAddress);
    zeroAddress.ss_family = AF_INET;
    //Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    //获得连接的标志
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    defaultRouteReachability == NULL ? : CFRelease(defaultRouteReachability);
    
    //如果不能获取连接标志，则不能连接网络，直接返回
    if(!didRetrieveFlags)
    {
        return NO;
    }
    //根据获得的连接标志进行判断
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkReachabilityFlagsConnectionRequired;
    
    return (isReachable && !needsConnection) ? YES : NO;
}

+ (NSString *)macAddressOfWIFI
{
    return nil;
}



+(NSString *)macAddress
{
	int                 mib[6];
	size_t              len;
	char                *buf;
	unsigned char       *ptr;
	struct if_msghdr    *ifm;
	struct sockaddr_dl  *sdl;
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1/n");
		return NULL;
	}
	
	if ((buf = malloc(len)) == NULL) {
		printf("Could not allocate memory. error!/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 2");
		return NULL;
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	// NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
	return [outstring uppercaseString];
}

+ (NSString *)appName
{
    NSDictionary * dic = [[NSBundle mainBundle] infoDictionary];
    return [dic objectForKey:@"CFBundleDisplayName"];
}

+ (NSString *)appVersion
{
    NSDictionary * dic = [[NSBundle mainBundle] infoDictionary];
    return [dic objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appBuildVersion
{
    NSDictionary * dic = [[NSBundle mainBundle] infoDictionary];
    return [dic objectForKey:@"CFBundleVersion"];
}

@end
