//
//  QYHFMDBmanager.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/6/12.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHFMDBmanager.h"
#import "QYHChatMssegeModel.h"
#import "FMDatabase.h"
#import "QYHContactModel.h"

@implementation QYHFMDBmanager
{
    NSString *_lastTime;
    
}

+(instancetype)shareInstance
{
    static QYHFMDBmanager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[QYHFMDBmanager alloc]init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //初始化数据库
        NSString *filePath = [NSString stringWithFormat:@"%@/Documents/chatMssege.db", NSHomeDirectory()];
        
        NSLog(@"filePath==%@",filePath);
        
        self.basae = [FMDatabaseQueue databaseQueueWithPath:filePath];
    }
    return self;
}

- (void)createTale{
    
    [self.basae inDatabase:^(FMDatabase *db) {
        
        if (![db open])
        {
            NSLog(@"数据库打开失败");
        }
        
        //创建表
        if (![db executeUpdate:[NSString stringWithFormat:@"create table if not exists Chat%@Mssege (id integer primary key autoincrement,messegeID text,fromUserID text,toUserID text,type integer,status integer,audioTime integer,imageType integer,ratioHW float,content text,time text,isRead bool,isReadVioce bool)",[QYHAccount shareAccount].loginUser]])
        {
            NSLog(@"创建聊天信息表失败");
        }
        
        if (![db executeUpdate:[NSString stringWithFormat:@"create table if not exists AddFriend%@Mssege (id integer primary key autoincrement,messegeID text,fromUserID text,toUserID text,type integer,status integer,content text,time text,isRead bool)",[QYHAccount shareAccount].loginUser]])
        {
            NSLog(@"创建添加好友信息表失败");
        }

        
    }];

}

#pragma mark - 聊天信息

- (void)insertChatMessege:(QYHChatMssegeModel *)messege completion:(InsertCompletion)completion
{
    [self.basae inDatabase:^(FMDatabase *db) {
        
        if ([db executeUpdate:[NSString stringWithFormat:@"insert into Chat%@Mssege (messegeID,fromUserID,toUserID,type,status,audioTime,imageType,ratioHW,content,time,isRead,isReadVioce) values (?,?,?,?,?,?,?,?,?,?,?,?)",[QYHAccount shareAccount].loginUser],messege.messegeID,messege.fromUserID,messege.toUserID,@(messege.type),@(messege.status),@(messege.audioTime),@(messege.imageType),@(messege.ratioHW),messege.content,messege.time,@(messege.isRead),@(messege.isReadVioce)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
        
    }];
}

-(void)updateIsAllReadMessegeByFromUserID:(NSString *)fromUserID completion:(UpdateAllCompletion)completion
{
    [self.basae inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:[NSString stringWithFormat:@"update Chat%@Mssege set isRead = ? where (fromUserID = ? or (fromUserID = ? and toUserID = ?)) and isRead = ?",[QYHAccount shareAccount].loginUser],@(YES),fromUserID,[QYHAccount shareAccount].loginUser,fromUserID,@(NO)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
        
    }];
}


-(void)updateLastNoReadMessegeByMessegeModel:(QYHChatMssegeModel *)messegeModel completion:(UpdateAllCompletion)completion
{
    [self.basae inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:[NSString stringWithFormat:@"update Chat%@Mssege set isRead = ? where messegeID = ? and isRead = ?",[QYHAccount shareAccount].loginUser],@(NO),messegeModel.messegeID,@(YES)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
        
    }];
}


-(void)updateIsReadVoioceMessegeBymessegeID:(NSString *)messegeID completion:(UpdateVoiceCompletion)completion
{
    [self.basae inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:[NSString stringWithFormat:@"update Chat%@Mssege set isReadVioce = ? where messegeID = ? and isReadVioce = ?",[QYHAccount shareAccount].loginUser],@(YES),messegeID,@(NO)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }];
}

-(void)updateMessegeContentByMessegeModel:(QYHChatMssegeModel *)messegeModel completion:(UpdateContentCompletion)completion{
    
    [self.basae inDatabase:^(FMDatabase *db) {
        
        if ([db executeUpdate:[NSString stringWithFormat:@"update Chat%@Mssege set content = ? where messegeID = ?",[QYHAccount shareAccount].loginUser],messegeModel.content,messegeModel.messegeID])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
        
    }];
}

