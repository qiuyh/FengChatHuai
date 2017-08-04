//
//  QYHChatCell.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/27.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHChatCell.h"
#import "UIButton+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "XMPPvCardTemp.h"

@interface QYHChatCell()<AVAudioPlayerDelegate,UIGestureRecognizerDelegate,MLEmojiLabelDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableAttributedString *attrString;
@property (copy, nonatomic) ButtonImageBlock imageBlock;
@property (strong, nonatomic) NSString *imageUrl;


@end


@implementation QYHChatCell


-(void)layoutSubviews{
    
    
    self.chatBgImageView.userInteractionEnabled = YES;
    self.chatTextView.userInteractionEnabled = YES;
    self.mlEmojiLabel.userInteractionEnabled = YES;
    
    /**
     *  显示UIMenuController菜单
     */
    if (self.menuBlock) {
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showMenu:)];
        longPress.delegate = self;
        //        longPress.cancelsTouchesInView = NO;
        //        longPress.minimumPressDuration = 1.0;//(2秒)
        
        if (_messageModel.type == SendText) {
            NSLog(@"mlEmojiLabel");
            [self.mlEmojiLabel addGestureRecognizer:longPress];
        }else{
            [self.contentView addGestureRecognizer:longPress];
        }
        
    }
    
    /**
     *  显示PushDetailVC
     */
    
    if (self.pushBlock) {
//        NSLog(@"pushBlock");
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToDetailVC:)];
        tapGesture.cancelsTouchesInView = NO;
        self.headImageView.userInteractionEnabled = YES;
        [self.headImageView addGestureRecognizer:tapGesture];
        
    }
}

- (void)setMssegeModel:(QYHChatMssegeModel*)messageModel
{
    self.messageModel = messageModel;
}


-(void)setCellValue:(NSString *)str urlString:(NSString *)urlString type:(ContentType)contentType headImage:(UIImage*)headImage imageType:(NSInteger)imageType audioTime:(NSInteger)audioTime
{
    
    if (contentType == HeTextContent || contentType ==HeImageContent || contentType ==HeVoiceContent) {
        
    }else{
        
        switch (self.messageModel.status) {
            case ChatMessageSending:
                [self.activityView setHidden:NO];
                [self.activityView startAnimating];
                [self.sendFailuredImageView setHidden:YES];
                self.voiceImageView.hidden = YES;
                self.voiceTimeLabel.hidden = YES;
                break;
                
            case ChatMessageSendFailure:
                [self.activityView setHidden:YES];
                [self.activityView stopAnimating];
                [self.sendFailuredImageView setHidden:NO];
                self.voiceImageView.hidden = YES;
                self.voiceTimeLabel.hidden = YES;
                break;
                
            case ChatMessageSendSuccess:
                [self.activityView setHidden:YES];
                [self.activityView stopAnimating];
                [self.sendFailuredImageView setHidden:YES];
                self.voiceImageView.hidden = NO;
                self.voiceTimeLabel.hidden = NO;
                break;
                
            default:
                break;
        }
        
    }
    
    
    //设置背景图片
    NSString *imageNamed = contentType == HeTextContent || contentType ==HeImageContent || contentType ==HeVoiceContent ? @"chatfrom_bg_normal.png" : @"chatto_bg_normal.png";
    UIImage *image = [UIImage imageNamed:imageNamed];
    
    
    image = [image resizableImageWithCapInsets:(UIEdgeInsetsMake(image.size.height * 0.6, image.size.width * 0.4, image.size.height * 0.3, image.size.width * 0.4))];
    
    
    self.chatBgImageView.image = image;
    
   
    /**
     *  头像
     */
    
    UIImage *headImage1;
    
    if (contentType == HeTextContent || contentType ==HeImageContent || contentType ==HeVoiceContent ) {
        
//        XMPPJID *myJid = [QYHXMPPTool sharedQYHXMPPTool].xmppStream.myJID;
//        XMPPJID *byJID = [XMPPJID jidWithUser:[self.messageModel.fromUserID isEqualToString:[QYHAccount shareAccount].loginUser]? self.messageModel.toUserID :self.messageModel.fromUserID  domain:myJid.domain resource:myJid.resource];
//        
//        XMPPvCardTemp *vCard =  [[QYHXMPPTool sharedQYHXMPPTool].vCard vCardTempForJID:byJID shouldFetch:YES];
        
        NSString *user = [self.messageModel.fromUserID isEqualToString:[QYHAccount shareAccount].loginUser]? self.messageModel.toUserID :self.messageModel.fromUserID;
        XMPPvCardTemp *vCard = [[QYHXMPPvCardTemp shareInstance] vCard:user];
        
        headImage1 = vCard.photo ? [UIImage imageWithData:vCard.photo] : [UIImage imageNamed:@"placeholder"];;
        
    }else{
//        XMPPvCardTemp *myvCard =  [QYHXMPPTool sharedQYHXMPPTool].vCard.myvCardTemp;
        XMPPvCardTemp *myvCard = [[QYHXMPPvCardTemp shareInstance] vCard:nil];
        headImage1 = myvCard.photo ? [UIImage imageWithData:myvCard.photo] : [UIImage imageNamed:@"placeholder"];
    }
    
    self.headImageView.image = headImage1;
    
  
    switch (contentType) {
        case HeTextContent:
        case MyTextContent:
            [self setTextValue:str type:contentType];
            break;
            
        case HeImageContent:
        case MyImageContent:
            [self setImageValue:urlString type:contentType imageType:imageType];
            break;
            
        case HeVoiceContent:
        case MyVoiceContent:
            [self setVoiceValue:urlString type:contentType audioTime:audioTime];
            break;
            
        default:
            break;
    }
    
}


