//
//  QYHHistoryImage.h
//  FengChatHuai
//
//  Created by 邱永槐 on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface QYHHistoryImage : NSManagedObject

@property (nonatomic, retain) NSData * headerImage;
@property (nonatomic, retain) NSString * imageText;
@property (nonatomic, retain) NSDate * time;

@end
