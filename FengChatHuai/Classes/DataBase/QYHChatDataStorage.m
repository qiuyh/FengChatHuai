//
//  QYHChatDataStorage.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/6/7.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHChatDataStorage.h"

@implementation QYHChatDataStorage

+(instancetype)shareInstance
{
    static QYHChatDataStorage *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[QYHChatDataStorage alloc]init];
        
    });

    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _faceDictionary = [[NSMutableDictionary alloc]init];
        _usersArray   = [NSMutableArray array];
        _userDic = [NSMutableDictionary dictionary];
//        _messageArray = [NSMutableArray array];
        _homePath = [NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()];

    }
    return self;
}

@end
