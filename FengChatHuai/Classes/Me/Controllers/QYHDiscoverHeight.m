//
//  QYHDiscoverHeight.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/22.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHDiscoverHeight.h"
#import "QYHContactModel.h"
#import "MLEmojiLabel.h"

@interface QYHDiscoverHeight ()

@property (nonatomic,strong) NSMutableArray *nickNameArrM;
@property (nonatomic,strong) NSMutableArray *phoneArrM;
@property (nonatomic,strong) NSMutableArray *commetArray;

@property (strong, nonatomic)  MLEmojiLabel *commetLabel;

@end

@implementation QYHDiscoverHeight

-(void)setCellHeightByDic:(NSDictionary *)dic{
    
    NSString *photoNumber = [dic objectForKey:@"photoNumber"];
    NSString *content     = [dic objectForKey:@"content"];
    NSArray  *commentArray ;
    NSArray  *imagesUrl;
    if ([[dic objectForKey:@"comment"] isKindOfClass:[NSArray class]]) {
        commentArray   = [dic objectForKey:@"comment"];
    }

    if ([[dic objectForKey:@"imagesUrl"] isKindOfClass:[NSArray class]]) {
        imagesUrl   = [dic objectForKey:@"imagesUrl"];
    }
   
    [self initCommetView:commentArray];
    
    NSString *name = [self getNickName:photoNumber];
    
    CGFloat contentLabelHeight = [NSString getContentSize:content fontOfSize:15 maxSizeMake:CGSizeMake(SCREEN_WIDTH - 64, 1000000)].height + 10;
    CGFloat nameButtonWith = [NSString getContentSize:name fontOfSize:17 maxSizeMake:CGSizeMake(SCREEN_WIDTH - 64, 19)].width + 10;
    
    if (imagesUrl) {
        if (imagesUrl.count == 1) {
            CGFloat with   = [[dic objectForKey:@"imageWith"] floatValue];
            CGFloat height = [[dic objectForKey:@"imageHeight"] floatValue];
            
            if (with>SCREEN_WIDTH-100) {
                
                height = (height*1.0/with) * (SCREEN_WIDTH-100);
                with = SCREEN_WIDTH-100;
                
            }else if (height > 300) {
                with = (with*1.0/height)*300;
                height = 300;
            }
            
            self.oneImageWith = with;
            self.oneImageHeight = height;
            self.photosViewHeight = height+10;
            
        }else{
            
            self.photosViewHeight = 80+(80+5)*((imagesUrl.count-1)/3)+10;
        }
    }
    
    __block CGFloat commentHeight = 0.0f;
    
    [self.commentHeightArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        commentHeight += [self.commentHeightArray[idx] floatValue];
        commentHeight +=5;
    }];
    
    
    if (self.supportSize.height<1&&commentHeight<1) {
        self.commentViewHeight  = 0;
    }else{
        self.commentViewHeight  = self.supportSize.height > 0 ? (self.supportSize.height + commentHeight+5):(commentHeight+8);
        if (commentHeight<1) {
            self.commentViewHeight  = self.supportSize.height;
        }
    }
    
    self.contentLabelHeight = contentLabelHeight;
    self.nameButtonWith     = nameButtonWith;
    self.cellHeight         = 20+60+self.photosViewHeight+ self.contentLabelHeight+self.commentViewHeight;
}



- (void)initCommetView:(NSArray *)commentArray{
    
    [self.nickNameArrM removeAllObjects];
    [self.phoneArrM removeAllObjects];
    
    for (NSDictionary *commentDic in commentArray) {
        
        NSDictionary *contentDic;
        if ([[commentDic objectForKey:@"content"] isKindOfClass:[NSDictionary class]]) {
            contentDic  = [commentDic objectForKey:@"content"];
        }

        NSString *fromUser = [commentDic objectForKey:@"phone"];
        BOOL isSupport = [[commentDic objectForKey:@"support"] boolValue];
        BOOL isComment = [[commentDic objectForKey:@"isComment"] boolValue];
        
        if (isComment)
        {
            /**
             *  评论
             */
            if (contentDic) {
                [self.commetArray addObject:commentDic];
            }

        }else{
            /**
             *  赞
             */
            
            NSString *nickName = [self getNickName:fromUser];
            
            if (isSupport)
            {
                [self.nickNameArrM addObject:nickName];
                [self.phoneArrM addObject:fromUser];
                
            }else{
                [self.nickNameArrM removeObject:nickName];
                [self.phoneArrM removeObject:fromUser];
            }
            
        }
    }
    
    [self addSupportView];
    [self getCommentHeight];
    
}
/**
 *  添加赞的人名
 */
