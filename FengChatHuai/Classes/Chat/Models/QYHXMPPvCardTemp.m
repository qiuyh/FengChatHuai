//
//  QYHXMPPvCardTemp.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/1.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHXMPPvCardTemp.h"


@implementation QYHXMPPvCardTemp

+(instancetype)shareInstance{
    static QYHXMPPvCardTemp *vCard = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vCard = [[QYHXMPPvCardTemp alloc]init];
    });
    
    return vCard;
}

-(XMPPvCardTemp *)vCard:(NSString *)user{
    
    // 1.得到data
    NSString *userPath;
    if (user) {
        
        if ([user isEqualToString:[QYHAccount shareAccount].loginUser]) {
            userPath = @"myVCard";
        }else{
            userPath = user;
        }
    }else{
        userPath = @"myVCard";
    }
 
    NSString *path=[NSString stringWithFormat:@"%@%@%@",[QYHChatDataStorage shareInstance].homePath,[QYHAccount shareAccount].loginUser,userPath];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    // 2.创建反归档对象
    
    NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    // 3.解码并存到数组中
    
    QYHXMPPvCardTemp *vCardTemp  = [unArchiver decodeObjectForKey:[NSString stringWithFormat:@"%@%@",userPath,[QYHAccount shareAccount].loginUser]];
    
    XMPPvCardTemp *vCard = vCardTemp.vCard;
    
    return vCard;

}


-(void)setVCard:(QYHXMPPvCardTemp *)vCardTemp byUser:(NSString *)user{
    // 1.创建可变的data对象，装数据
    
    NSMutableData *data = [NSMutableData data];
    
    // 2.创建归档对象
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    // 3.把对象编码
    
    NSString *userPath;
    if (user) {
        
        if ([user isEqualToString:[QYHAccount shareAccount].loginUser]) {
            userPath = @"myVCard";
        }else{
            userPath = user;
        }
    }else{
        userPath = @"myVCard";
    }

    
    [archiver encodeObject:vCardTemp forKey:[NSString stringWithFormat:@"%@%@",userPath,[QYHAccount shareAccount].loginUser]];
    
    // 4.编码完成
    
    [archiver finishEncoding];
    
    // 5.保存归档
    
    //取到沙盒路径
    NSString *path=[NSString stringWithFormat:@"%@%@%@",[QYHChatDataStorage shareInstance].homePath,[QYHAccount shareAccount].loginUser,userPath];
    
    [data writeToFile:path atomically:YES];

}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.vCard forKey:@"vCard"];
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.vCard = [aDecoder decodeObjectForKey:@"vCard"];
        
    }
    
    return self;
}


@end
