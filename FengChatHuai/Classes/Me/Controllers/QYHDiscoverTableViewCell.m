//
//  QYHDiscoverTableViewCell.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/15.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHDiscoverTableViewCell.h"
#import "QYHContactModel.h"
#import "UIImageView+WebCache.h"
#import "UIView+SDAutoLayout.h"
#import "QYHCommentCell.h"
#import "QYHDiscoverViewController.h"

@interface QYHDiscoverTableViewCell ()<UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,QYHCommentCellDelegate>

@property (nonatomic,strong) UIView *supportbgView;
@property (nonatomic,strong) UIButton *lastSupportNameButton;
@property (nonatomic,strong) NSMutableArray *nickNameArrM;
@property (nonatomic,strong) NSMutableArray *phoneArrM;
@property (nonatomic,strong) UITextView *supportTextView;

@property (nonatomic,strong) NSMutableArray *commetNickNameArrM;
@property (nonatomic,strong) NSMutableDictionary *commetPhoneDic;
@property (nonatomic,strong) UITextView *commetTextView;
@property (nonatomic,strong) UIView *lineView;

@property (nonatomic,strong) UITableView *commentTableView;
@property (nonatomic,strong) NSMutableArray *commetArray;

@property (nonatomic,strong) NSArray *commetHightArray;

@property (nonatomic,assign) BOOL isShow;//键盘弹起或者赞View出现时，再点击cell时要隐藏

@property (nonatomic,assign) BOOL isOpening;//是否点击全文查看

@end

@implementation QYHDiscoverTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickHeadImage:)];
    self.headImageView.userInteractionEnabled = YES;
    [self.headImageView addGestureRecognizer:tap];
    
    self.operationMenu.hidden = NO;
    
//    self.allBtnHeightConstraint.constant = 0.0f;
//    self.allTextButton.hidden = YES;
    
}

#pragma mark - 展示数据

- (void)confitDataByDic:(NSDictionary *)dic height:(QYHDiscoverHeight *)heightModel detail:(BOOL)isDetail{
     //photoNumber,time,content,imagesUrl
    
    NSString *photoNumber = [dic objectForKey:@"photoNumber"];
    NSString *time        = [dic objectForKey:@"time"];
    NSString *content     = [dic objectForKey:@"content"];
    NSArray  *commentArray ;
    NSArray  *imagesUrl;
    if ([[dic objectForKey:@"comment"] isKindOfClass:[NSArray class]]) {
        commentArray   = [dic objectForKey:@"comment"];
    }

    if ([[dic objectForKey:@"imagesUrl"] isKindOfClass:[NSArray class]]) {
        imagesUrl   = [dic objectForKey:@"imagesUrl"];
    }
    
    
    [self initCommetView:commentArray height:heightModel];
    [self initImageView:imagesUrl height:heightModel];

    
    _photoNumber = photoNumber;
    _time        = time;
    _photosUrl   = imagesUrl;
    
    XMPPvCardTemp *vCard = [[QYHXMPPvCardTemp shareInstance] vCard:photoNumber];
    NSData   *imageData = vCard.photo ?vCard.photo:UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0);
    
    self.headImageView.image = [UIImage imageWithData:imageData];
    self.contentLabel.text   = content;
    self.timeLabel.text = [NSString getMessageDateStringFromdateString:time andNeedTime:YES];
    [self.nameButton setTitle:[self getNickName:photoNumber] forState:UIControlStateNormal];
    
    if (heightModel.contentLabelHeight>65) {
        if (heightModel.isOpening) {
            self.allTextButton.selected = YES;
            self.contentLabelHeightConstraint.constant = heightModel.contentLabelHeight;
        }else{
            self.allTextButton.selected = NO;
            self.contentLabelHeightConstraint.constant = 65.0f;
        }
        self.allTextButton.hidden = NO;
        self.allBtnHeightConstraint.constant = 25.0f;
        
        if (isDetail) {
            self.allTextButton.hidden = YES;
            self.allBtnHeightConstraint.constant = 0.0f;
            self.contentLabelHeightConstraint.constant = heightModel.contentLabelHeight;
        }
       
    }else{
        self.allTextButton.hidden = YES;
        self.allBtnHeightConstraint.constant = 0.0f;
        self.contentLabelHeightConstraint.constant = heightModel.contentLabelHeight;
    }
    self.photosViewHeightConstraint.constant   = heightModel.photosViewHeight;
    self.commentViewHeightConstraint.constant  = heightModel.commentViewHeight;
    self.nameButtonWithConstraint.constant     = heightModel.nameButtonWith;
    
