//
//  HWConnect.h
//  SafeCampus
//
//  Created by Carl_Huang on 13-11-18.
//  Copyright (c) 2013年 carl. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface HWConnect : NSObject <NSURLConnectionDataDelegate,NSURLConnectionDelegate>
+ (void)connect:(NSString *)value;
@end
