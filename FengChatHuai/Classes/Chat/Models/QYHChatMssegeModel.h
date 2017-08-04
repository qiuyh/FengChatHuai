//
//  QYHChatMssegeModel.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/6/12.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>

//枚举Cell类型
typedef enum : NSUInteger {
    SendText,
    SendImage,
    SendVoice,
    SendNewCircle,
    SendAddFriend,
    SendDeleteFrien
    
} MySendContentType;


typedef enum : NSUInteger {
    HImageType,
    VImageType
    
} imageType;

typedef NS_ENUM(NSUInteger, ChatMessageStatus)
{
    ChatMessageSending =0,
    ChatMessageSendFailure =1,
    ChatMessageSendSuccess =2
};

typedef NS_ENUM(NSUInteger, AddFriendStatus)
{
    AddFriendNormer =0,
    AddFriendAgreed =1,
    AddFriendReject =2,
    AddAgreeded =3,
    AddRejected =4
};

@interface QYHChatMssegeModel : NSObject

@property (nonatomic,copy) NSString *messegeID;
@property (nonatomic,copy) NSString *fromUserID;
@property (nonatomic,copy) NSString *toUserID;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *time;
@property (nonatomic,assign) MySendContentType type;
@property (nonatomic,assign) ChatMessageStatus status;
@property (nonatomic,assign) AddFriendStatus   addStatus;
@property (nonatomic,assign) NSInteger audioTime;
@property (nonatomic,assign) imageType imageType;
@property (nonatomic,assign) CGFloat ratioHW;
@property (nonatomic,assign) BOOL isRead;
@property (nonatomic,assign) BOOL isReadVioce;



@end