- (void)showMenu:(UILongPressGestureRecognizer *)longPress{
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        NSLog(@"UILongPressGestureRecognizer");
        
        if (CGRectContainsPoint(self.chatBgImageView.frame,[longPress locationInView:self.contentView])) {
            self.menuBlock(self);
        }
    }
}

- (IBAction)pushToDetailVC:(id)sender
{
    NSLog(@"pushToDetailVC");
     self.pushBlock(self.messageModel.fromUserID);
}
- (void)setTime:(NSString *)msgObj
{
    NSString *timeString = [NSString getMessageDateStringFromdateString:msgObj andNeedTime:YES];
    CGSize rect = [NSString getContentSize:timeString fontOfSize:13 maxSizeMake:CGSizeMake(300, 30)];
    self.timeLabelWithConstraint.constant = rect.width + 10;
    self.timeLabel.text = timeString;

}

- (void)setTextValue:(NSString *)str type:(ContentType)contentType
{
    
//    self.attrString = str;
    
    //由text计算出text的宽高
//    CGRect bound = [self.attrString boundingRectWithSize:CGSizeMake(SCREEN_WIDTH*2.0/3, 1000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine context:nil];
    
//    CGSize bound = [NSString getContentSize:str fontOfSize:15 maxSizeMake:CGSizeMake(SCREEN_WIDTH*2.0/3, 1000)];
    
    self.mlEmojiLabel.text = str;
    
    CGSize bound = [self.mlEmojiLabel preferredSizeWithMaxWidth:SCREEN_WIDTH*2.0/3];
    //根据text的宽高来重新设置新的约束
    //背景的宽

    self.chatBgImageWidthConstraint.constant = bound.width + 40;
    self.chatTextWidthConstaint.constant = bound.width + 20;
    
//    NSDictionary *ats = @{
//                          NSFontAttributeName : [UIFont fontWithName:@"DIN Medium" size:16.0f],
//                          NSParagraphStyleAttributeName : paragraphStyle,
//                          };
//    
//    lab.attributedText = [[NSAttributedString alloc] initWithString:string attributes:ats];//textview 设置行间距
//    self.chatTextView.attributedText = str;

    
    self.mlEmojiLabel.frame = CGRectMake(5, 0, bound.width, bound.height + 20);
    

}


