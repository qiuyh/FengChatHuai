//
//  QYHFunctionView.m
//  FengChatHuai
//
//  Created by 邱永槐 on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHFunctionView.h"
#import "QYHFaceView.h"
#import "QYHImageModelClass.h"
#import "QYHHistoryImage.h"

@interface QYHFunctionView()<UIScrollViewDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) FunctionBlock block;
//暂存表情组件回调的表情和表情文字
@property (strong, nonatomic) UIImage *headerImage;
@property (strong, nonatomic) NSString *imageText;
@property (strong, nonatomic) UIPageControl *pageControl;
//display我们的表情图片
@property (strong, nonatomic) UIScrollView *headerScrollView;

//定义数据模型用于获取历史表情
@property (strong, nonatomic) QYHImageModelClass *imageModel;

@end


@implementation QYHFunctionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        //实例化数据模型
//        self.imageModel =[[QYHImageModelClass alloc] init];
        
        //实例化下面的button
//        UIButton *faceButton = [[UIButton alloc] initWithFrame:CGRectZero];
//        faceButton.backgroundColor = [UIColor grayColor];
//        
//        [faceButton setTitle:@"全部表情" forState:UIControlStateNormal];
//        [faceButton setShowsTouchWhenHighlighted:YES];
//        [faceButton addTarget:self action:@selector(tapButton1:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:faceButton];
        
        
        //实例化常用表情按钮
//        UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectZero];
//        moreButton.backgroundColor = [UIColor orangeColor];
//        [moreButton setTitle:@"常用表情" forState:UIControlStateNormal];
//        [moreButton setShowsTouchWhenHighlighted:YES];
//        [moreButton addTarget:self action:@selector(tapButton2:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:moreButton];
        
//        //给按钮添加约束
//        faceButton.translatesAutoresizingMaskIntoConstraints = NO;
//        moreButton.translatesAutoresizingMaskIntoConstraints = NO;
//        //水平约束
//        NSArray *buttonH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[faceButton][moreButton(==faceButton)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(faceButton,moreButton)];
//        [self addConstraints:buttonH];
//        
//        //垂直约束
//        NSArray *button1V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[faceButton(44)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(faceButton)];
//        [self addConstraints:button1V];
//        
//        NSArray *button2V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[moreButton(44)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(moreButton)];
//        [self addConstraints:button2V];
        
        //默认显示表情图片
        [self tapButton1:nil];
        
    }
    return self;
}

//接受回调
-(void)setFunctionBlock:(FunctionBlock)block
{
    self.block = block;
}

//点击全部表情按钮回调方法
-(void)tapButton1: (id) sender
{
//    // 从plist文件载入资源
//    NSBundle *bundle = [NSBundle mainBundle];
//    NSString *path = [bundle pathForResource:@"emoticons" ofType:@"plist"];
//    NSArray *headers = [NSArray arrayWithContentsOfFile:path];
//    
//    if (headers.count == 0) {
//        NSLog(@"访问的plist文件不存在");
//    }
//    else
//    {
//        //调用headers方法显示表情
//        [self header:headers];
//    }
    
    //调用headers方法显示表情
    [self header:[QYHChatDataStorage shareInstance].faceDataArray];
}

//点击历史表情的回调方法
-(void) tapButton2: (id) sender
{
    
    //从数据库中查询所有的图片
    NSArray *imageData = [self.imageModel queryAll];
    //解析请求到的数据
    NSMutableArray *headers = [NSMutableArray arrayWithCapacity:imageData.count];
    
    //数据实体，相当于javaBean的东西
    QYHHistoryImage *tempData;
    
    for (int i = 0; i < imageData.count; i ++) {
        tempData = imageData[i];
        
        //解析数据，转换成函数headers要用的数据格式
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
        [dic setObject:tempData.imageText forKey:@"chs"];
        UIImage *image = [UIImage imageWithData:tempData.headerImage];
        [dic setObject:image forKey:@"png"];
        
        [headers addObject:dic];
    }
    
    [self header:headers];
    
}


