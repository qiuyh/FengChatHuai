//
//  QYHFriendModelClass.h
//  FengChatHuai
//
//  Created by 邱永槐 on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QYHHistoryFrirend.h"

@interface QYHFriendModelClass : NSObject

//插入历史好友
-(void)saveHistoryFriend:(NSString *)nickName WithJid:(NSString *) jidStr;
-(NSArray *) queryAll;
-(void) deleteFriendWithJid:(NSString *)jidStr;

@end
