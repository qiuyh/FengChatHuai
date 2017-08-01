//
//  QYHImageModelClass.h
//  FengChatHuai
//
//  Created by 邱永槐 on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "QYHHistoryImage.h"


@interface QYHImageModelClass : NSObject

//保存数据
//-(void)save:(NSData *) image ImageText:(NSString *) imageText;
//查询所有的图片
-(NSArray *) queryAll;

@end
