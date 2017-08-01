//
//  QYHChatDataStorage.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/6/7.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYHChatDataStorage : NSObject

+ (instancetype)shareInstance;

@property (nonatomic,strong) NSArray *faceDataArray;

@property (nonatomic,strong) NSMutableDictionary *faceDictionary ;

@property (nonatomic,copy) NSString *homePath;

//@property (nonatomic,strong) NSMutableArray *messageArray;

@property (nonatomic,strong) NSMutableArray *usersArray;

@property (nonatomic,strong) NSMutableDictionary *userDic;

@end