//    [UIView animateWithDuration:0.05 animations:^{
//        [self layoutIfNeeded];
//        [self.contentLabel layoutIfNeeded];
//        [self.photosView layoutIfNeeded];
//        [self.commentView layoutIfNeeded];
//    }];
    
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

/**
 *  初始化照片
 *
 */
#pragma mark - 初始化照片
- (void)initImageView:(NSArray *)imagesUrl height:(QYHDiscoverHeight *)heightModel{
    
    
    [self.photosView removeAllSubviews];
    
    if (imagesUrl&&!self.photosView.subviews.count) {
        for (int i = 0; i<imagesUrl.count; i++) {
            
            __block UIImageView *imageView;
            
            if (imagesUrl.count == 1) {
                imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, heightModel.oneImageWith, heightModel.oneImageHeight)];
            }else if (imagesUrl.count == 4) {
                imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5+(80+5)*(i%2), 0+(80+5)*(i/2), 80, 80)];
                
            }else{
                imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5+(80+5)*(i%3), 0+(80+5)*(i/3), 80, 80)];
            }
            
            imageView.clipsToBounds = YES;
            imageView.contentMode   = UIViewContentModeScaleAspectFill;
            
            NSString *smallSize = @"?imageView2/1/w/150/h/150";
            if (imagesUrl.count == 1) {
                smallSize = [NSString stringWithFormat:@"?imageView2/1/w/%d/h/%d",(int)(heightModel.oneImageWith*1.5),(int)(heightModel.oneImageHeight*1.5)];
            }
            NSURL *url = [NSURL URLWithString:[imagesUrl[i] stringByAppendingString:smallSize]];
            [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
            
            imageView.tag = 100+i;
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(displayImages:)];
            [imageView addGestureRecognizer:tap];
            
            [self.photosView addSubview:imageView];
        }
    }
}

/**
 *  初始化赞、评论的View
 *
 */
#pragma mark - 初始化赞、评论的View
- (void)initCommetView:(NSArray *)commentArray height:(QYHDiscoverHeight *)heightModel{
   
    NSLog(@"commentArray== %@",commentArray);
    
    /**
     *  赞的数量
     */
    int supportCount = 0;
    int index = 0;
    
    [self.nickNameArrM removeAllObjects];
    [self.phoneArrM removeAllObjects];
    
    [self.commetArray removeAllObjects];
    [self.commetNickNameArrM removeAllObjects];
    [self.commetPhoneDic removeAllObjects];

    for (NSDictionary *commentDic in commentArray) {
        index++;
        
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
            
            [self getSupportArrays:fromUser isSupport:isSupport supportCount:supportCount isLastObject:commentArray.count == index ? YES:NO];
        }
    }

    /**
     *  赞👍
     */
    _isLink = NO;
    self.supportTextView = nil;
    [self.supportbgView removeAllSubviews];
    [self.supportbgView removeFromSuperview];
    
    if (self.nickNameArrM.count) {
        [self addSupportView:heightModel];
    }else{
       
    }
    
    
    /**
     *  评论
     *
     */
    
    [self.commentTableView removeFromSuperview];
    self.commentTableView = nil;
    [self.lineView removeFromSuperview];
    self.lineView = nil;
    
    if (self.commetArray.count) {
        
        self.commetHightArray = heightModel.commentHeightArray;
        
        __block CGFloat commentHeight = 0.0f;
        
        [heightModel.commentHeightArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            commentHeight += [heightModel.commentHeightArray[idx] floatValue];
            commentHeight +=5;
        }];
        
        CGFloat y = self.nickNameArrM.count ? heightModel.supportSize.height+5:heightModel.supportSize.height+10;
        self.commentTableView.frame = CGRectMake(8, y , SCREEN_WIDTH - 80, commentHeight);
        
        if (self.supportbgView.frame.size.height>1) {
            self.lineView.frame = CGRectMake(0, heightModel.supportSize.height-1, SCREEN_WIDTH - 64, 0.5);
        }
    }
  
}

