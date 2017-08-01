//
//  QYHHistoryFrirend.h
//  FengChatHuai
//
//  Created by 邱永槐 on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface QYHHistoryFrirend : NSManagedObject

@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * jidStr;
@property (nonatomic, retain) NSDate * timestap;

@end
