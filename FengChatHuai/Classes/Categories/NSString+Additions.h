//
//  NSString+Additions.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/19.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Additions)


/**
 *	@brief	固定电话区号格式化（将形如 01085792889 格式化为 010-85792889）
 *
 *	@return	返回格式化后的号码（形如 010-85792889）
 */
- (NSString*)areaCodeFormat;

/**
 *	@brief	验证固定电话区号是否正确（e.g. 010正确，040错误）
 *
 *	@return	返回固定电话区号是否正确
 */
- (BOOL)isAreaCode;

+(NSString*)dictionaryToJson:(NSDictionary *)dic;


/**
 *  doc沙盒路径
 */
+ (NSString *)documentPath;


/**
 *  cache沙盒路径
 */
+ (NSString *)cachePath;

/**
 *  是否超过3分钟
 *
 */

+ (BOOL)isOutThreeSeconde:(NSString *)dateString;

/**
 *  当前具体时间
 */
+ (NSString *)formatCurDate;

/**
 *  是否两个时间差在一分钟内
 */
+ (BOOL )isMinute:(NSString *)dateString1 compare:(NSString *)dateString2;

/**
 *  当前日期
 */
+ (NSString *)formatCurDay;

//+ (NSString *)formateDate:(NSString *)dateString;

+(NSString *)getMessageDateStringFromdateString:(NSString *)dateString andNeedTime:(BOOL)needTime;

/**
 *  获取App版本号
 */
+ (NSString *)getAppVer;


+ (NSString *)createUuid;


/**
 *  去除字符串回车
 */
- (NSString *)trim;


/**
 *  去除字符串所有空格
 */
- (NSString*)removeAllSpace;


- (NSURL *)toURL;

- (NSString *) MD5;

- (NSString *)stringByRemovingHTML;


/**
 * 是否包含子字符串
 */
- (BOOL) isContainsString:(NSString*)substring;

- (BOOL) isOlderVersionThan:(NSString*)otherVersion;

- (BOOL) isNewerVersionThan:(NSString*)otherVersion;

- (BOOL) checkTelNumberInput;

/* IP地址验证 */
- (BOOL) isValidateIP;

- (BOOL) isEmpty;


- (NSString *)replaceUnicode:(NSString *)unicodeStr;


/**
 *  获取字符串的尺寸
 *
 *  @param textContent 内容
 *  @param textFont    字体尺寸
 *  @param maxSize     最大尺寸
 *
 *  @return 计算后的尺寸size
 */
+ (CGSize)getContentSize:(NSString *)textContent
              fontOfSize:(CGFloat)textFont
             maxSizeMake:(CGSize)maxSize;

//是否包含表情
- (BOOL)stringContainsEmoji;


//邮箱
+ (BOOL) justEmail;

//手机号码验证
+ (BOOL) justMobile:(NSString *)string;

//车牌号验证
+ (BOOL) justCarNo;

//车型
+ (BOOL) justCarType;

//用户名
+ (BOOL) justUserName;

//密码
+ (BOOL) justPassword;

//昵称
+ (BOOL) justNickname;

//身份证号
+ (BOOL) justIdentityCard;


+ (NSString *)acodeId;


@end
