//
//  PictureViewController.h
//  类似QQ图片添加、图片浏览
//
//  Created by seven on 16/4/1.
//  Copyright © 2016年 QQpicture. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedPhotosArray)(NSArray *blockArray);

@interface PictureViewController : UIViewController

@property(nonatomic,strong)UICollectionView *pictureCollectonView;

@property(assign ,nonatomic) NSInteger maxNum;//添加照片的最大数量
@property(nonatomic,assign)  CGSize itemSize;//展示每张图片的大小
@property(nonatomic,strong)  UIImage *addImage;//添加按钮的图片
@property(nonatomic,assign)  CGFloat minimumInteritemSpacing;
@property(nonatomic,assign)  CGFloat minimumLineSpacing;//上下的间距 
@property(nonatomic,assign)  UIEdgeInsets sectionInset;
@property (nonatomic,assign,readonly)  NSUInteger count;//每行的张数

@property(nonatomic,assign)  CGRect pictureCollectonViewFrame;

@property(nonatomic,copy) SelectedPhotosArray  SelectedPhotosArrayBlock;

- (void)setSelectedPhotosArrayBlock:(SelectedPhotosArray)SelectedPhotosArrayBlock;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com