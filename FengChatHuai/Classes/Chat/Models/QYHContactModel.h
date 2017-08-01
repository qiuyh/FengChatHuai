//
//  QYHContactModel.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/6/13.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPvCardTemp.h"

@interface QYHContactModel : NSObject<NSCoding>


@property (nonatomic, strong)XMPPvCardTemp *vCard;
@property (nonatomic, strong) XMPPJID *jid;
@property (nonatomic, strong) NSString * nickname;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSNumber * sectionNum;


@end