- (void)updateMessegeStatusByMessegeModel:(QYHChatMssegeModel *)messegeModel completion:(UpdateStatusCompletion)completion{
    [self.basae inDatabase:^(FMDatabase *db) {
        
        if ([db executeUpdate:[NSString stringWithFormat:@"update Chat%@Mssege set status = ? where messegeID = ?",[QYHAccount shareAccount].loginUser],@(messegeModel.status),messegeModel.messegeID])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
        
    }];
}

-(void)deleteChatMessegeByFromUserID:(NSString *)fromUserID completion:(DeleteCompletion)completion
{
    [self.basae inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:[NSString stringWithFormat:@"delete from Chat%@Mssege where fromUserID = ? or (fromUserID = ? and toUserID = ?)",[QYHAccount shareAccount].loginUser],fromUserID,[QYHAccount shareAccount].loginUser,fromUserID])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }];
}

-(void)deleteChatMessegeByMessegeID:(NSString *)messegeID completion:(DeleteCompletion)completion{
    
    [self.basae inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:[NSString stringWithFormat:@"delete from Chat%@Mssege where messegeID = ?",[QYHAccount shareAccount].loginUser],messegeID])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }];
}

-(void)queryAllChatMessegeByFromUserID:(NSString *)fromUserID orToUserID:(NSString *)toUserID completion:(QueryCompletion)completion
{
    [self.basae inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db  executeQuery:[NSString stringWithFormat:@"select * from Chat%@Mssege where fromUserID = ? or (fromUserID = ? and toUserID = ?)",[QYHAccount shareAccount].loginUser],fromUserID,toUserID,fromUserID];
        NSMutableArray* array = [[NSMutableArray alloc] init];
        
        if (rs)
        {
            _lastTime = @"2016-06-19 01:11";
            
            while ([rs next])
            {
                QYHChatMssegeModel *messegeModel = [[QYHChatMssegeModel alloc]init];
                
                messegeModel.messegeID   = [rs stringForColumn:@"messegeID"];
                messegeModel.fromUserID  = [rs stringForColumn:@"fromUserID"];
                messegeModel.toUserID    = [rs stringForColumn:@"toUserID"];
                messegeModel.content     = [rs stringForColumn:@"content"];
                messegeModel.time        = [rs stringForColumn:@"time"];
                messegeModel.type        = [rs intForColumn:@"type"];
                messegeModel.status      = [rs intForColumn:@"status"];
                messegeModel.audioTime   = [rs intForColumn:@"audioTime"];
                messegeModel.imageType   = [rs intForColumn:@"imageType"];
                messegeModel.ratioHW     = [rs doubleForColumn:@"ratioHW"];
                messegeModel.isRead      = [rs boolForColumn:@"isRead"];
                messegeModel.isReadVioce = [rs boolForColumn:@"isReadVioce"];
                
                if (![NSString isMinute:messegeModel.time compare:_lastTime]) {
                    
                    [array addObject:messegeModel.time];
                }
                
                [array addObject:messegeModel];
                
                _lastTime = messegeModel.time;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,YES);
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil,NO);
            });
        }
    }];
}

- (void)queryAllUnReadChatMessegeByFromUserID:(NSString *)fromUserID orToUserID:(NSString *)toUserID completion:(QueryUnReadCompletion)completion{
    [self.basae inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db  executeQuery:[NSString stringWithFormat:@"select * from Chat%@Mssege where fromUserID = ? or (fromUserID = ? and toUserID = ?)",[QYHAccount shareAccount].loginUser],fromUserID,toUserID,fromUserID];
        
        NSInteger unReadCount = 0;
        
        if (rs)
        {
            while ([rs next])
            {
                if (![rs boolForColumn:@"isRead"]) {
                    unReadCount ++;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(unReadCount,YES);
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(0,NO);
            });
        }
    }];
}

- (void)queryAllUnReadChatMessegeCompletion:(QueryUnReadCompletion)completion{
    
    [self.basae inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db  executeQuery:[NSString stringWithFormat:@"select * from Chat%@Mssege",[QYHAccount shareAccount].loginUser]];
        
        NSInteger unReadCount = 0;
        
        if (rs)
        {
            while ([rs next])
            {
                if (![rs boolForColumn:@"isRead"]) {
                    unReadCount ++;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(unReadCount,YES);
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(0,NO);
            });
        }
    }];
}

#pragma mark - 添加好友信息