-(MLEmojiLabel *)mlEmojiLabel{
    if (!_mlEmojiLabel) {
        _mlEmojiLabel = [MLEmojiLabel new];
        _mlEmojiLabel.numberOfLines = 0;
//        _mlEmojiLabel.disableThreeCommon = YES;
        _mlEmojiLabel.font = [UIFont systemFontOfSize:15.0f];
        _mlEmojiLabel.backgroundColor = [UIColor clearColor];
        _mlEmojiLabel.userInteractionEnabled = YES;
        _mlEmojiLabel.delegate = self;
//        _mlEmojiLabel.textAlignment = NSTextAlignmentCenter;
        //下面是自定义表情正则和图像plist的例子
        _mlEmojiLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        _mlEmojiLabel.customEmojiPlistName = @"expressionImage_custom";
        
        [self.chatTextView addSubview:_mlEmojiLabel];
        
    }
    
    return _mlEmojiLabel;
}

- (void)setImageValue:(NSString *) imageUrl type:(ContentType)contentType imageType:(NSInteger)imageType
{
    
    switch (imageType)
    {
        case 0:
            self.chatBgImageWidthConstraint.constant  = 140;
            self.imgWidthConstraint.constant  = 140;
            self.buttonWidthConstraint.constant       = 140;
            break;
        case 1:
            self.chatBgImageWidthConstraint.constant  = 110;
            self.imgWidthConstraint.constant  = 110;
            self.buttonWidthConstraint.constant       = 110;
            break;
        default:
           
            break;
    }
    
    //裁剪效果
//    UIImageView *imageView01 = [[UIImageView alloc]init];
//    [imageView01 setFrame:CGRectMake(90, 190, 220, 280)];
//    [imageView01 setImage:[UIImage imageNamed:@"me"]];
//    [self.view addSubview:imageView01];
//    
//    UIImage *bubble = [UIImage imageNamed:@"chatto_bg_normal"];
//    UIImageView *imageView = [[UIImageView alloc]init];
//    [imageView setFrame:imageView01.frame];
//    [imageView setImage:[bubble stretchableImageWithLeftCapWidth:15 topCapHeight:48]];
//    
//    CALayer *layer = imageView.layer;
//    layer.frame = (CGRect){{0.0},imageView.layer.frame.size};
//    imageView01.layer.mask = layer;
//    [imageView01 setNeedsDisplay];
//
    
   
    
    self.imageUrl = imageUrl;
    [_chatBgImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_chatBgImageView setClipsToBounds:YES];

    if (![imageUrl hasPrefix:@"http://"]) {
        
        self.chatBgImageView.image = [UIImage imageWithContentsOfFile:[[QYHChatDataStorage shareInstance].homePath stringByAppendingString:imageUrl]];
    }else{
        
        [self.chatBgImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"x@2x"]];
    }
    
    if (contentType == MyImageContent) {
        self.imgbView.image = [[UIImage imageNamed:@"message_sender_background_reversed"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
    }else{
        self.imgbView.image = [[UIImage imageNamed:@"message_receiver_background_reversed"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
    }
    
//    [self.chatBgImageView setFrame:CGRectMake(90, 190, 220, 280)];
    
//    UIImage *bubble = nil;
//    if (contentType == MyImageContent) {
//        bubble = [UIImage imageNamed:@"chatto_bg_normal"];
//    }else{
//        bubble = [UIImage imageNamed:@"chatfrom_bg_normal"];
//    }
    
//    UIImageView *imageView = [[UIImageView alloc]init];
//    [imageView setFrame:self.chatBgImageView.frame];
//    [self.imgbView setImage:[bubble stretchableImageWithLeftCapWidth:15 topCapHeight:bubble.size.height/2.0]];
//    
//    CALayer *layer = self.imgbView.layer;
//    layer.frame = (CGRect){{0.0},self.imgbView.layer.frame.size};
//    self.chatBgImageView.layer.mask = layer;
//    [self.chatBgImageView setNeedsDisplay];
//    
    
    //    之前的
    //    self.imageButton.imageView.contentMode = UIViewContentModeScaleToFill;
    //    self.imageButton.layer.cornerRadius = 5;
    //    self.imageButton.clipsToBounds = YES;
    //    self.imageUrl = imageUrl;
    //
    //    if (![imageUrl hasPrefix:@"http://"]) {
    //        [self.imageButton setBackgroundImage:[UIImage imageWithContentsOfFile:imageUrl] forState:UIControlStateNormal];
    //    }else{
    //        [self.imageButton setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:imageUrl]];
    //    }
}

- (void)setVoiceValue:(NSString *)playUrlString type:(ContentType)contentType audioTime:(NSInteger)audioTime
{
    
    CGFloat with = 90.0f + audioTime*2;
    
    with = with > SCREEN_WIDTH - 100 ? SCREEN_WIDTH - 100 : with;
    
    self.chatBgImageWidthConstraint.constant  = with;
    self.buttonWidthConstraint.constant       = with;
    
    self.voiceTimeLabel.text = [NSString stringWithFormat:@"%ld''",audioTime];
    
    if (contentType == HeVoiceContent) {
        self.redTipUIImageView.hidden = self.messageModel.isReadVioce;
    }
    
    self.playTime = audioTime;
    
    NSLog(@"playUrlString==%@",playUrlString);
    
    if (![playUrlString hasPrefix:@"http://"]) {
        
         self.playURL = playUrlString;
        
    }else{
        
        self.playURL = playUrlString;
    }

}

-(void)setButtonImageBlock:(ButtonImageBlock)block
{
    self.imageBlock = block;
}

- (IBAction)tapImageButton:(id)sender {
    self.imageBlock(self.imageUrl);
}

- (void)playAudioByPlayUrl:(NSString *)urlString
{
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    //网络请求声音
    NSData *data = nil;
    
    NSLog(@"urlString==%@",urlString);
    if (![urlString hasPrefix:@"http://"]) {
        
        data = [NSData dataWithContentsOfFile:[[QYHChatDataStorage shareInstance].homePath stringByAppendingString:urlString]];
        
    }else{
        
        data  = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
    }
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithData:data error:&error];
    player.volume  = 1.0;
    if (error) {
        NSLog(@"播放错误：%@",[error description]);
    }
    self.audioPlayer = player;
    self.audioPlayer.meteringEnabled = YES;
    self.audioPlayer.delegate = self;
    
    [self handleNotification:YES];
    
    [self.audioPlayer play];
    NSLog(@"%@", urlString);
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"播放结束");
    
//    getDataFromeQiNiuByfile
    
    [self handleNotification:NO];
   
}

#pragma mark - 监听听筒or扬声器
- (void) handleNotification:(BOOL)state
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:state]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    if(state)//添加监听
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification"
                                                   object:nil];
    }
    else//移除监听
    { [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    }
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.activityView setHidesWhenStopped:YES];
    [self.activityView setHidden:YES];

    [self.sendFailuredImageView setImage:[UIImage imageNamed:@"dd_send_failed"]];
    [self.sendFailuredImageView setHidden:YES];
    self.sendFailuredImageView.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *pan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTheSendAgain)];
    [self.sendFailuredImageView addGestureRecognizer:pan];
    
    // Initialization code
}

-(void)setSendAgainBlock:(ClickTheSendAgainBlock)block
{
    self.sendAgain = block;
}


-(void)clickTheSendAgain
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"重发" message:@"是否重新发送此消息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 100;
    [alert show];
    
}

#pragma mark - alerViewDelegage
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            
            self.sendAgain(self.messageModel);
        }
    }else{
        if (buttonIndex == 1) {
            
            if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",alertView.message]]]) {
                
                if (kSystemVersion >= 10.0) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",alertView.message]] options:@{} completionHandler:nil];
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",alertView.message]]];
                }
                
            }
        }
    }
    
}


#pragma mark - MLEmojiLabelDelegate

- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type
{
    switch(type){
        case MLEmojiLabelLinkTypeURL:
            if ([self.delagete respondsToSelector:@selector(pushToWebViewControllerByUrl:)]) {
                [self.delagete pushToWebViewControllerByUrl:link];
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
