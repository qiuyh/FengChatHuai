//
//  QYHQiNiuRequestManarger.m
//  Original
//
//  Created by 邱永槐 on 16/4/23.
//  Copyright © 2016年 qiuyognhuai. All rights reserved.
//

#import "QYHQiNiuRequestManarger.h"
#import "QiniuSDK.h"
#import "QiniuPutPolicy.h"
#import "UIImageView+WebCache.h"
#import "NSDictionary+Valkidate.h"
#import "QYHContactModel.h"

/**
 *  注册七牛获取
 */
static NSString *QiniuAccessKey        = @"c2cCFhByfUAm1EWQIS_j8CFx2RZp1APuU8TG85VV";
static NSString *QiniuSecretKey        = @"iDhIvzXZSA7MplpFHnijlzQf6JBpjpCPVloZnaRx";
//static NSString *QiniuBucketName       = [NSString stringWithFormat:@"huaibucket:%@uploadfile.jpeg",@"e"];
static NSString *QiniuBaseURL          = @"7xt8p0.com2.z0.glb.qiniucdn.com";


@implementation QYHQiNiuRequestManarger


+ (instancetype)shareInstance
{
    static QYHQiNiuRequestManarger *manager=nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[QYHQiNiuRequestManarger alloc]init];
    });
    
    return manager;
}

#pragma mark - QINIU Method
- (NSString *)tokenWithScope:(NSString *)scope
{
    QiniuPutPolicy *policy = [QiniuPutPolicy new];
    policy.scope = scope;
    return [policy makeToken:QiniuAccessKey secretKey:QiniuSecretKey];
    
}

/**
 *  上传多张照片
 *
 *  @return <#return value description#>
 */

- (void)updateFile:(NSString *)fileNmae photoNumber:(NSString *)photoNumber photosArray:(NSArray *)photosArray Success:(qiNIuSuccess)success failure:(qiNIuFailure)failure partProgress:(qiNIuProgress)prtProgress totalProgress:(qiNIuProgress)tolProgress
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    __block CGFloat totalProgress = 0.0f;
    __block CGFloat partProgress = 1.0f / [photosArray count];
    __block NSUInteger currentIndex = 0;
    int count = 0;
    
    for (UIImage *image in photosArray) {
        
        NSData *data = UIImageJPEGRepresentation(image, 0.75);
        fileNmae = [NSString stringWithFormat:@"%d%@",count,fileNmae];
        count++;
        [self updateFile:fileNmae withphotoNumber:photoNumber data:data Success:^(id responseObject) {
            
            currentIndex++;
            
            totalProgress = partProgress*currentIndex;
            
            [array addObject:responseObject];
            
            if (currentIndex == photosArray.count) {
                success(array);
            }
            
            tolProgress(totalProgress);
            
        } failure:^(NSError *error) {
            failure(error);
        } progress:^(CGFloat progress) {
            prtProgress(progress);
        }];
    }
}

/**
 *  上传到相同的路径，覆盖之前的内容
 *
 *  @param fileNmae    <#fileNmae description#>
 *  @param photoNumber <#photoNumber description#>
 *  @param data        <#data description#>
 *  @param success     <#success description#>
 *  @param failure     <#failure description#>
 */

- (void)updateFile:(NSString *)fileNmae photoNumber:(NSString *)photoNumber data:(NSData *)data Success:(qiNIuSuccess)success failure:(qiNIuFailure)failure progress:(qiNIuProgress)progress
{
    
//    NSUserDefaults *accountPassword = [NSUserDefaults standardUserDefaults];
    NSString *customerID = photoNumber ? photoNumber:[QYHAccount shareAccount].loginUser;
    
    NSString *QiniuBucketName  = [NSString stringWithFormat:@"huaibucket:%@%@",customerID,fileNmae];
    NSString *qiNiukey         = [NSString stringWithFormat:@"%@%@",customerID,fileNmae];
    
    NSString *token = [self tokenWithScope:QiniuBucketName];
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%f",a];
    
    
    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil
                                               progressHandler:^(NSString *key, float percent){
                                                   
                                                   progress(percent);
                                               }
                                                        params:@{ @"x:foo":@"fooval" }
                                                      checkCrc:YES
                                            cancellationSignal:^BOOL{
                                                return NO;
                                            }];
    
    
    [upManager putData:data key:qiNiukey token:token
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  if (!info.error) {
                      
                      NSString *contentURL = [NSString stringWithFormat:@"http://%@/%@?_=%@",QiniuBaseURL,key,timeString];
                      
                      NSLog(@"QN Upload Success URL= %@",contentURL);
                      
                      success(contentURL);
                  }
                  else {
                      
                      NSLog(@"%@",info.error);
                      
                      failure(info.error);
                  }
              } option:opt];
    
}

/**
 *  上传到不同的路径，不覆盖之前的内容
 *
 *  @param fileNmae    <#fileNmae description#>
 *  @param photoNumber <#photoNumber description#>
 *  @param data        <#data description#>
 *  @param success     <#success description#>
 *  @param failure     <#failure description#>
 */