- (void)insertAddFriendMessege:(QYHChatMssegeModel *)messege completion:(InsertCompletion)completion{
    
    [self.basae inDatabase:^(FMDatabase *db) {
        
        if ([db executeUpdate:[NSString stringWithFormat:@"insert into AddFriend%@Mssege (messegeID,fromUserID,toUserID,type,status,content,time,isRead) values (?,?,?,?,?,?,?,?)",[QYHAccount shareAccount].loginUser],messege.messegeID,messege.fromUserID,messege.toUserID,@(messege.type),@(messege.addStatus),messege.content,messege.time,@(messege.isRead)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
        
    }];

}

- (void)updateIsAllReadAddFriendMessegeCompletion:(UpdateAllCompletion)completion{
    
    [self.basae inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:[NSString stringWithFormat:@"update AddFriend%@Mssege set isRead = ? where isRead = ?",[QYHAccount shareAccount].loginUser],@(YES),@(NO)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
        
    }];

}

- (void)updateAddFriendMessegeStatusByMessegeModel:(QYHChatMssegeModel *)messegeModel completion:(UpdateStatusCompletion)completion{
    [self.basae inDatabase:^(FMDatabase *db) {
        
        if ([db executeUpdate:[NSString stringWithFormat:@"update AddFriend%@Mssege set status = ? where messegeID = ?",[QYHAccount shareAccount].loginUser],@(messegeModel.addStatus),messegeModel.messegeID])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
        
    }];
}

- (void)deleteAllAddFriendMessegeCompletion:(DeleteCompletion)completion{
    [self.basae inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:[NSString stringWithFormat:@"delete from AddFriend%@Mssege",[QYHAccount shareAccount].loginUser]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }];

}

- (void)deleteAddFriendMessegeByMessegeID:(NSString *)messegeID completion:(DeleteCompletion)completion{
    [self.basae inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:[NSString stringWithFormat:@"delete from AddFriend%@Mssege where messegeID = ?",[QYHAccount shareAccount].loginUser],messegeID])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }];
    
}


- (void)deleteAddFriendMessegeByFromUserID:(NSString *)fromUserID  completion:(DeleteCompletion)completion{
    [self.basae inDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:[NSString stringWithFormat:@"delete from AddFriend%@Mssege where fromUserID = ?",[QYHAccount shareAccount].loginUser],fromUserID])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }];

}

- (void)queryAllAddFriendMessegeCompletion:(QueryCompletion)completion{
    [self.basae inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db  executeQuery:[NSString stringWithFormat:@"select * from AddFriend%@Mssege",[QYHAccount shareAccount].loginUser]];
        NSMutableArray* array = [[NSMutableArray alloc] init];
        
        if (rs)
        {
            while ([rs next])
            {
                QYHChatMssegeModel *messegeModel = [[QYHChatMssegeModel alloc]init];
                
                messegeModel.messegeID   = [rs stringForColumn:@"messegeID"];
                messegeModel.fromUserID  = [rs stringForColumn:@"fromUserID"];
                messegeModel.toUserID    = [rs stringForColumn:@"toUserID"];
                messegeModel.content     = [rs stringForColumn:@"content"];
                messegeModel.time        = [rs stringForColumn:@"time"];
                messegeModel.type        = [rs intForColumn:@"type"];
                messegeModel.addStatus   = [rs intForColumn:@"status"];
                messegeModel.isRead      = [rs boolForColumn:@"isRead"];
                
                [array addObject:messegeModel];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array,YES);
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil,NO);
            });
        }
    }];
}

- (void)queryAllUnReadAddFriendMessegeCompletion:(QueryUnReadCompletion)completion{
    
    [self.basae inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db  executeQuery:[NSString stringWithFormat:@"select * from AddFriend%@Mssege",[QYHAccount shareAccount].loginUser]];
        
        NSInteger unReadCount = 0;
        
        if (rs)
        {
            while ([rs next])
            {
                if (![rs boolForColumn:@"isRead"]) {
                    unReadCount ++;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(unReadCount,YES);
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(0,NO);
            });
        }
    }];
}


#pragma mark - 总--


