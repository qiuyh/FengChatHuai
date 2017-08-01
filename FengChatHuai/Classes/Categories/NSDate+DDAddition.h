//
//  NSDate+DDAddition.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/19.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DDAddition)


- (NSString*)transformToFuzzyDate;

- (NSString*)promptDateString;

/**
 *  判断当前时间段是否在某一个时间段之间
 *
 *  @param fromDateStr 开始时间
 *  @param toDateStr   结束时间
 *
 *  @return BOOL value
 */
+ (BOOL)isCurrentDateBetweenFromDateStr:(NSString *)fromDateStr toDateStr:(NSString *)toDateStr;

@end
