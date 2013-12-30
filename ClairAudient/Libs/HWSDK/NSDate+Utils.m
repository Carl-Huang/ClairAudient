//
//  NSDate+Utils.m
//  HWSDK
//
//  Created by Carl on 13-11-6.
//  Copyright (c) 2013年 carl. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)
#pragma mark - Class Methods
+ (NSDate *)dateFromString:(NSString *)dateString
{
    NSString * format = @"YYYY-MM-dd";
    return [[self class] dateFromString:dateString withFormat:format];
}

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)format
{
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = format;
    return [dateFormatter dateFromString:dateString];
}

+ (NSString *)formatDateString:(NSString *)format withDate:(NSDate *)date
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:date];
}


#pragma mark - Instance Methods
- (NSString *)formatDateString:(NSString *)format
{
    if(!format)
        format = @"YYYY-MM-dd";
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = format;
    NSString * dateString = [dateFormatter stringFromDate:self];
    dateFormatter = nil;
    return dateString;
}

- (NSString *)weekDayForCurrentDate
{
    NSArray * weekDays = @[@"星期天",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
    NSCalendar * calender = [NSCalendar currentCalendar];
    NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
    NSInteger units = NSWeekdayCalendarUnit;
    dateComponents = [calender components:units fromDate:self];
    int week = [dateComponents weekday];
    return [weekDays objectAtIndex:week - 1];
}




@end