- (void)updateFile:(NSString *)fileNmae withphotoNumber:(NSString *)photoNumber data:(NSData *)data Success:(qiNIuSuccess)success failure:(qiNIuFailure)failure progress:(qiNIuProgress)progress
{
    NSDateFormatter *dateForm = [[NSDateFormatter alloc] init];
    dateForm.dateFormat = @"yyyyMMddHHmmss";
    NSString *currentTimeStr = [dateForm stringFromDate:[NSDate date]];
    
    NSString *customerID = [[QYHAccount shareAccount].loginUser stringByAppendingString:currentTimeStr];
    
    NSString *QiniuBucketName  = [NSString stringWithFormat:@"huaibucket:%@%@",customerID,fileNmae];
    NSString *qiNiukey         = [NSString stringWithFormat:@"%@%@",customerID,fileNmae];
    
    NSString *token = [self tokenWithScope:QiniuBucketName];
    
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    
    NSLog(@"currentTimeStr==%@",currentTimeStr);
    
//    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
//    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
//    NSString *timeString = [NSString stringWithFormat:@"%f",a];
    
//    NSError *error;
//    QNFileRecorder *file = [QNFileRecorder fileRecorderWithFolder:@"保存目录" error:&error];
//    //check error
//    QNUploadManager *upManager1 = [[QNUploadManager alloc] initWithRecorder:file];

    
    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:nil
                                               progressHandler:^(NSString *key, float percent){
                                                   progress(percent);
                                               }
                                                        params:@{ @"x:foo":@"fooval" }
                                                  checkCrc:YES
                                        cancellationSignal:^BOOL{
                                            return NO;
                                        }];
    
  
//    NSLog(@"data==%@,qiNiukey==%@,token==%@",data,qiNiukey,token);

    [upManager putData:data key:qiNiukey token:token
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  if (!info.error) {
        
//                      NSString *contentURL = [NSString stringWithFormat:@"http://%@/%@?_=%@",QiniuBaseURL,key,timeString];
                        NSString *contentURL = [NSString stringWithFormat:@"http://%@/%@",QiniuBaseURL,key];
                      
                      NSLog(@"QN Upload Success URL= %@",contentURL);
                      
                      success(contentURL);
                }
              else {
                  
                  NSLog(@"%@",info.error);
                  
                  failure(info.error);
              }
          } option:opt];

}

/**
 *  获取所有的发表说说的信息
 *
 */
- (void)getAllTrendsByUserArray:(NSArray *)array success:(qiNIuSuccess)success failure:(qiNIuFailure)failure{
    
    NSString *fileName2 = @"trends.json";
    __block NSMutableArray *arrM = [NSMutableArray array];
    
    /**
     *  最多可以请求50数据
     */
    
    __block int i = 0;
    
    for (id obj in array) {
        
        NSLog(@"getAllTrendsgetAllTrends==%d",i);
        
        __block NSString *photoNumber = nil;
        
        if ([obj isKindOfClass:[QYHContactModel class]]) {
            
            QYHContactModel *user = obj;
            photoNumber = user.jid.user;
            
        }
        
        [self getFile:fileName2 withphotoNumber:photoNumber Success:^(id responseObject) {
            [arrM addObject:responseObject];
            //            NSLog(@"获取全部发表说说信息-responseObject==%@",responseObject);
            i++;
            if (i == array.count) {
                success(arrM);
            }
            
        } failure:^(NSError *error) {
            
            NSDictionary *err = error.userInfo;
            
            if (![err[@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]){
                
                failure(error);
            }else{
                i++;
                if (i == array.count) {
                    success(arrM);
                }
            }
            
        }];
    }
}

/**
 *  获取json字典或者字符串
 *
 *  @param fileNmae    <#fileNmae description#>
 *  @param photoNumber <#photoNumber description#>
 *  @param success     <#success description#>
 *  @param failure     <#failure description#>
 */
- (void)getFile:(NSString *)fileNmae withphotoNumber:(NSString *)photoNumber Success:(qiNIuSuccess)success failure:(qiNIuFailure)failure
{
    
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    
    manger.requestSerializer =  [AFHTTPRequestSerializer serializer];
    manger.requestSerializer.timeoutInterval = 15;
    manger.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%f",a];
    
    //    NSUserDefaults *accountPassword = [NSUserDefaults standardUserDefaults];
    NSString *customerID = photoNumber ? photoNumber: [QYHAccount shareAccount].loginUser;
    
    NSString *urlString  = [NSString stringWithFormat:@"http://7xt8p0.com2.z0.glb.qiniucdn.com/%@%@?_=%@",customerID,fileNmae,timeString];
    
    NSLog(@"urlString==%@",urlString);
    
    [manger POST:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSDictionary *dic = [NSDictionary dictionaryWithJsonString:string];
        
        NSLog(@"string==%@,dic==%@",string,dic);
        
        success(dic ? dic : string);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"error==%@",error.userInfo);
        
        //失败走失败的回调
        failure(error);
    }];
    
}

/**
 *  获取NSData
 *
 *  @param fileNmae <#fileNmae description#>
 *  @param success  <#success description#>
 *  @param failure  <#failure description#>
 */
- (void)getDataFromeQiNiuByfile:(NSString *)fileNmae Success:(qiNIuSuccess)success failure:(qiNIuFailure)failure
{
    
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    
    manger.requestSerializer =  [AFHTTPRequestSerializer serializer];
    manger.requestSerializer.timeoutInterval = 15;
    manger.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manger POST:fileNmae parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"error==%@",error.userInfo);
        
        //失败走失败的回调
        failure(error);
    }];
    
}


@end
