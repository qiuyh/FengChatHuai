//
//  QYHDiscoverTableViewCell.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/15.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYHDiscoverHeight.h"
#import "QYHOperationMenuView.h"

@class QYHDiscoverTableViewCell;
/**
 *  评论、赞
 */
typedef NS_ENUM(NSInteger,ClickCommentType) {
    /**
     *  赞
     */
    LikeButtonClickedOperation,
    /**
     *  评论
     */
    CommentButtonClickedOperation
};

@protocol QYHDiscoverTableViewCellDelagete <NSObject>

- (void)clickHeadImageByPhotoNumber:(NSString *)photoNumber;
- (void)clickAllTextButton:(BOOL)isOpening indexCell:(QYHDiscoverTableViewCell *)cell;
- (void)commentActionByPhotoNumber:(NSString *)photoNumber time:(NSString *)time type:(ClickCommentType)type isLink:(BOOL)isLink;
- (void)displayImagesByArrays:(NSArray *)photosUrl index:(NSInteger)index;

-(void)setCommentIndexCell:(QYHDiscoverTableViewCell *)cell;

- (void)dismissOperationView:(QYHDiscoverTableViewCell *)cell;

-(void)answerCommentByToUser:(NSString *)toUser phoneNumber:(NSString *)phoneNumber time:(NSString *)time indexCell:(QYHDiscoverTableViewCell *)commentIndexCell;

- (void)gotoWebViewByUrlString:(NSString *)urlString;
- (void)showMenuCopy:(NSString *)copyString touch:(UITouch *)touch gesture:(UIGestureRecognizer *)gesture;

@end

@interface QYHDiscoverTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UIButton *nameButton;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UIButton *allTextButton;

@property (weak, nonatomic) IBOutlet UIView *photosView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *commentView;

@property (weak, nonatomic) IBOutlet UIButton *commentButton;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *allBtnHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photosViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameButtonWithConstraint;

@property (nonatomic,strong) QYHOperationMenuView *operationMenu;

@property (nonatomic,assign) BOOL isLink;//是否赞了

@property (nonatomic,copy) NSString    *photoNumber;
@property (nonatomic,copy) NSString    *time;
@property (nonatomic,strong) NSArray   *photosUrl;
@property (nonatomic,assign) NSInteger index;

@property (nonatomic,weak) id<QYHDiscoverTableViewCellDelagete> delegate;

- (void)confitDataByDic:(NSDictionary *)dic height:(QYHDiscoverHeight *)heightModel detail:(BOOL)isDetail;

@end
