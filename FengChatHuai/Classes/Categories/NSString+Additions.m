//
//  NSString+Additions.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/19.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "NSString+Additions.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Additions)


/**
 *	@brief	固定电话区号格式化（将形如 01085792889 格式化为 010-85792889）
 *
 *	@return	返回格式化后的号码（形如 010-85792889）
 */
- (NSString*)areaCodeFormat
{
    // 先去掉两边空格
    NSMutableString *value = [NSMutableString stringWithString:[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    // 先匹配是否有连字符/空格，如果有则直接返回
    NSString *regex = @"^0\\d{2,3}[- ]\\d{7,8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    
    if([predicate evaluateWithObject:value]){
        // 替换掉中间的空格
        return [value stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    }
    
    // 格式化号码 三位区号
    regex = [NSString stringWithFormat:@"^(%@)\\d{7,8}$",[self regex_areaCode_threeDigit]];
    predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if([predicate evaluateWithObject:value]){
        // 插入连字符 "-"
        [value insertString:@"-" atIndex:3];
        return value;
    }
    
    
    // 格式化号码 四位区号
    regex = [NSString stringWithFormat:@"^(%@)\\d{7,8}$",[self regex_areaCode_fourDigit]];
    predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if([predicate evaluateWithObject:value]){
        // 插入连字符 "-"
        [value insertString:@"-" atIndex:4];
        return value;
    }
    
    return nil;
}

/**
 *	@brief	验证固定电话区号是否正确（e.g. 010正确，030错误）
 *
 *	@return	返回固定电话区号是否正确
 */
- (BOOL)isAreaCode
{
    
    NSString *regex = [NSString stringWithFormat:@"^%@|%@$",[self regex_areaCode_threeDigit],[self regex_areaCode_fourDigit]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if([predicate evaluateWithObject:self]){
        return YES;
    }
    
    return NO;
}


/**
 *	@brief	获取三位数区号的正则表达式（三位数区号形如 010）
 */
- (NSString*)regex_areaCode_threeDigit
{
    return @"010|02[0-57-9]";
}
/**
 *	@brief	获取四位数区号的正则表达式（四位数区号形如 0311）
 */
- (NSString*)regex_areaCode_fourDigit
{
    // 03xx
    NSString *fourDigit03 = @"03([157]\\d|35|49|9[1-68])";
    // 04xx
    NSString *fourDigit04 = @"04([17]\\d|2[179]|[3,5][1-9]|4[08]|6[4789]|8[23])";
    // 05xx
    NSString *fourDigit05 = @"05([1357]\\d|2[37]|4[36]|6[1-6]|80|9[1-9])";
    // 06xx
    NSString *fourDigit06 = @"06(3[1-5]|6[0238]|9[12])";
    // 07xx
    NSString *fourDigit07 = @"07(01|[13579]\\d|2[248]|4[3-6]|6[023689])";
    // 08xx
    NSString *fourDigit08 = @"08(1[23678]|2[567]|[37]\\d|5[1-9]|8[3678]|9[1-8])";
    // 09xx
    NSString *fourDigit09 = @"09(0[123689]|[17][0-79]|[39]\\d|4[13]|5[1-5])";
    
    return [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@",fourDigit03,fourDigit04,fourDigit05,fourDigit06,fourDigit07,fourDigit08,fourDigit09];
    
}

+(NSString *)dictionaryToJson:(NSDictionary *)dic

{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

+ (NSString *)documentPath {
    static NSString * path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                 objectAtIndex:0] copy];
    });
    return path;
}


+ (NSString *)cachePath {
    static NSString * path = nil;
    if (!path) {
        path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)
                 objectAtIndex:0] copy];
    }
    return path;
}

+ (NSString *)formatCurDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *result = [dateFormatter stringFromDate:[NSDate date]];
    
    return result;
}


+ (NSString *)formatCurDay {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *result = [dateFormatter stringFromDate:[NSDate date]];
    
    return result;
}


