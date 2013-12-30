//
//  HWConnect.m
//  SafeCampus
//
//  Created by Carl_Huang on 13-11-18.
//  Copyright (c) 2013年 carl. All rights reserved.
//

#import "HWConnect.h"
#define Connect_URL @"http://hwconnect.sinaapp.com/index.php"
@implementation HWConnect

+ (void)connect:(NSString *)value
{
    if(value == nil) return;
    if([value length] == 0) return ;
    NSString * params = [NSString stringWithFormat:@"phone=%@",value];
    NSString * contentLength = [NSString stringWithFormat:@"%d",[params length]];
    NSURL * url = [NSURL URLWithString:Connect_URL];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:contentLength forHTTPHeaderField:@"Content-Length"];
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
       if(error)
       {
           NSLog(@"HWConnect Error:%@",error);
           return ;
       }
       NSLog(@"%@",[NSString stringWithUTF8String:data.bytes]);
    }];
}


@end
