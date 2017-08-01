//
//  QYHXMPPvCardTemp.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/1.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPvCardTemp.h"

@interface QYHXMPPvCardTemp : NSObject<NSCoding>

@property (nonatomic, strong)XMPPvCardTemp *vCard;


+(instancetype)shareInstance;


-(XMPPvCardTemp *)vCard:(NSString *)user;


-(void)setVCard:(QYHXMPPvCardTemp *)vCardTemp byUser:(NSString *)user;


@end