+ (NSString *)getAppVer {
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


- (NSURL *) toURL {
    return [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}



- (NSString *) MD5 {
    // Create pointer to the string as UTF8
    const char* ptr = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    
    return output;
}



- (NSString *)trim{
    return  [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (NSString*)removeAllSpace
{
    NSString* result = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"    " withString:@""];
    return result;
}


- (BOOL) isEmpty {
    return nil == self
    || 0 == [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
}


- (BOOL) isOlderVersionThan:(NSString*)otherVersion
{
    return ([self compare:otherVersion options:NSNumericSearch] == NSOrderedAscending);
}

- (BOOL) isNewerVersionThan:(NSString*)otherVersion
{
    return ([self compare:otherVersion options:NSNumericSearch] == NSOrderedDescending);
}


- (BOOL)checkTelNumberInput
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    //电话号码也能输入
    NSString *phoneRegex = @"1\\d{10}";
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSString *PHS1 = @"^(\\d{3,4}-)\\d{7,8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",PHS];
    NSPredicate *regextestphs1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",PHS1];
    if (([regextestphs evaluateWithObject:self] == YES)||[phoneTest evaluateWithObject:self] == YES ||[regextestphs1 evaluateWithObject:self] == YES){
        
        return YES;
    }else
    {
        return NO;
    }
    
    
    // return [phoneTest evaluateWithObject:self];
}
//限制表情输入
- (BOOL)stringContainsEmoji
{
    __block BOOL isEmoji = NO;
    
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
     
                             options:NSStringEnumerationByComposedCharacterSequences
     
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              
                              const unichar hs = [substring characterAtIndex:0];
                              
                              
                              if (0xd800 <= hs && hs <= 0xdbff) {
                                  
                                  if (substring.length > 1) {
                                      
                                      const unichar ls = [substring characterAtIndex:1];
                                      
                                      const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                      
                                      
                                      NSLog(@"表情编码 = %d",uc);
                                      if (uc == 0x1F981) {
                                          isEmoji = YES;
                                      }
                                      
                                      if (0x1d000 <= uc && uc <= 0x1f77f) {
                                          
                                          isEmoji = YES;
                                          
                                      }
                                      
                                  }
                                  
                              } else if (substring.length > 1) {
                                  
                                  const unichar ls = [substring characterAtIndex:1];
                                  
                                  if (ls == 0x20e3) {
                                      
                                      isEmoji = YES;
                                      
                                  }
                                  
                              } else {
                                  
                                  if (0x2100 <= hs && hs <= 0x27ff) {
                                      
                                      isEmoji = YES;
                                      
                                  } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                      
                                      isEmoji = YES;
                                      
                                  } else if (0x2934 <= hs && hs <= 0x2935) {
                                      
                                      isEmoji = YES;
                                      
                                  } else if (0x3297 <= hs && hs <= 0x3299) {
                                      
                                      isEmoji = YES;
                                      
                                  } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                      
                                      isEmoji = YES;
                                      
                                  }
                                  
                              }
                              
                          }];
    return isEmoji;
}


+ (NSString *)createUuid
{
    CFUUIDRef   uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref = CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString                    *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    __autoreleasing NSString    *r = [uuid lowercaseString];
    CFRelease(uuid_string_ref);
    return r;
}


- (NSString*)stringByRemovingHTML{
    
    NSString *html = self;
    NSScanner *thescanner = [NSScanner scannerWithString:html];
    NSString *text = nil;
    
    while ([thescanner isAtEnd] == NO) {
        [thescanner scanUpToString:@"<" intoString:NULL];
        [thescanner scanUpToString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
        html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
        
    }
    return html;
}


- (BOOL)isContainsString:(NSString*)substring
{
    NSRange range = [self rangeOfString : substring];
    BOOL found = ( range.location != NSNotFound );
    return found;
}


- (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}




+ (CGSize)getContentSize:(NSString *)textContent
              fontOfSize:(CGFloat)textFont
             maxSizeMake:(CGSize)maxSize;
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:textFont],
                                NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    
    CGRect aRect = [textContent boundingRectWithSize:CGSizeMake(maxSize.width, maxSize.height)
                                             options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes:attribute
                                             context:nil];
    
//    if (kSystemVersion>=10.0) {
//        
//        CGFloat spaceWith = 0;
//        
//        if(textContent){
//            for (int i=0; i<textContent.length; i++) {
//                NSRange range=NSMakeRange(i,1);
//                NSString *subString=[textContent substringWithRange:range];
//                if ([subString isEqualToString:@""]) {
//                    continue;
//                }
//                const char *cString=[subString UTF8String];
//                if (!cString) {
//                    continue;
//                }
//                if (strlen(cString)==3)
//                {
//                    spaceWith += 0.5;
//                }
//            }
//        }
//        
//        aRect.size.width += spaceWith;
//    }

    return aRect.size;
}


