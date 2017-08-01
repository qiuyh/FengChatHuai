//
//  QYHCommentCell.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/9/1.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHCommentCell.h"
#import "UIView+SDAutoLayout.h"
#import "QYHContactModel.h"

@interface QYHCommentCell ()<MLEmojiLabelDelegate>

@property (nonatomic,strong) UIButton *fromUserButton;
@property (nonatomic,strong) UIButton *toUserButton;

@property (nonatomic,strong) UITouch *currentTouch;

@property (nonatomic,copy) NSString *cpString;

@end


@implementation QYHCommentCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
         self.commetLabel.sd_layout.topEqualToView(self.contentView).leftEqualToView(self.contentView).bottomEqualToView(self.contentView).rightEqualToView(self.contentView);
        self.fromUserButton.hidden = NO;
        self.toUserButton.hidden = NO;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(copy:)];
        [self.commetLabel addGestureRecognizer:longPress];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}



- (void)confitDataByDic:(NSDictionary *)commentDic{
 
    NSDictionary *contentDic = [commentDic objectForKey:@"content"];
    
    NSString *fromUser = [commentDic objectForKey:@"phone"];
    
    BOOL isAnswer     = [[contentDic objectForKey:@"isAnswer"] boolValue];
    NSString *content = [contentDic objectForKey:@"content"];
    NSString *toUser  = [contentDic objectForKey:@"toUser"];
    
    NSString *fromNickName = [self getNickName:fromUser];
    NSString *toNickName   = [self getNickName:toUser];
    
    NSString *str;
    
    _cpString = content;
    _toUserPhoneNumber = toUser;
    
    if (isAnswer) {
        str = [NSString stringWithFormat:@"%@回复%@：%@",fromNickName,toNickName,content];
    }else{
        str = [NSString stringWithFormat:@"%@：%@",fromNickName,content];
    }
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:str];
    
    __weak typeof(self) weakSelf = self;
    
    [self.commetLabel setText:attString afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:[UIColor colorWithRed:123.0/255 green:154.0/255 blue:194.0/255 alpha:1.0] range:[str rangeOfString:fromNickName]];
        
        [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial-BoldMT" size:15.0f] range:[str rangeOfString:fromNickName]];
        
        [weakSelf.fromUserButton setTitle:fromUser forState:UIControlStateNormal];
        CGSize fromBtnSize = [NSString getContentSize:fromNickName fontOfSize:16.0f maxSizeMake:CGSizeMake(SCREEN_WIDTH - 80, MAXFLOAT)];
        weakSelf.fromUserButton.frame = CGRectMake(0, 0, fromBtnSize.width, fromBtnSize.height);
      
        if (isAnswer) {
            
            NSRange range = [str rangeOfString:[toNickName stringByAppendingString:@"："]];
            range.length-=1;
            
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:[UIColor colorWithRed:123.0/255 green:154.0/255 blue:194.0/255 alpha:1.0] range:range];
            
            [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial-BoldMT" size:15.0f] range:range];
            
            [weakSelf.toUserButton setTitle:fromUser forState:UIControlStateNormal];
            CGSize toBtnSize = [NSString getContentSize:fromNickName fontOfSize:16.0f maxSizeMake:CGSizeMake(SCREEN_WIDTH - 80, MAXFLOAT)];
            weakSelf.toUserButton.frame = CGRectMake( fromBtnSize.width + 30, 0, toBtnSize.width, toBtnSize.height);

        }else{
            weakSelf.toUserButton = nil;
            [weakSelf.toUserButton removeFromSuperview];
        }
        
        return mutableAttributedString;
    }];
    
}

#pragma mark - 获取昵称

- (NSString *)getNickName:(NSString *)phoneNumber{
    QYHContactModel *user = [[QYHChatDataStorage shareInstance].userDic objectForKey:phoneNumber];
    NSString *name = @"我";
    if (user) {
        name =  user.nickname ? [user.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:user.vCard.nickname ? [user.vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]: [user.displayName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return name;
}



-(MLEmojiLabel *)commetLabel{
    if (!_commetLabel) {
        _commetLabel = [MLEmojiLabel new];
        _commetLabel.numberOfLines = 0;
        _commetLabel.font = [UIFont systemFontOfSize:15.0f];
        _commetLabel.backgroundColor = [UIColor clearColor];
        _commetLabel.userInteractionEnabled = YES;
        _commetLabel.delegate = self;
        //下面是自定义表情正则和图像plist的例子
        _commetLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        _commetLabel.customEmojiPlistName = @"expressionImage_custom";
        
        [self.contentView addSubview:_commetLabel];
        
    }
    
    return _commetLabel;
}

-(UIButton *)fromUserButton{
    if (!_fromUserButton) {
        _fromUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fromUserButton.backgroundColor = [UIColor clearColor];
        [_fromUserButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_fromUserButton setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [_fromUserButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
        [_fromUserButton addTarget:self action:@selector(userClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.commetLabel addSubview:_fromUserButton];
    }
    
    return _fromUserButton;
}

-(UIButton *)toUserButton{
    if (!_toUserButton) {
        _toUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _toUserButton.backgroundColor = [UIColor clearColor];
        [_toUserButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_toUserButton setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [_toUserButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
        [_toUserButton addTarget:self action:@selector(userClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.commetLabel addSubview:_toUserButton];
    }
    
    return _toUserButton;
}


- (void)userClick:(UIButton *)button{
    
    button.backgroundColor = [UIColor lightGrayColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        button.backgroundColor = [UIColor clearColor];
    });
    NSLog(@"butt==%@",button.currentTitle);
    
    if ([self.delegate respondsToSelector:@selector(clickNickNameByPhotoNumber:)]) {
        [self.delegate clickNickNameByPhotoNumber:button.currentTitle];
    }
}


#pragma mark - alerViewDelegage
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        if (buttonIndex == 1) {
            if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",alertView.message]]]) {
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",alertView.message]]];
                
            }
        }
}

#pragma mark - MLEmojiLabelDelegate

- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type
{
    switch(type){
        case MLEmojiLabelLinkTypeURL:
            if ([self.delegate respondsToSelector:@selector(openUrl:)]) {
                [self.delegate openUrl:link];
            }
            NSLog(@"点击了链接%@",link);
            break;
        case MLEmojiLabelLinkTypePhoneNumber:
            
            //拨打电话
        {
            NSLog(@"点击了电话%@",link);
            
            UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:nil message:link delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", nil];
            alerView.tag = 101;
            [alerView show];
            
            break;
        }
        case MLEmojiLabelLinkTypeEmail:
            NSLog(@"点击了邮箱%@",link);
            if ([self.delegate respondsToSelector:@selector(showMenuCopy:touch:gesture:)]) {
                [self.delegate showMenuCopy:link touch:_currentTouch gesture:nil];
            }
            break;
        case MLEmojiLabelLinkTypeAt:
            NSLog(@"点击了用户%@",link);
            break;
        case MLEmojiLabelLinkTypePoundSign:
            NSLog(@"点击了话题%@",link);
            break;
        default:
            NSLog(@"点击了不知道啥%@",link);
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    //    NSLog(@"gestureRecognizer==%@,touch==%@",gestureRecognizer,touch.view);
    _currentTouch = touch;
    return YES;
}

- (void)copy:(UILongPressGestureRecognizer *)lonnPress{
    if ([self.delegate respondsToSelector:@selector(showMenuCopy:touch:gesture:)]) {
        
        [self.delegate showMenuCopy:_cpString touch:nil gesture:lonnPress];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