- (void)getSupportArrays:(NSString *)fromUser isSupport:(BOOL)isSupport supportCount:(int)supportCount isLastObject:(BOOL)isLastObject{
    
    NSString *nickName = [self getNickName:fromUser];
    if (isSupport)
    {
        supportCount++;
        [self.nickNameArrM addObject:nickName];
        [self.phoneArrM addObject:fromUser];
        
    }else{
        supportCount--;
        [self.nickNameArrM removeObject:nickName];
        [self.phoneArrM removeObject:fromUser];
        
        if (supportCount>0) {
            
        }else{
            /**
             *  没有赞就清楚背景的View
             */
            
            if (isLastObject) {
                self.supportTextView = nil;
                [self.supportbgView removeAllSubviews];
                [self.supportbgView removeFromSuperview];
            }
        }
    }
}



/**
 *  添加赞的人名
 */
#pragma mark - 添加赞的人名
- (void)addSupportView:(QYHDiscoverHeight *)heightModel{
    
     NSMutableString *strM = [NSMutableString new];
    
    for (int i = 0; i< self.nickNameArrM.count; i++) {
        if (i==0) {
            [strM appendString:[NSString stringWithFormat:@"      %@",self.nickNameArrM[i]]];
        }else{
            [strM appendString:[@"，" stringByAppendingString:self.nickNameArrM[i]]];
        }
        
        /**
         *  我是否赞了
         */
        if ([self.phoneArrM[i] isEqualToString:[QYHAccount shareAccount].loginUser]) {
            _isLink = YES;
        }
    }
    
//    NSLog(@"strM==%@,,%ld",strM,self.nickNameArrM.count);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:strM];
    
    for (int i = 0; i< self.nickNameArrM.count; i++) {
     [attributedString addAttribute:NSLinkAttributeName value:[NSURL URLWithString:[self.phoneArrM[i] stringByAppendingString:@"://"]] range:[[attributedString string] rangeOfString:self.nickNameArrM[i]]];
    }
    
    [attributedString addAttribute:NSFontAttributeName
     
                          value:[UIFont fontWithName:@"Arial-BoldMT" size:15.0f]
     
                          range:NSMakeRange(0, attributedString.string.length)];

    self.supportTextView.attributedText = attributedString;
    
    self.supportTextView.frame = CGRectMake(0, 0,  heightModel.supportSize.width, heightModel.supportSize.height);
    self.supportbgView.frame   = CGRectMake(0, 3, SCREEN_WIDTH-64, heightModel.supportSize.height);
}


#pragma mark - textViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSLog(@"%@",[URL scheme]);
    if ([[URL scheme] containsString:@"username"]) {
        NSLog(@"点中了。。。。。。。。");
    }
    
    if ([self.delegate respondsToSelector:@selector(clickHeadImageByPhotoNumber:)]) {
        [self.delegate clickHeadImageByPhotoNumber:[URL scheme]];
    }

    return YES;
}

#pragma mark - 懒加载

-(UITextView *)supportTextView{
    if (!_supportTextView) {
        _supportTextView = [[UITextView alloc]init];
        _supportTextView.backgroundColor = [UIColor clearColor];
        _supportTextView.showsVerticalScrollIndicator = NO;
        _supportTextView.showsHorizontalScrollIndicator = NO;
        _supportTextView.scrollEnabled = NO;
        _supportTextView.editable = NO;
        //    设置点击时的样式
        NSDictionary *linkAttributes =@{NSForegroundColorAttributeName: [UIColor colorWithRed:123.0/255 green:154.0/255 blue:194.0/255 alpha:1.0],NSUnderlineColorAttributeName: [UIColor lightGrayColor],NSUnderlineStyleAttributeName:@(NSUnderlinePatternSolid)};
        
        //    添加链接文字
        _supportTextView.linkTextAttributes = linkAttributes;
        /** 设置自动检测类型为链接网址. */
        _supportTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        _supportTextView.delegate = self;
        
        UIImageView *supportIconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 10, 15, 15)];
        supportIconImageView.image = [UIImage imageNamed:@"Like"];
        
        [self.supportbgView addSubview:_supportTextView];
        [self.supportbgView addSubview:supportIconImageView];
        [self.commentView addSubview:self.supportbgView];
    }
    
    return _supportTextView;
}