/* IP地址验证 */
- (BOOL)isValidateIP
{
    NSString *ipRegex = @"\\b(?:\\d{1,3}\\.){3}\\d{1,3}\\b";
    NSPredicate *ipTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipRegex];
    return [ipTest evaluateWithObject:self];
}


/* 邮箱验证 */
-(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/* 手机号码验证 */
-(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

/* 车牌号验证 */
BOOL validateCarNo(NSString* carNo)
{
    NSString *carRegex = @"^[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    return [carTest evaluateWithObject:carNo];
}


+ (BOOL )isMinute:(NSString *)dateString1 compare:(NSString *)dateString2
{
    dateString1 = [dateString1 substringToIndex:16];
    dateString2 = [dateString2 substringToIndex:16];
    
    if([dateString1 isEqualToString:dateString2]){
        return YES;
    }
    
    return NO;
}

+(BOOL)isOutThreeSeconde:(NSString *)dateString{
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (dateString.length > 17)
    {
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
    }else
    {
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    
    NSDate * nowDate = [NSDate date];
    
    //将需要转换的时间转换成 NSDate 对象
    NSDate * needFormatDate = [dateFormatter dateFromString:dateString];
    
    // 取当前时间和转换时间两个日期对象的时间间隔
    // 这里的NSTimeInterval 并不是对象，是基本型，其实是double类型，是由c定义的:  typedef double NSTimeInterval;
    NSTimeInterval time = [nowDate timeIntervalSinceDate:needFormatDate];
    
    // 再然后，把间隔的秒数折算成天数和小时数：
    
    if (time<=60*3) {  // 3分钟以内的
        
        return NO;
    }
    
    return YES;
}

+ (NSString *)formateDate:(NSString *)dateString
{
    @try {
        
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        
        if (dateString.length > 17)
        {
            
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
        }else
        {
            
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        }
        
        NSDate * nowDate = [NSDate date];
        
        //将需要转换的时间转换成 NSDate 对象
        NSDate * needFormatDate = [dateFormatter dateFromString:dateString];
        
        // 取当前时间和转换时间两个日期对象的时间间隔
        // 这里的NSTimeInterval 并不是对象，是基本型，其实是double类型，是由c定义的:  typedef double NSTimeInterval;
        NSTimeInterval time = [nowDate timeIntervalSinceDate:needFormatDate];
        
        // 再然后，把间隔的秒数折算成天数和小时数：
        
        NSString *dateStr = @"";
        
//        if (time<=60) {  // 1分钟以内的
//            
//            dateStr = @"刚刚";
//            
//        }else if(time<=60*60){  //  一个小时以内的
//            
//            int mins = time/60;
//            dateStr = [NSString stringWithFormat:@"%d分钟前",mins];
//            
//        }else
        if(time<=60*60*24){   // 在两天内的
            
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            NSString * need_yMd = [dateFormatter stringFromDate:needFormatDate];
            NSString *now_yMd = [dateFormatter stringFromDate:nowDate];
            
            [dateFormatter setDateFormat:@"HH:mm"];
            if ([need_yMd isEqualToString:now_yMd]) {
                //// 在同一天
//                dateStr = [NSString stringWithFormat:@"今天 %@",[dateFormatter stringFromDate:needFormatDate]];
                 dateStr = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:needFormatDate]];
            }else{
                ////  昨天
                dateStr = [NSString stringWithFormat:@"昨天 %@",[dateFormatter stringFromDate:needFormatDate]];
            }
        }else {
            
            [dateFormatter setDateFormat:@"yyyy"];
            NSString * yearStr = [dateFormatter stringFromDate:needFormatDate];
            NSString *nowYear = [dateFormatter stringFromDate:nowDate];
            
            if ([yearStr isEqualToString:nowYear]) {
                ////  在同一年
                [dateFormatter setDateFormat:@"MM-dd HH:mm"];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }else{
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }
        }
        
        return dateStr;
    }
    @catch (NSException *exception) {
        return @"";
    }
}


+(NSString *)getMessageDateStringFromdateString:(NSString *)dateString andNeedTime:(BOOL)needTime
{
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    if (dateString.length > 17)
    {
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
    }else
    {
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    
    //将需要转换的时间转换成 NSDate 对象
    NSDate * needFormatDate = [dateFormatter dateFromString:dateString];
    
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:<#(NSTimeInterval)#>];
    return [self getMessageDateString:needFormatDate andNeedTime:needTime];
}

+ (NSString*)getMessageDateString:(NSDate*)messageDate andNeedTime:(BOOL)needTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm"];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:messageDate];
    NSDate *msgDate = [cal dateFromComponents:components];
    
    NSString*weekday = [self getWeekdayWithNumber:components.weekday];
    
    components = [cal components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    
    if([today isEqualToDate:msgDate]){
        if (needTime) {
            [formatter setDateFormat:@"今天 HH:mm"];
        }
        else{
            [formatter setDateFormat:@"HH:mm"];
        }
        return [formatter stringFromDate:messageDate];
//        return @"2016-12-30";
    }
    
    components.day -= 1;
    NSDate *yestoday = [cal dateFromComponents:components];
    if([yestoday isEqualToDate:msgDate]){
        if (needTime) {
            [formatter setDateFormat:@"昨天 HH:mm"];
        }
        else{
            [formatter setDateFormat:@"昨天"];
        }
        return [formatter stringFromDate:messageDate];
    }
    
    for (int i = 1; i <= 6; i++) {
        components.day -= 1;
        NSDate *nowdate = [cal dateFromComponents:components];
        if([nowdate isEqualToDate:msgDate]){
            if (needTime) {
                [formatter setDateFormat:[NSString stringWithFormat:@"%@ HH:mm",weekday]];
            }
            else{
                [formatter setDateFormat:[NSString stringWithFormat:@"%@",weekday]];
            }
            return [formatter stringFromDate:messageDate];
        }
    }
    
    
    NSDate * nowDate  = [NSDate date];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearStr = [formatter stringFromDate:messageDate];
    NSString *nowYear = [formatter stringFromDate:nowDate];
    
    if ([yearStr isEqualToString:nowYear]) {
        ////  在同一年
        if (needTime) {
            [formatter setDateFormat:@"MM-dd HH:mm"];
        }else{
            [formatter setDateFormat:@"MM-dd"];
        }
        
        return [formatter stringFromDate:messageDate];
    }else{
        if (needTime) {
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        }else{
            [formatter setDateFormat:@"yyyy-MM-dd"];
        }
        
        return [formatter stringFromDate:messageDate];
    }

//    
//    while (1) {
//        components.day -= 1;
//        NSDate *nowdate = [cal dateFromComponents:components];
//        if ([nowdate isEqualToDate:msgDate]) {
//            if (!needTime) {
//                [formatter setDateFormat:@"YYYY/MM/dd"];
//            }
//            return [formatter stringFromDate:messageDate];
//            break;
//        }
//    }
}

//1代表星期日、如此类推
+(NSString *)getWeekdayWithNumber:(NSInteger)number
{
    switch (number) {
        case 1:
            return @"星期日";
            break;
        case 2:
            return @"星期一";
            break;
        case 3:
            return @"星期二";
            break;
        case 4:
            return @"星期三";
            break;
        case 5:
            return @"星期四";
            break;
        case 6:
            return @"星期五";
            break;
        case 7:
            return @"星期六";
            break;
        default:
            return @"";
            break;
    }
}



//邮箱
+ (BOOL) justEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}


//手机号码验证
+ (BOOL) justMobile:(NSString *)string
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:string];
}


//车牌号验证
+ (BOOL) justCarNo
{
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:self];
}


//车型
+ (BOOL) justCarType
{
    NSString *CarTypeRegex = @"^[\u4E00-\u9FFF]+$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CarTypeRegex];
    return [carTest evaluateWithObject:self];
}


//用户名
+ (BOOL) justUserName
{
    NSString *userNameRegex = @"^[A-Za-z0-9]{6,20}+$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    BOOL B = [userNamePredicate evaluateWithObject:self];
    return B;
}


//密码
+ (BOOL) justPassword
{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,20}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:self];
}


//昵称
+ (BOOL) justNickname
{
    NSString *nicknameRegex = @"^[\u4e00-\u9fa5]{4,8}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nicknameRegex];
    return [passWordPredicate evaluateWithObject:self];
}


//身份证号
+ (BOOL) justIdentityCard
{
//    BOOL flag;
//    if (self->length <= 0) {
//        flag = NO;
//        return flag;
//    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:self];
}

+(NSString *)acodeId{
    
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    dateForm.dateFormat = @"yyyyMMddHHmmss";
    NSString *currentTimeStr = [dateForm stringFromDate:[NSDate date]];

    return currentTimeStr ;
}

@end
