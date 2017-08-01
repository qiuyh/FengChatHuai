//
//  QYHHttpTool.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/23.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HttpToolProgressBlock)(CGFloat progress);
typedef void (^HttpToolCompletionBlock)(NSError *error);

@interface QYHHttpTool : NSObject


-(void)uploadData:(NSData *)data
              url:(NSURL *)url
   progressBlock : (HttpToolProgressBlock)progressBlock
       completion:(HttpToolCompletionBlock) completionBlock;

/**
 下载数据
 */
-(void)downLoadFromURL:(NSURL *)url
        progressBlock : (HttpToolProgressBlock)progressBlock
            completion:(HttpToolCompletionBlock) completionBlock;


-(NSString *)fileSavePath:(NSString *)fileName;



@end
