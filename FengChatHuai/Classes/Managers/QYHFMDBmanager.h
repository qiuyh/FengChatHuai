//
//  QYHFMDBmanager.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/6/12.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"
#import "QYHChatMssegeModel.h"

typedef void(^InsertCompletion)       (BOOL result);
typedef void(^UpdateAllCompletion)    (BOOL result);
typedef void(^UpdateVoiceCompletion)  (BOOL result);
typedef void(^UpdateContentCompletion)(BOOL result);
typedef void(^UpdateStatusCompletion)(BOOL result);
typedef void(^DeleteCompletion)       (BOOL result);
typedef void(^QueryCompletion)      (NSArray *messagesArray,BOOL result);
typedef void(^QueryUnReadCompletion)(NSInteger count,BOOL result);

typedef void(^QueryAllMessageCompletion) (NSArray *addFriendArray,NSArray *messagesArray);

@interface QYHFMDBmanager : NSObject


@property (nonatomic,strong)FMDatabaseQueue *basae;


+ (instancetype)shareInstance;

- (void)createTale;

#pragma mark - 聊天信息

- (void)insertChatMessege:(QYHChatMssegeModel *)messege completion:(InsertCompletion)completion;

- (void)updateIsAllReadMessegeByFromUserID:(NSString *)fromUserID completion:(UpdateAllCompletion)completion;

-(void)updateLastNoReadMessegeByMessegeModel:(QYHChatMssegeModel *)messegeModel completion:(UpdateAllCompletion)completion;

- (void)updateIsReadVoioceMessegeBymessegeID:(NSString *)messegeID completion:(UpdateVoiceCompletion)completion;

- (void)updateMessegeContentByMessegeModel:(QYHChatMssegeModel *)messegeModel completion:(UpdateContentCompletion)completion;

- (void)updateMessegeStatusByMessegeModel:(QYHChatMssegeModel *)messegeModel completion:(UpdateStatusCompletion)completion;

- (void)deleteChatMessegeByFromUserID:(NSString *)fromUserID completion:(DeleteCompletion)completion;

- (void)deleteChatMessegeByMessegeID:(NSString *)messegeID completion:(DeleteCompletion)completion;

- (void)queryAllChatMessegeByFromUserID:(NSString *)fromUserID orToUserID:(NSString *)toUserID completion:(QueryCompletion)completion;

- (void)queryAllUnReadChatMessegeByFromUserID:(NSString *)fromUserID orToUserID:(NSString *)toUserID completion:(QueryUnReadCompletion)completion;

- (void)queryAllUnReadChatMessegeCompletion:(QueryUnReadCompletion)completion;

#pragma mark - 添好友信息

- (void)insertAddFriendMessege:(QYHChatMssegeModel *)messege completion:(InsertCompletion)completion;

- (void)updateIsAllReadAddFriendMessegeCompletion:(UpdateAllCompletion)completion;

//- (void)updateIsReadOrNoReadAddFriendMessegeByMessegeID:(NSString *)messegeID completion:(UpdateAllCompletion)completion;

- (void)updateAddFriendMessegeStatusByMessegeModel:(QYHChatMssegeModel *)messegeModel completion:(UpdateStatusCompletion)completion;

- (void)deleteAllAddFriendMessegeCompletion:(DeleteCompletion)completion;

- (void)deleteAddFriendMessegeByFromUserID:(NSString *)fromUserID  completion:(DeleteCompletion)completion;

- (void)deleteAddFriendMessegeByMessegeID:(NSString *)messegeID completion:(DeleteCompletion)completion;

- (void)queryAllAddFriendMessegeCompletion:(QueryCompletion)completion;

- (void)queryAllUnReadAddFriendMessegeCompletion:(QueryUnReadCompletion)completion;


#pragma mark - 总---
- (void)queryAllUnReadCompletion:(QueryUnReadCompletion)completion;


- (void)queryAllMessegeByUserArray:(NSArray *)userArray completion:(QueryAllMessageCompletion)completion;

@end
