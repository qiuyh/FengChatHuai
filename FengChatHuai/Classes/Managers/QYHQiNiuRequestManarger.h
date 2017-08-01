//
//  QYHQiNiuRequestManarger.h
//  Original
//
//  Created by 邱永槐 on 16/4/23.
//  Copyright © 2016年 qiuyognhuai. All rights reserved.
//

#import <Foundation/Foundation.h>
//成功回调
typedef void (^qiNIuSuccess)(id responseObject);
//失败回调
typedef void (^qiNIuFailure)(NSError *error);

typedef void (^qiNIuProgress)(CGFloat progress);

@interface QYHQiNiuRequestManarger : NSObject

+ (instancetype)shareInstance;

//上传多张图片
- (void)updateFile:(NSString *)fileNmae
       photoNumber:(NSString *)photoNumber
       photosArray:(NSArray *)photosArray
           Success:(qiNIuSuccess)success
           failure:(qiNIuFailure)failure
      partProgress:(qiNIuProgress)prtProgress
     totalProgress:(qiNIuProgress)tolProgress;

- (void)updateFile:(NSString *)fileNmae
       photoNumber:(NSString *)photoNumber
              data:(NSData *)data
           Success:(qiNIuSuccess)success
           failure:(qiNIuFailure)failure
          progress:(qiNIuProgress)progress;


- (void)updateFile:(NSString *)fileNmae
   withphotoNumber:(NSString *)photoNumber
              data:(NSData *)data
           Success:(qiNIuSuccess)success
           failure:(qiNIuFailure)failure
          progress:(qiNIuProgress)progress;

- (void)getAllTrendsByUserArray:(NSArray *)array
                        success:(qiNIuSuccess)success
                        failure:(qiNIuFailure)failure;

- (void)getFile:(NSString *)fileNmae
withphotoNumber:(NSString *)photoNumber
        Success:(qiNIuSuccess)success
        failure:(qiNIuFailure)failure;

- (void)getDataFromeQiNiuByfile:(NSString *)fileNmae
                        Success:(qiNIuSuccess)success
                        failure:(qiNIuFailure)failure;

@end
