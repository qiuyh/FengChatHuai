//
//  QYHCircleCell.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/9/7.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHCircleCell.h"
#import "UIView+SDAutoLayout.h"
#import "UIImageView+WebCache.h"


@interface QYHCircleCell ()

@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *contentLabel;
@property (nonatomic,strong) UILabel *countLabel;
@property (nonatomic,strong) UIView *imagesView;


@end

@implementation QYHCircleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentBgView.hidden = NO;
        self.timeLabel.hidden = NO;
        self.imagesView.hidden = NO;
        self.contentLabel.hidden = NO;
        self.countLabel.hidden = NO;
        
        self.backgroundColor = [UIColor colorWithHexString:kDefaultBackgroundColor];
    }
    
    return self;
}

-(void)confitDataByQYHCircleContentModel:(QYHCircleContentModel *)model firstRow:(BOOL)isFirstRow{
//    
//    NSString *photoNumber = [dic objectForKey:@"photoNumber"];
//    NSString *time        = [dic objectForKey:@"time"];
//    NSString *content     = [dic objectForKey:@"content"];
//    NSArray  *commentArray ;
//    NSArray  *imagesUrl;
//    if ([[dic objectForKey:@"comment"] isKindOfClass:[NSArray class]]) {
//        commentArray   = [dic objectForKey:@"comment"];
//    }
//    
//    if ([[dic objectForKey:@"imagesUrl"] isKindOfClass:[NSArray class]]) {
//        imagesUrl   = [dic objectForKey:@"imagesUrl"];
//    }
    
    if (isFirstRow) {
        self.timeLabel.attributedText = [self getDayAndMonthByTime:model.time];
        self.timeLabel.hidden = NO;
    }else{
        self.timeLabel.hidden = YES;
    }
    
    self.contentLabel.text = model.content;
   
    CGFloat space;
    [self.imagesView removeAllSubviews];
    if (model.imagesArrM) {
        [self initImageViewByImages:model.imagesArrM];
        
        space = 170;
        self.countLabel.hidden = NO;
        self.countLabel.text = [NSString stringWithFormat:@"共%lu张",model.imagesArrM.count];
    }else{
        space = 90;
        self.countLabel.hidden = YES;
    }
    
    CGSize size = [NSString getContentSize:model.content fontOfSize:16.0f maxSizeMake:CGSizeMake(SCREEN_WIDTH-space, 60)];
    self.imagesView.sd_layout.leftSpaceToView(self.contentView,80).topEqualToView(self.contentView).widthIs(model.imagesArrM?80:0).heightIs(80);
    self.contentLabel.sd_layout.leftSpaceToView(self.imagesView,5).rightSpaceToView(self.contentView,5).topEqualToView(self.contentView).heightIs(size.height);
     self.countLabel.sd_layout.leftSpaceToView(self.imagesView,5).bottomEqualToView(self.imagesView).heightIs(18).widthIs(100);
    self.contentBgView.sd_layout.leftSpaceToView(self.contentView,80).topEqualToView(self.contentView).widthIs(SCREEN_WIDTH - 85).heightIs(model.imagesArrM?80:size.height);
    
}

#pragma mark - 获取时间月日

- (NSMutableAttributedString *)getDayAndMonthByTime:(NSString *)time{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSString转NSDate
    NSDate *date=[formatter dateFromString:time];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    comps = [calendar components:unitFlags fromDate:date];
    long day=[comps day];//获取日期对应的长整形字符串
    long month=[comps month];//获取月对应的长整形字符串
    
    NSString *string = [NSString stringWithFormat:@"%02ld%ld月",day,month];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:string];
    [attributedString addAttribute:NSFontAttributeName
     
                             value:[UIFont fontWithName:@"Arial-BoldMT" size:28.0f]
     
                             range:NSMakeRange(0, 2)];
    [attributedString addAttribute:NSFontAttributeName
     
                             value:[UIFont systemFontOfSize:13.0f]
     
                             range:NSMakeRange(2, attributedString.string.length-2)];
    
    return attributedString;
}


- (void)initImageViewByImages:(NSArray *)arr{
    
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imgView = [[UIImageView alloc]init];
        imgView.clipsToBounds = YES;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        
        NSString *smallSize = @"?imageView2/1/w/100/h/100";
        
        switch (arr.count) {
            case 1:
                imgView.frame = CGRectMake(0, 0, 80, 80);
                break;
            case 2:
                imgView.frame = CGRectMake(idx*40.5, 0, 39.5, 80);
                smallSize = @"?imageView2/1/w/100/h/200";
                break;
            case 3:
            {
                if (idx==0) {
                    imgView.frame = CGRectMake(idx*40.5, 0, 39.5, 80);
                    smallSize = @"?imageView2/1/w/100/h/200";
                }else{
                    imgView.frame = CGRectMake(40.5, 40.5*(idx-1), 39.5, 39.5);
                    smallSize = @"?imageView2/1/w/100/h/100";
                }
                break;
            }
            default:
            {
                imgView.frame = CGRectMake(40.5*(idx%2), 40.5*(idx/2), 39.5, 39.5);
                smallSize = @"?imageView2/1/w/100/h/100";
                break;
            }
        }
        
        
        
        NSURL *url = [NSURL URLWithString:[arr[idx] stringByAppendingString:smallSize]];
        [imgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
        [self.imagesView addSubview:imgView];
        
        if (idx ==3) {
            *stop = YES;
        }
        
    }];
}


#pragma mark - 懒加载
-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, -5, 65, 30)];
        
        [self.contentView addSubview:_timeLabel];
    }
    
    return _timeLabel;
}

-(UIView *)imagesView{
    if (!_imagesView) {
        _imagesView = [[UIView alloc]init];
        _imagesView.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:_imagesView];
    }
    
    return _imagesView;
}

-(UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.font = [UIFont systemFontOfSize:16.0f];
        _contentLabel.numberOfLines = 0;
        
        [self.contentView addSubview:_contentLabel];
    }
    
    return _contentLabel;
}

-(UILabel *)countLabel{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc]init];
        _countLabel.font = [UIFont systemFontOfSize:14.0f];
        _countLabel.textColor = [UIColor grayColor];
        
        [self.contentView addSubview:_countLabel];
    }
    
    return _countLabel;
}

-(UIView *)contentBgView{
    if (!_contentBgView) {
        _contentBgView = [[UIView alloc]init];
//        _contentBgView.alpha = 0.5;
        _contentBgView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
        
        [self.contentView addSubview:_contentBgView];
    }
    
    return _contentBgView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
