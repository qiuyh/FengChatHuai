//
//  NSDate+DDAddition.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/19.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "NSDate+DDAddition.h"

static int localAndServerGap = 0;

@implementation NSDate (DDAddition)


- (NSString*)transformToFuzzyDate
{
    NSDate* nowDate = [NSDate date];
    
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //  通过已定义的日历对象，获取某个时间点的NSDateComponents表示，并设置需要表示哪些信息（NSYearCalendarUnit, NSMonthCalendarUnit, NSDayCalendarUnit等）
    NSDateComponents *nowDateComponents = [greCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit fromDate:nowDate];
    
    NSDateComponents *selfDateComponents = [greCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit fromDate:self];
    
    
    NSDateComponents *weeDateComponents = [[NSDateComponents alloc] init];
    [weeDateComponents setCalendar:[NSCalendar currentCalendar]];
    weeDateComponents.year = selfDateComponents.year;
    weeDateComponents.month = selfDateComponents.month;
    weeDateComponents.day = selfDateComponents.day;
    weeDateComponents.hour = 0;
    weeDateComponents.minute = 0;
    weeDateComponents.second = 0;
    
    NSDate* weeDate = [weeDateComponents date];
    NSInteger timeInterval = [nowDate timeIntervalSinceDate:weeDate];
    
    NSUInteger selfTnterval = [nowDate timeIntervalSinceDate:self];
    if (selfTnterval < 3 * 60)
    {
        return @"刚刚";
    }
    else if (selfTnterval < 60 * 60)
    {
        NSString* dateString = [NSString stringWithFormat:@"%u分钟前",(unsigned int)selfTnterval / 60];
        return dateString;
    }
    else if (selfTnterval < 24 * 60 * 60 && nowDateComponents.day == selfDateComponents.day)
    {
        NSString* dateString = [NSString stringWithFormat:@"%u小时前",(unsigned int)selfTnterval / (60 * 60)];
        return dateString;
    }
    else if (timeInterval < 48 * 60 * 60)
    {
        return @"昨天";
    }
    else if (nowDateComponents.weekOfYear == selfDateComponents.weekOfYear)
    {
        NSArray* weekdays = @[@"temp",@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
        NSString* dateString = weekdays[selfDateComponents.weekday];
        return dateString;
    }
    else if ([self timeIntervalSince1970] == 0)
    {
        return nil;
    }
    else
    {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yy/MM/dd"];
        NSString* dateString = [dateFormatter stringFromDate:self];
        return dateString;
    }
}

- (NSString*)promptDateString
{
    NSDate* nowDate = [NSDate date];
    
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //  通过已定义的日历对象，获取某个时间点的NSDateComponents表示，并设置需要表示哪些信息（NSYearCalendarUnit, NSMonthCalendarUnit, NSDayCalendarUnit等）
    NSDateComponents *nowDateComponents = [greCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit fromDate:nowDate];
    
    NSDateComponents *selfDateComponents = [greCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit fromDate:self];
    
    NSDateComponents *weeDateComponents = [[NSDateComponents alloc] init];
    [weeDateComponents setCalendar:[NSCalendar currentCalendar]];
    weeDateComponents.year = selfDateComponents.year;
    weeDateComponents.month = selfDateComponents.month;
    weeDateComponents.day = selfDateComponents.day;
    weeDateComponents.hour = 0;
    weeDateComponents.minute = 0;
    weeDateComponents.second = 0;
    
    NSDate* weeDate = [[weeDateComponents date] dateByAddingTimeInterval:24 * 60 * 60];
    
    NSString* lastComponents = nil;
    //    NSString* twoComponent = nil;
    NSInteger hour = selfDateComponents.hour;
    
    if (selfDateComponents.minute < 10)
    {
        lastComponents = [NSString stringWithFormat:@"%li:0%li",(long)hour,(long)selfDateComponents.minute];
    }
    else
    {
        lastComponents = [NSString stringWithFormat:@"%li:%li",(long)hour,(long)selfDateComponents.minute];
    }
    
    NSInteger timeInterval = [nowDate timeIntervalSinceDate:weeDate];
    
    NSString* dateString = nil;
    if (timeInterval < 24 * 60 * 60)
    {
        if (nowDateComponents.day == selfDateComponents.day) {
            //同一天
            if (selfDateComponents.hour <= 4) {
                dateString = [NSString stringWithFormat:@"凌晨 %@",lastComponents];
            }else if (selfDateComponents.hour <= 12){
                dateString = [NSString stringWithFormat:@"上午 %@",lastComponents];
            }else if (selfDateComponents.hour <= 18){
                dateString = [NSString stringWithFormat:@"下午 %@",lastComponents];
            }else{
                dateString = [NSString stringWithFormat:@"晚上 %@",lastComponents];
            }
            //            dateString = lastComponents;
        }
        else
        {
            //昨天
            dateString = [NSString stringWithFormat:@"昨天 %@",lastComponents];
        }
    }
    else if (nowDateComponents.weekOfMonth == selfDateComponents.weekOfMonth)
    {
        //在同一个周中
        NSArray* weekdays = @[@"temp",@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
        NSString* weekdayString = weekdays[selfDateComponents.weekday];
        dateString = [NSString stringWithFormat:@"%@%@",weekdayString,lastComponents];
    }
    else if (nowDateComponents.year == selfDateComponents.year)
    {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM月dd日"];
        dateString = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:self],lastComponents];
    }else
    {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        dateString = [NSString stringWithFormat:@"%@ %@",[dateFormatter stringFromDate:self],lastComponents];
    }
    
    
    return dateString;
}

+ (void)setServerTime:(int)serverTime
{
    int localTime = [[NSDate date] timeIntervalSince1970];
    localAndServerGap = serverTime - localTime;
}

+ (NSUInteger)messageDate
{
    int localDate = [[NSDate date] timeIntervalSince1970];
    return localDate + localAndServerGap;
}



+ (BOOL)isCurrentDateBetweenFromDateStr:(NSString *)fromDateStr toDateStr:(NSString *)toDateStr
{
    NSDate *fromDate = [NSDate getCustomDate:fromDateStr];
    NSLog(@">>> fromDate :%@", fromDate);
    
    NSDate *toDate   = [NSDate getCustomDate:toDateStr];
    NSLog(@">>> toDate :%@", toDate);
    
    NSDate *currentDate = [NSDate date];
    NSLog(@">>> currentDate :%@",currentDate);
    
    if ([currentDate compare:fromDate]== NSOrderedDescending &&
        [currentDate compare:toDate] == NSOrderedAscending)
    {
        NSLog(@">>> 当前时间在 %@-%@ 免打扰时间之内！！！", fromDateStr, toDateStr);
        return YES;
    }
    
    NSLog(@">>> 当前时间不在 %@-%@ 免打扰时间之内！！！", fromDateStr, toDateStr);
    
    return NO;
}

+ (NSDate *)getCustomDate:(NSString *)timeStr
{
    //获取当前时间
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currentComps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    
    
    NSInteger hour   = [[timeStr substringToIndex:2] integerValue];
    NSInteger minute = [[timeStr substringFromIndex:3] integerValue];
    
    
    //设置当天的某个点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    [resultComps setMinute:minute];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [resultCalendar dateFromComponents:resultComps];
}



@end