-(UIView *)supportbgView{
    if (!_supportbgView) {
        _supportbgView = [[UIView alloc]init];
//        _supportbgView.backgroundColor = [UIColor redColor];
        //        _supportbgView.frame = CGRectMake(0, 10, self.commentView.frame.size.width, 20);
    }
    
    return _supportbgView;
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

-(NSMutableArray *)commetNickNameArrM{
    if (!_commetNickNameArrM) {
        _commetNickNameArrM = [NSMutableArray array];
    }
    return _commetNickNameArrM;
}

-(NSMutableDictionary *)commetPhoneDic{
    if (!_commetPhoneDic) {
        _commetPhoneDic = [NSMutableDictionary dictionary];
    }
    return _commetPhoneDic;
}

-(UITextView *)commetTextView{
    if (!_commetTextView) {
        _commetTextView = [[UITextView alloc]init];
        _commetTextView.backgroundColor = [UIColor clearColor];
        _commetTextView.showsVerticalScrollIndicator = NO;
        _commetTextView.showsHorizontalScrollIndicator = NO;
        _commetTextView.scrollEnabled = NO;
        _commetTextView.editable = NO;
        //    设置点击时的样式
        NSDictionary *linkAttributes =@{NSForegroundColorAttributeName: [UIColor colorWithRed:123.0/255 green:154.0/255 blue:194.0/255 alpha:1.0],NSUnderlineColorAttributeName: [UIColor lightGrayColor],NSUnderlineStyleAttributeName:@(NSUnderlinePatternSolid)};
        
        //    添加链接文字
        _commetTextView.linkTextAttributes = linkAttributes;
        /** 设置自动检测类型为链接网址. */
        _commetTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        _commetTextView.delegate = self;
        
//        [self.commentView addSubview:_commetTextView];
    }
    
    return _commetTextView;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = [UIColor colorWithHexString:kDefaultLineGray1Color];
        
        [self.commentView addSubview:_lineView];
    }
    
    return _lineView;
}

-(NSMutableArray *)commetArray{
    if (!_commetArray) {
        _commetArray = [NSMutableArray array];
    }
    
    return _commetArray;
}

-(UITableView *)commentTableView{
    if (!_commentTableView) {
        _commentTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, 260, 204) style:UITableViewStylePlain];
        _commentTableView.backgroundColor = [UIColor clearColor];
        _commentTableView.scrollEnabled = NO;
        _commentTableView.showsVerticalScrollIndicator = NO;
        _commentTableView.showsVerticalScrollIndicator = NO;
//        _commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _commentTableView.delegate = self;
        _commentTableView.dataSource = self;
        _commentTableView.tableFooterView = [[UIView alloc]init];
        
        [self.commentView addSubview:_commentTableView];
    }
    
    return _commentTableView;
}

#pragma mark - 初始化评论、赞的View

-(QYHOperationMenuView *)operationMenu{
    if (!_operationMenu) {
        _operationMenu = [QYHOperationMenuView new];
        __weak typeof(self) weakSelf = self;
        [_operationMenu setLikeButtonClickedOperation:^(BOOL isLink){
            
            _isLink = isLink;
            if ([weakSelf.delegate respondsToSelector:@selector(commentActionByPhotoNumber:time:type:isLink:)]) {
                [weakSelf.delegate commentActionByPhotoNumber:weakSelf.photoNumber time:weakSelf.time type:LikeButtonClickedOperation isLink:isLink];
            }
            
        }];
        [_operationMenu setCommentButtonClickedOperation:^{
            if ([weakSelf.delegate respondsToSelector:@selector(commentActionByPhotoNumber:time:type:isLink:)]) {
                [weakSelf.delegate commentActionByPhotoNumber:weakSelf.photoNumber time:weakSelf.time type:CommentButtonClickedOperation isLink:NO];
            }
        }];
        
        [self.contentView addSubview:_operationMenu];
        
        _operationMenu.sd_layout
        .rightSpaceToView(self.commentButton, 0)
        .heightIs(36)
        .centerYEqualToView(self.commentButton)
        .widthIs(0);
    }
    
    return _operationMenu;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - 点击姓名进入个人信息页面

//点击头像进入个人信息页面
- (void)clickHeadImage:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(clickHeadImageByPhotoNumber:)]) {
        [self.delegate clickHeadImageByPhotoNumber:_photoNumber];
    }
    
}