- (void)queryAllMessegeByUserArray:(NSArray *)userArray completion:(QueryAllMessageCompletion)completion{
    
    [self.basae inDatabase:^(FMDatabase *db) {
        
        /**
         *
         *
         *  添加好友记录
         *
         *
         */
        
        FMResultSet *rs = [db  executeQuery:[NSString stringWithFormat:@"select * from AddFriend%@Mssege",[QYHAccount shareAccount].loginUser]];
        NSMutableArray* array = [[NSMutableArray alloc] init];
        
        if (rs) {
            NSLog(@"获取添加好友记录成功");
        }else{
            NSLog(@"获取添加好友记录失败");
        }

        while ([rs next])
        {
            QYHChatMssegeModel *messegeModel = [[QYHChatMssegeModel alloc]init];
            
            messegeModel.messegeID   = [rs stringForColumn:@"messegeID"];
            messegeModel.fromUserID  = [rs stringForColumn:@"fromUserID"];
            messegeModel.toUserID    = [rs stringForColumn:@"toUserID"];
            messegeModel.content     = [rs stringForColumn:@"content"];
            messegeModel.time        = [rs stringForColumn:@"time"];
            messegeModel.type        = [rs intForColumn:@"type"];
            messegeModel.addStatus   = [rs intForColumn:@"status"];
            messegeModel.isRead      = [rs boolForColumn:@"isRead"];
            
            [array addObject:messegeModel];
            
        }
        
        
        /**
         *
         *
         *  聊天记录
         *
         *
         */
        
        NSMutableArray *arrM = [NSMutableArray array];
        
        for (QYHContactModel *user in userArray) {
            
            FMResultSet *rs1 = [db  executeQuery:[NSString stringWithFormat:@"select * from Chat%@Mssege where fromUserID = ? or (fromUserID = ? and toUserID = ?)",[QYHAccount shareAccount].loginUser],user.jid.user,[QYHAccount shareAccount].loginUser,user.jid.user];
            
            NSMutableArray* array1 = [[NSMutableArray alloc] init];
            
            if (rs1) {
                NSLog(@"获取聊天记录成功");
            }else{
                NSLog(@"获取聊天记录失败");
            }
            
            _lastTime = @"2016-06-19 01:11";
            
            while ([rs1 next])
            {
                QYHChatMssegeModel *messegeModel = [[QYHChatMssegeModel alloc]init];
                
                messegeModel.messegeID   = [rs1 stringForColumn:@"messegeID"];
                messegeModel.fromUserID  = [rs1 stringForColumn:@"fromUserID"];
                messegeModel.toUserID    = [rs1 stringForColumn:@"toUserID"];
                messegeModel.content     = [rs1 stringForColumn:@"content"];
                messegeModel.time        = [rs1 stringForColumn:@"time"];
                messegeModel.type        = [rs1 intForColumn:@"type"];
                messegeModel.status      = [rs1 intForColumn:@"status"];
                messegeModel.audioTime   = [rs1 intForColumn:@"audioTime"];
                messegeModel.imageType   = [rs1 intForColumn:@"imageType"];
                messegeModel.ratioHW     = [rs1 doubleForColumn:@"ratioHW"];
                messegeModel.isRead      = [rs1 boolForColumn:@"isRead"];
                messegeModel.isReadVioce = [rs1 boolForColumn:@"isReadVioce"];
                
                if (![NSString isMinute:messegeModel.time compare:_lastTime])
                {
                    
                    [array1 addObject:messegeModel.time];
                }
                
                [array1 addObject:messegeModel];
                
                _lastTime = messegeModel.time;
            }
            
            if (array1.count) {
                 [arrM addObject:array1];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(array,arrM);
        });
        
    }];
}

- (void)queryAllUnReadCompletion:(QueryUnReadCompletion)completion{
    
    [self.basae inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs1 = [db  executeQuery:[NSString stringWithFormat:@"select * from AddFriend%@Mssege",[QYHAccount shareAccount].loginUser]];
        
        NSInteger unReadCount = 0;
        
        if (rs1)
        {
            while ([rs1 next])
            {
                if (![rs1 boolForColumn:@"isRead"]) {
                    unReadCount ++;
                }
            }
            
            
        }
        
        FMResultSet *rs2 = [db  executeQuery:[NSString stringWithFormat:@"select * from Chat%@Mssege",[QYHAccount shareAccount].loginUser]];
        
        if (rs2)
        {
            while ([rs2 next])
            {
                if (![rs2 boolForColumn:@"isRead"]) {
                    unReadCount ++;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(unReadCount,YES);
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(unReadCount,NO);
            });
        }
        
    }];
    
}
@end
