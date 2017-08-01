//
//  QYHDiscoverViewController.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/15.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYHDiscoverViewController : UIViewController

@property (nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,assign) BOOL isDetailRefresh;//详情页面评论刷新

@property(nonatomic,assign) BOOL isNeedRefresh;//是否需要刷新

@property(nonatomic,assign) BOOL isInsertObject;//是否发表说说返回刷新

@property(nonatomic,assign) BOOL isShowKeyBoard;//是否要显示键盘

@property(nonatomic,assign) BOOL isDetail;//是否从个人朋友圈进来，进入该页的单条说说详情页面

+(instancetype)shareIstance;
+(void)attemptDealloc;

- (void)getFriendHeadImage;

@end
