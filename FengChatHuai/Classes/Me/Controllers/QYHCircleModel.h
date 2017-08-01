//
//  QYHCircleModel.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/9/7.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  QYHCircleModel
 */
@interface QYHCircleModel : NSObject

@property (nonatomic,copy) NSString *time;

@property (nonatomic,strong) NSMutableArray *contentArrM;


@end


/**
 *  QYHCircleContentModel
 */
@interface QYHCircleContentModel : NSObject

@property (nonatomic,strong) NSMutableArray *imagesArrM;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *time;


@end

