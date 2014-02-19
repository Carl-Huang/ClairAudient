//
//  User.m
//  ClairAudient
//
//  Created by Carl on 14-1-19.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "User.h"
#define User_Key @"User_Info"
@implementation User
+ (void)saveToLocal:(User *)user
{
    NSDictionary * userInfo = [[self class] toDictionary:user];
    [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:User_Key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (User *)userFromLocal
{
    NSDictionary * userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:User_Key];
    if (userInfo) {
        User * user = [[self class] fromDictionary:userInfo withClass:[User class]];
        return user;
    }else
    {
        return  nil;
    }

}
@end
