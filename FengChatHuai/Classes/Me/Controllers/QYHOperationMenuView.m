//
//  QYHOperationMenuView.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/23.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHOperationMenuView.h"
#import "UIView+SDAutoLayout.h"


@implementation QYHOperationMenuView
{
    UIButton *_likeButton;
    UIButton *_commentButton;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 5;
    self.backgroundColor = [UIColor colorWithRed:69/255.0 green:74/255.0 blue:76/255.0 alpha:1.0];
    
    _likeButton = [self creatButtonWithTitle:@"赞" image:[UIImage imageNamed:@"AlbumLike"] selImage:[UIImage imageNamed:@"Like"] target:self selector:@selector(likeButtonClicked)];
    _commentButton = [self creatButtonWithTitle:@"评论" image:[UIImage imageNamed:@"AlbumComment"] selImage:[UIImage imageNamed:@"AlbumComment"] target:self selector:@selector(commentButtonClicked)];
    
    UIView *centerLine = [UIView new];
    centerLine.backgroundColor = [UIColor grayColor];
    
    
    [self sd_addSubviews:@[_likeButton, _commentButton, centerLine]];
    
    CGFloat margin = 5;
    
    _likeButton.sd_layout
    .leftSpaceToView(self, margin)
    .topEqualToView(self)
    .bottomEqualToView(self)
    .widthIs(80);
    
    centerLine.sd_layout
    .leftSpaceToView(_likeButton, margin)
    .topSpaceToView(self, margin)
    .bottomSpaceToView(self, margin)
    .widthIs(1);
    
    _commentButton.sd_layout
    .leftSpaceToView(centerLine, margin)
    .topEqualToView(_likeButton)
    .bottomEqualToView(_likeButton)
    .widthRatioToView(_likeButton, 1);
    
}

- (UIButton *)creatButtonWithTitle:(NSString *)title image:(UIImage *)image selImage:(UIImage *)selImage target:(id)target selector:(SEL)sel
{
    UIButton *btn = [UIButton new];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:selImage forState:UIControlStateSelected];
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    return btn;
}

- (void)likeButtonClicked
{
     _isLink = !_isLink;
    
    if (self.likeButtonClickedOperation) {
        self.likeButtonClickedOperation(_isLink);
    }
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:_likeButton.imageView.bounds];
    imageView.image = [UIImage imageNamed:@"Like"];
    _likeButton.imageView.clipsToBounds = NO;
    [_likeButton.imageView addSubview:imageView];
    
    [self startShake:imageView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_isLink) {
            [_likeButton setTitle:@"取消" forState:UIControlStateNormal];
        }else{
            [_likeButton setTitle:@"赞" forState:UIControlStateNormal];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.show = NO;
        [self stopShake:imageView];
    });
    
}

//抖动动画
- (void)startShake:(UIImageView *)imageView
{
    // 设定为缩放
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    // 动画选项设定
    animation.duration = 0.2f; // 动画持续时间
    animation.repeatCount = MAXFLOAT; // 重复次数
    animation.autoreverses = YES; // 动画结束时执行逆动画
    
    // 缩放倍数
    animation.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
    animation.toValue   = [NSNumber numberWithFloat:2.0]; // 结束时的倍率
    
    // 添加动画
    [imageView.layer addAnimation:animation forKey:@"scaleLink-layer"];
}

//移除抖动动画
- (void)stopShake:(UIImageView *)imageView
{
    
    [imageView.layer removeAnimationForKey:@"scaleLink-layer"];

    [imageView removeFromSuperview];
}


- (void)commentButtonClicked
{
    if (self.commentButtonClickedOperation) {
        self.commentButtonClickedOperation();
    }
    self.show = NO;
}

- (void)setShow:(BOOL)show
{
    _show = show;
    if (_isLink) {
        [_likeButton setTitle:@"取消" forState:UIControlStateNormal];
    }else{
        [_likeButton setTitle:@"赞" forState:UIControlStateNormal];
    }
    
    NSLog(@"setShow==%d",show);
    
    [UIView animateWithDuration:0.2 animations:^{
        if (!show) {
            [self clearAutoWidthSettings];
            self.sd_layout
            .widthIs(0);
        } else {
            self.fixedWidth = nil;
            [self setupAutoWidthWithRightView:_commentButton rightMargin:5];
        }
        [self updateLayoutWithCellContentView:self.superview];
    }];
}


@end