//点击姓名进入个人信息页面
- (IBAction)pushPersonDetailVC:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickHeadImageByPhotoNumber:)]) {
        [self.delegate clickHeadImageByPhotoNumber:_photoNumber];
    }
}

//点击全文
- (IBAction)lookAllTextBtn:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
         _isOpening = YES;
    }else{
         _isOpening = NO;
    }
    
    QYHDiscoverTableViewCell *cell = (QYHDiscoverTableViewCell *)[[sender superview] superview];
    
    if ([self.delegate respondsToSelector:@selector(clickAllTextButton:indexCell:)]) {
        
        [self.delegate clickAllTextButton:_isOpening indexCell:cell];
    }
}

#pragma mark - 赞和评论按钮
- (IBAction)commentBtn:(id)sender {
    
    if (!_operationMenu.show) {
        
        QYHDiscoverTableViewCell *cell = (QYHDiscoverTableViewCell *)[[sender superview] superview];
        
        if ([self.delegate respondsToSelector:@selector(setCommentIndexCell:)]) {
            [self.delegate setCommentIndexCell:cell];
        }
        
        _operationMenu.isLink = _isLink;
    }
    
    if ([self.delegate respondsToSelector:@selector(dismissOperationView:)]) {
        [self.delegate dismissOperationView:self];
    }
    
     _operationMenu.show  = !_operationMenu.isShowing;
    
}

#pragma mark - 显示图片
- (void)displayImages:(UITapGestureRecognizer *)tap{
    UIImageView *imgView = (UIImageView *)tap.view;
    _index = imgView.tag - 100;
//    NSLog(@"_photosUrl==%@",_photosUrl);
    if ([self.delegate respondsToSelector:@selector(displayImagesByArrays:index:)]) {
        [self.delegate displayImagesByArrays:_photosUrl index:_index];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    QYHDiscoverViewController *suprView = (QYHDiscoverViewController *)self.delegate;
    
    if (self.operationMenu.show||suprView.isShowKeyBoard) {
        _isShow = YES;
    }else{
        _isShow = NO;
    }

//    NSLog(@"gestureRecognizer==%@,touch==%@",gestureRecognizer,touch.view);
    return YES;
}

#pragma mark- QYHCommentCellDelegate

- (void)clickNickNameByPhotoNumber:(NSString *)photoNumber{
    if ([self.delegate respondsToSelector:@selector(clickHeadImageByPhotoNumber:)]) {
        [self.delegate clickHeadImageByPhotoNumber:photoNumber];
    }
}

-(void)openUrl:(NSString *)urlString{
    if ([self.delegate respondsToSelector:@selector(gotoWebViewByUrlString:)]) {
        [self.delegate gotoWebViewByUrlString:urlString];
    }
}

- (void)showMenuCopy:(NSString *)copyString touch:(UITouch *)touch gesture:(UIGestureRecognizer *)gesture{
    if ([self.delegate respondsToSelector:@selector(showMenuCopy:touch:gesture:)]) {
        [self.delegate showMenuCopy:copyString touch:touch gesture:gesture];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.commetArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"commentCell";
    QYHCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[QYHCommentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
 
    [cell confitDataByDic:self.commetArray[indexPath.section]];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!_isShow) {
        
        QYHCommentCell *cell =[tableView cellForRowAtIndexPath:indexPath];
        
        if ([self.delegate respondsToSelector:@selector(answerCommentByToUser:phoneNumber:time:indexCell:)]) {
            [self.delegate answerCommentByToUser:cell.toUserPhoneNumber phoneNumber:_photoNumber time:_time indexCell:self];
        }
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section<self.commetHightArray.count) {
        return [self.commetHightArray[indexPath.section] floatValue];
    }
    return 0;
}

@end
