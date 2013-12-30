//
//  VersionManager.m
//  YueXing100
//
//  Created by Carl on 13-12-15.
//  Copyright (c) 2013年 Yoo. All rights reserved.
//

#import "VersionManager.h"

@implementation VersionManager
+ (void)checkUpdate:(NSString *)appID compleitionBlock:(void (^)(BOOL hasNew,NSError * error))completionHandle
{
    if(!appID)
    {
        NSLog(@"The appID is nil.");
        
        if(completionHandle)
        {
            completionHandle(NO,[NSError errorWithDomain:@"The appID is nil" code:100 userInfo:nil]);
        }
        return;
    }
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appID]];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError)
        {
            NSLog(@"%@",connectionError);
            if(completionHandle)
            {
                completionHandle(NO,connectionError);
            }
            return ;
        }
        
        NSError * parseError;
        id jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&parseError];
        if(parseError)
        {
            if(completionHandle)
            {
                completionHandle(NO,parseError);
                return ;
            }
        }
        NSLog(@"%@",jsonDictionary);
        NSArray * results = [jsonDictionary objectForKey:@"results"];
        
        if([results count] == 0)
        {
            NSLog(@"Check update failed.");
            completionHandle(NO,[NSError errorWithDomain:@"Check update failed." code:100 userInfo:nil]);
            return ;
        }
        
        //取得最新版本信息
        NSDictionary * newInfo = [results objectAtIndex:0];
        NSString * newVersion = [newInfo objectForKey:@"version"];
        //取得本机版本信息
        NSDictionary * nowInfo = [[NSBundle mainBundle] infoDictionary];
        NSString * nowVersion = [nowInfo objectForKey:@"CFBundleVersion"];
        //比较版本信息
        if([nowVersion floatValue] >= [newVersion floatValue])
        {
            //已经是最新版本了
            NSLog(@"No update.");
            if (completionHandle) {
                completionHandle(NO,nil);
            }
        }
        else
        {
            //有更新版本
            NSLog(@"New Version");
            if(completionHandle){
                completionHandle(YES,nil);
            }
        }

        
        
    }];
    
}
@end
