//
//  QYHDiscoverHeight.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/22.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYHDiscoverHeight : NSObject

@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,assign) CGFloat contentLabelHeight;
@property (nonatomic,assign) CGFloat photosViewHeight;
@property (nonatomic,assign) CGFloat commentViewHeight;
@property (nonatomic,assign) CGFloat nameButtonWith;

@property (nonatomic,assign) CGFloat oneImageWith;
@property (nonatomic,assign) CGFloat oneImageHeight;

@property (nonatomic,assign) CGSize  supportSize;

@property (nonatomic,strong) NSMutableArray *commentHeightArray;

@property (nonatomic,assign) BOOL isOpening;

- (void)setCellHeightByDic:(NSDictionary *)dic;
@end