- (void)addSupportView{
    
    NSMutableString *strM = [NSMutableString new];
    
    for (int i = 0; i< self.nickNameArrM.count; i++) {
        if (i==0) {
            [strM appendString:[NSString stringWithFormat:@"      %@",self.nickNameArrM[i]]];
        }else{
            [strM appendString:[@"，" stringByAppendingString:self.nickNameArrM[i]]];
        }
    }
    
    CGSize size = [NSString getContentSize:strM fontOfSize:15.0f maxSizeMake:CGSizeMake(SCREEN_WIDTH - 64, MAXFLOAT)];
    
    if (size.width > 1) {
        size.height+=15;
        size.width+=12;
    }else{
        size.height = 0;
    }

    self.supportSize = size;
}

- (void)getCommentHeight{
    
    [self.commetArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *commentDic = self.commetArray[idx];
        NSDictionary *contentDic = [commentDic objectForKey:@"content"];
        
        NSString *fromUser = [commentDic objectForKey:@"phone"];
        
        BOOL isAnswer     = [[contentDic objectForKey:@"isAnswer"] boolValue];
        NSString *content = [contentDic objectForKey:@"content"];
        NSString *toUser  = [contentDic objectForKey:@"toUser"];
        
        NSString *fromNickName = [self getNickName:fromUser];
        NSString *toNickName   = [self getNickName:toUser];
        
        NSString *str;
        
        if (isAnswer) {
            str = [NSString stringWithFormat:@"%@回复%@：%@",fromNickName,toNickName,content];
        }else{
            str = [NSString stringWithFormat:@"%@：%@",fromNickName,content];
        }
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:str];
        
        [self.commetLabel setText:attString afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:[UIColor colorWithRed:123.0/255 green:154.0/255 blue:194.0/255 alpha:1.0] range:[str rangeOfString:fromNickName]];
            
            [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial-BoldMT" size:15.0f] range:[str rangeOfString:fromNickName]];
            
            if (isAnswer) {
                [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:[UIColor colorWithRed:123.0/255 green:154.0/255 blue:194.0/255 alpha:1.0] range:[str rangeOfString:toNickName]];
                
                [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial-BoldMT" size:15.0f] range:[str rangeOfString:toNickName]];
                
            }
            
            return mutableAttributedString;
        }];
        
        CGSize size = [self.commetLabel preferredSizeWithMaxWidth:SCREEN_WIDTH - 80];
        
        [self.commentHeightArray addObject:@(size.height)];

    }];
    
}

/**
 *  获取昵称
 */
- (NSString *)getNickName:(NSString *)phoneNumber{
    QYHContactModel *user = [[QYHChatDataStorage shareInstance].userDic objectForKey:phoneNumber];
    NSString *name = @"我";
    if (user) {
        name =  user.nickname ? [user.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:user.vCard.nickname ? [user.vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]: [user.displayName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return name;
}

-(NSMutableArray *)nickNameArrM{
    if (!_nickNameArrM) {
        _nickNameArrM = [NSMutableArray array];
    }
    return _nickNameArrM;
}

-(NSMutableArray *)phoneArrM{
    if (!_phoneArrM) {
        _phoneArrM = [NSMutableArray array];
    }
    return _phoneArrM;
}

-(NSMutableArray *)commetArray{
    if (!_commetArray) {
        _commetArray = [NSMutableArray array];
    }
    
    return _commetArray;
}


-(NSMutableArray *)commentHeightArray{
    if (!_commentHeightArray) {
        _commentHeightArray = [NSMutableArray array];
    }
    
    return _commentHeightArray;
}


-(MLEmojiLabel *)commetLabel{
    if (!_commetLabel) {
        _commetLabel = [MLEmojiLabel new];
        _commetLabel.numberOfLines = 0;
        _commetLabel.font = [UIFont systemFontOfSize:15.0f];
        _commetLabel.backgroundColor = [UIColor clearColor];
        //下面是自定义表情正则和图像plist的例子
        _commetLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        _commetLabel.customEmojiPlistName = @"expressionImage_custom";
        
    }
    
    return _commetLabel;
}



@end