//负责把查出来的图片显示
-(void) header:(NSArray *)headers
{
    [self.headerScrollView removeFromSuperview];
    self.headerScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.headerScrollView.backgroundColor = [UIColor whiteColor];
    self.headerScrollView.bounces  = NO;
    self.headerScrollView.delegate = self;
    self.headerScrollView.showsVerticalScrollIndicator    = NO;
    self.headerScrollView.showsHorizontalScrollIndicator  = NO;
    
    [self addSubview:self.headerScrollView];
    
    //给scrollView添加约束
    self.headerScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    //水平约束
    NSArray *scrollH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_headerScrollView]|" options:0   metrics:0 views:NSDictionaryOfVariableBindings(_headerScrollView)];
    [self addConstraints:scrollH];
    
    //垂直约束
    NSArray *scrolV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headerScrollView]-30-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_headerScrollView)];
    [self addConstraints:scrolV];
    
    
    
    CGFloat scrollHeight = self.frame.size.height -60;
    
//    int count  = 0;
//    
//    for (id obj in headers)
//    {
//        if (![obj[@"png"]isEqualToString:@""])
//        {
//            count++;
//        }
//    }
    
    //根据图片量来计算scrollView的Contain的宽度
    CGFloat width = (headers.count/28 + (headers.count/28 ? 1:0))*SCREEN_WIDTH ;
    
    self.headerScrollView.contentSize = CGSizeMake(width, scrollHeight);
    self.headerScrollView.pagingEnabled = YES;
    
    _pageControl =[[UIPageControl alloc]initWithFrame:CGRectMake(0.0, 180,SCREEN_WIDTH, 0.0)];
    _pageControl.numberOfPages = width/SCREEN_WIDTH;
    _pageControl.currentPage   = 0;
    _pageControl.pageIndicatorTintColor        = [UIColor colorWithRed:204/255.0 green:204/255.0  blue:204/255.0  alpha:1.0];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:236/255.0  green:88/255.0  blue:78/255.0  alpha:1.0];
    
    [self addSubview:_pageControl];
    [self sendSubviewToBack:self.headerScrollView];
    
    
    //图片坐标
    CGFloat x = 0;
    CGFloat y = 0;
    
    CGFloat spaceX = 0;
    CGFloat spaceY = 0;
    
    //往scroll上贴图片
    for (int i = 0; i <=  headers.count; i ++) {
        //获取图片信息
        UIImage *image;
        NSString *imageText ;
        
        if ((!((i+1)%28)&&i) || i == headers.count)
        {
            image     = [UIImage imageNamed:@"dd_emoji_delete"];
            imageText = @"cancel";
            
        }else
        {
            
            NSString *imageName =  [@"MLEmoji_Expression.bundle" stringByAppendingPathComponent:[QYHChatDataStorage shareInstance].faceDictionary[headers[i]]];
            
            image =  [UIImage imageNamed:imageName];
            imageText = headers[i];
            
//            if ([headers[i-(i+1)/28][@"png"] isKindOfClass:[NSString class]])
//            {
//                image = [UIImage imageNamed:headers[i-(i+1)/28][@"png"]];
//            }
//            else
//            {
//                image = headers[i-(i+1)/28][@"png"];
//            }
//            
//            imageText = headers[i-(i+1)/28][@"chs"];
            
        }
        
        
        spaceX = (SCREEN_WIDTH  - 30*7)/8.0;
        spaceY = (scrollHeight  - 30*4)/5.0;
        
        //计算图片位置
        x = (i/4) * (30 + spaceX) + (i/28 + 1)*spaceX;
        y = (i%4) * (30 + spaceY) + spaceY;
        
        QYHFaceView *face = [[QYHFaceView alloc] initWithFrame:CGRectMake(x, y, 30, 30)];
        if ((!((i+1)%28)&&i) || i == headers.count)
        {
            face.imageView.frame = CGRectMake(0, 5, 30, 20);
        }

        [face setImage:image ImageText:imageText];
        
        //face的回调，当face点击时获取face的图片
        __weak __block QYHFunctionView *copy_self = self;
        [face setFaceBlock:^(UIImage *image, NSString *imageText)
         {
             copy_self.block(image, imageText);
         }];
        
        [self.headerScrollView addSubview:face];
    }
    
    [self.headerScrollView setNeedsDisplay];
    
}

#pragma mark-UIScrollViewDelegate

//结束减速
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    _pageControl.currentPage = scrollView.contentOffset.x/scrollView.frame.size.width;
    
}

@end
