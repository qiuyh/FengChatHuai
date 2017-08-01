//
//  QYHToolView.m
//  FengChatHuai
//
//  Created by 邱永槐 on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHToolView.h"
#import "QYHImageModelClass.h"
#import "QYHHistoryImage.h"

typedef NS_ENUM(NSInteger, ChatToolStatus) {
    ChatToolStatusNothing,
    ChatToolStatusShowVoice,
    ChatToolStatusShowFace,
    ChatToolStatusShowMore,
    ChatToolStatusShowKeyboard,
};

@interface QYHToolView()

@property (nonatomic, strong) UIImageView *imgView;

//最左边发送语音的按钮
@property (nonatomic, strong) UIButton *voiceChangeButton;

//发送语音的按钮
@property (nonatomic, strong) UIButton *sendVoiceButton;

//文本视图
//@property (nonatomic, strong) UITextView *sendTextView;

//切换键盘
@property (nonatomic, strong) UIButton *changeKeyBoardButton;

//More
@property (nonatomic, strong) UIButton *moreButton;

//键盘坐标系的转换
@property (nonatomic, assign) CGRect endKeyBoardFrame;


//表情键盘
//@property (nonatomic, strong) QYHFunctionView *functionView;

@property (nonatomic, strong) UIButton *sendButton;

//more
//@property (nonatomic, strong) QYHMoreView *moreView;

//数据model
@property (strong, nonatomic) QYHImageModelClass  *imageMode;

@property (strong, nonatomic) QYHHistoryImage *tempImage;


//传输文字的block回调
@property (strong, nonatomic) MyTextBlock textBlock;

//contentsinz
@property (strong, nonatomic) ContentSizeBlock sizeBlock;

//传输volome的block回调
@property (strong, nonatomic) AudioVolumeBlock volumeBlock;

//传输录音地址
@property (strong, nonatomic) AudioURLBlock urlBlock;

//传输录音总时间
@property (strong, nonatomic) AudioTimeBlock timeBlock;

//录音取消
@property (strong, nonatomic) CancelRecordBlock cancelBlock;

//录音开始
@property (strong, nonatomic) BeganRecordBlock beganBlock;

//扩展功能回调
@property (strong, nonatomic) ExtendFunctionBlock extendBlock;

//添加录音功能的属性
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSURL *audioPlayURL;

@property (strong, nonatomic) NSString *string;

@end

@implementation QYHToolView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"toolbar_bottom_bar.png"]];
//        [self setBackgroundColor:[UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0]];
        
        
        // Initialization code
        //imageMode的初始化，存入历史表情
//        self.imageMode = [[QYHImageModelClass alloc] init];
//        
//        
//        [self addSubview];
//        [self addConstraint];
        
    }
    return self;
}

- (void)initView:(BOOL)isChating{
    
    _isChating = isChating;
    
    [self addSubview];
    [self addConstraint];
    
    [self setBackgroundColor:[UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0]];
}

-(void)setMyTextBlock:(MyTextBlock)block
{
    self.textBlock = block;
}

-(void)setBeganRecordBlock:(BeganRecordBlock)block
{
    self.beganBlock = block;
}

-(void)setAudioVolumeBlock:(AudioVolumeBlock)block
{
    self.volumeBlock = block;
}

-(void)setAudioURLBlock:(AudioURLBlock)block
{
    self.urlBlock = block;
}

-(void)setAudioTimeBlock:(AudioTimeBlock)block
{
    self.timeBlock = block;
}

-(void)setContentSizeBlock:(ContentSizeBlock)block
{
    self.sizeBlock = block;
}

-(void)setCancelRecordBlock:(CancelRecordBlock)block
{
    self.cancelBlock = block;
}

-(void)setExtendFunctionBlock:(ExtendFunctionBlock)block
{
    self.extendBlock = block;
}


//控件的初始化
-(void) addSubview
{
    
    self.imgView =[[UIImageView alloc]initWithFrame:CGRectZero];
    self.imgView.backgroundColor = [UIColor colorWithRed:165.0/255 green:165.0/255 blue:165.0/255 alpha:1.0];
    [self addSubview:self.imgView];

    if (_isChating) {
        
        self.voiceChangeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.voiceChangeButton setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
        [self.voiceChangeButton addTarget:self action:@selector(tapVoiceChangeButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.voiceChangeButton];
        
        self.sendVoiceButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.sendVoiceButton setBackgroundImage:[UIImage imageNamed:@"dd_press_to_say_normal"] forState:UIControlStateNormal];
        [self.sendVoiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //    [self.sendVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
        
        
        [self.sendVoiceButton addTarget:self action:@selector(tapSendVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
        self.sendVoiceButton.hidden = YES;
        [self addSubview:self.sendVoiceButton];
    }
   
    
    self.sendTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    [self.sendTextView.layer setMasksToBounds:YES];
    [self.sendTextView setScrollsToTop:NO];
    [self.sendTextView setFont:[UIFont systemFontOfSize:16.0f]];
    [self.sendTextView.layer setCornerRadius:4.0f];
    [self.sendTextView.layer setBorderWidth:0.5f];
    [self.sendTextView.layer setBorderColor:[UIColor colorWithRed:165.0/255 green:165.0/255 blue:165.0/255 alpha:1.0].CGColor];
    self.sendTextView.delegate = self;
    self.sendTextView.returnKeyType = UIReturnKeySend;
    self.sendTextView.enablesReturnKeyAutomatically = YES;
    [self addSubview:self.sendTextView];
    
    self.changeKeyBoardButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.changeKeyBoardButton setImage:[UIImage imageNamed:@"dd_emotion"] forState:UIControlStateNormal];
    [self.changeKeyBoardButton addTarget:self action:@selector(tapChangeKeyBoardButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.changeKeyBoardButton];
    
    if (_isChating) {
        self.moreButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.moreButton setImage:[UIImage imageNamed:@"dd_utility"] forState:UIControlStateNormal];
        [self.moreButton addTarget:self action:@selector(tapMoreButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.moreButton];
    }
    
//    self.backgroundColor = [UIColor colorWithHexString:kDefaultBackgroundColor];
    
//    [self addDone];
    
    
    //设置资源加载的文件名
//    self.functionView.plistFileName = @"emoticons";
    
    //实例化FunctionView
    self.functionView = [[QYHFunctionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 230)];
    self.functionView.backgroundColor = [UIColor whiteColor];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendButton.frame = CGRectMake(SCREEN_WIDTH -  80, 195, 60, 30);
    self.sendButton.layer.cornerRadius = 5;
    self.sendButton.clipsToBounds = YES;
    self.sendButton.enabled = NO;
    self.sendButton.titleLabel.font  = [UIFont systemFontOfSize:15];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"dd_image_send"] forState:UIControlStateNormal];

    
    [self.sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.functionView addSubview:self.sendButton];
    
    __weak __block QYHToolView *copy_self = self;
    //获取图片并显示
    [self.functionView setFunctionBlock:^(UIImage *image, NSString *imageText)
     {
         //删除
         if ([imageText isEqualToString:@"cancel"]) {
             
             [copy_self deleteEmojiFace];
             
             if (!copy_self.sendTextView.text.length)
             {
                 copy_self.sendButton.enabled = NO;
             }

             
         }else
         {
             
             NSString *str = [NSString stringWithFormat:@"%@%@",copy_self.sendTextView.text, imageText];
             
             NSLog(@"获取图片并显示str ==%@",str);
             
             copy_self.sendTextView.text = str;
             
             
             CGSize contentSize = copy_self.sendTextView.contentSize;
             
             if (copy_self.sizeBlock) {
                 copy_self.sizeBlock(contentSize);
             }
             

             if (str.length)
             {
                 copy_self.sendButton.enabled = YES;
                 
             }
             
         }

         
         
         //把使用过的图片存入sqlite
//         NSData *imageData = UIImagePNGRepresentation(image);
//         [copy_self.imageMode save:imageData ImageText:imageText];
     }];
    
    
    //给sendTextView添加轻击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.delegate = self;
    [self.sendTextView addGestureRecognizer:tapGesture];
    
    
    //给sendVoiceButton添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sendVoiceButtonLongPress:)];
    //设置长按时间
    longPress.minimumPressDuration = 0.2;
    [self.sendVoiceButton addGestureRecognizer:longPress];
    
    //实例化MoreView
    self.moreView = [[QYHMoreView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.moreView.backgroundColor = [UIColor whiteColor];
    [self.moreView setMoreBlock:^(NSInteger index) {
        NSLog(@"MoreIndex = %d",(int)index);
        copy_self.extendBlock((int)index);
    }];
    
    
    
    _faceMoreView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 230)];
    
    [self.faceMoreView addSubview:self.functionView];
    [self.faceMoreView addSubview:self.moreView];
    self.functionView.hidden = YES;
    self.moreView.hidden = YES;
    
    
}


- (void)deleteEmojiFace
{
    
    NSString* toDeleteString = nil;
    if (self.sendTextView.text.length == 0)
    {
        return;
    }
    if (self.sendTextView.text.length == 1)
    {
        self.sendTextView.text = @"";
    }
    else
    {
        NSUInteger length = 0;
        
        for (NSUInteger j=0; j<5; j++) {
            
            if ((self.sendTextView.text.length < (3+j))) {
                
                break;
            }
            
            toDeleteString = [self.sendTextView.text substringFromIndex:self.sendTextView.text.length - (3+j)];
            
            if ([[QYHChatDataStorage shareInstance].faceDictionary objectForKey:toDeleteString]) {
                
                length = (3+j);
            }
            
            
            if (length)
            {
                break;
            }
            
        }
        
        length = length == 0 ? 1 : length;
        self.sendTextView.text = [self.sendTextView.text substringToIndex:self.sendTextView.text.length - length];
    }
    
    CGSize contentSize = self.sendTextView.contentSize;
    
    self.sizeBlock(contentSize);
}


//给控件加约束imgView
-(void)addConstraint
{
    self.imgView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *imgViewConstraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_imgView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_imgView)];
    [self addConstraints:imgViewConstraintH];
    
    NSArray *imgViewConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imgView(0.5)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_imgView)];
    [self addConstraints:imgViewConstraintV];

    if (_isChating) {
    //给voicebutton添加约束
    self.voiceChangeButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *voiceConstraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_voiceChangeButton(30)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_voiceChangeButton)];
    [self addConstraints:voiceConstraintH];
    
    NSArray *voiceConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_voiceChangeButton(30)]-8-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_voiceChangeButton)];
    [self addConstraints:voiceConstraintV];
    
    
    
    //给MoreButton添加约束
    self.moreButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *moreButtonH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_moreButton(30)]-5-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_moreButton)];
    [self addConstraints:moreButtonH];
    
    NSArray *moreButtonV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_moreButton(30)]-8-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_moreButton)];
    [self addConstraints:moreButtonV];
    }
    
    //给changeKeyBoardButton添加约束
    self.changeKeyBoardButton.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *KeyBoardButtonHeightConstraint ;
    if (_isChating) {
        KeyBoardButtonHeightConstraint = @"H:[_changeKeyBoardButton(33)]-43-|";
    }else{
        KeyBoardButtonHeightConstraint = @"H:[_changeKeyBoardButton(33)]-10-|";
    }
    NSArray *changeKeyBoardButtonH = [NSLayoutConstraint constraintsWithVisualFormat:KeyBoardButtonHeightConstraint options:0 metrics:0 views:NSDictionaryOfVariableBindings(_changeKeyBoardButton)];
    [self addConstraints:changeKeyBoardButtonH];
    
    NSArray *changeKeyBoardButtonV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_changeKeyBoardButton(33)]-5-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_changeKeyBoardButton)];
    [self addConstraints:changeKeyBoardButtonV];
    
    
    NSString *sendTextViewHeightConstraint ;
    if (_isChating) {
        sendTextViewHeightConstraint = @"H:|-45-[_sendTextView]-80-|";
    }else{
        sendTextViewHeightConstraint = @"H:|-10-[_sendTextView]-60-|";
    }
    
    //给文本框添加约束
    self.sendTextView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *sendTextViewConstraintH = [NSLayoutConstraint constraintsWithVisualFormat:sendTextViewHeightConstraint options:0 metrics:0 views:NSDictionaryOfVariableBindings(_sendTextView)];
    [self addConstraints:sendTextViewConstraintH];
    
    NSArray *sendTextViewConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_sendTextView]-5-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_sendTextView)];
    [self addConstraints:sendTextViewConstraintV];
    
    if (_isChating) {
    //语音发送按钮
        self.sendVoiceButton.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *sendVoiceButtonConstraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-45-[_sendVoiceButton]-80-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_sendVoiceButton)];
        [self addConstraints:sendVoiceButtonConstraintH];
        
        NSArray *sendVoiceButtonConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_sendVoiceButton]-5-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_sendVoiceButton)];
        [self addConstraints:sendVoiceButtonConstraintV];
    }
    
}

//长按手势触发的方法
-(void)sendVoiceButtonLongPress:(id)sender
{
    static int i = 1;
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        
        UILongPressGestureRecognizer * longPress = sender;
        
        //录音开始
        if (longPress.state == UIGestureRecognizerStateBegan)
        {
            
            i = 1;
            
//            [self.sendVoiceButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
               [self.sendVoiceButton setBackgroundImage:[UIImage imageNamed:@"dd_record_release_end"] forState:UIControlStateNormal];
            
            //录音初始化
            [self audioInit];
            
            //创建录音文件，准备录音
            if ([self.audioRecorder prepareToRecord])
            {
                //开始
                [self.audioRecorder record];
                
                //设置定时检测音量变化
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
            }
            
            self.beganBlock(1);
        }
        
        
        //取消录音
        if (longPress.state == UIGestureRecognizerStateChanged)
        {
            
            CGPoint piont = [longPress locationInView:self];
            NSLog(@"%f",piont.y);
            
            if (piont.y < -20)
            {
                if (i == 1) {
                    
                    [self.sendVoiceButton setBackgroundImage:[UIImage imageNamed:@"dd_press_to_say_normal"] forState:UIControlStateNormal];
                    [self.sendVoiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    
//                    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"录音取消" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
//                    [alter show];
                    //去除图片用的
                    self.cancelBlock(1);
                    i = 0;
                    
                }
                
                
            }else
            {
                //创建录音文件，准备录音
                if ([self.audioRecorder prepareToRecord])
                {
                    i = 1;
                    //开始
                    [self.audioRecorder record];
                    
                    self.beganBlock(1);
                }
            }
        }
        
        if (longPress.state == UIGestureRecognizerStateEnded) {
            
            
            [self.sendVoiceButton setBackgroundImage:[UIImage imageNamed:@"dd_press_to_say_normal"] forState:UIControlStateNormal];
            [self.sendVoiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
            if (i == 1)
            {
                NSLog(@"录音结束");
                
                double cTime = self.audioRecorder.currentTime;
                if (cTime > 1)
                {
//                    NSData *data = [NSData dataWithContentsOfFile:_string];
                    
                    //如果录制时间<1 不发送
                    NSLog(@"发出去");
                    self.timeBlock(cTime);
                    self.urlBlock(_string);
                    
                }
                else
                {
                    //删除记录的文件
                    [self.audioRecorder deleteRecording];
                    //                    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"录音时间太短！" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
                    //                    [alter show];
                    self.cancelBlock(0);
                    
                }
              
            }else
            {
                //删除记录的文件
                [self.audioRecorder deleteRecording];
                //取消结束
                self.beganBlock(0);
            }
            
            [self.audioRecorder stop];
            [_timer invalidate];

        }
        
        
    }
    
}





//录音部分初始化
-(void)audioInit
{
    NSError * err = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    [audioSession setActive:YES error:&err];
    
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    //通过可变字典进行配置项的加载
    NSMutableDictionary *setAudioDic = [[NSMutableDictionary alloc] init];
    
    //设置录音格式(aac格式)
    [setAudioDic setValue:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [setAudioDic setValue:@(44100) forKey:AVSampleRateKey];
    
    //设置录音通道数1 Or 2
    [setAudioDic setValue:@(1) forKey:AVNumberOfChannelsKey];
    
    //线性采样位数  8、16、24、32
    [setAudioDic setValue:@16 forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [setAudioDic setValue:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];
    
//    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    _string = [NSString stringWithFormat:@"%ld.aac", (long)[[NSDate date] timeIntervalSince1970]];
    
    NSString *str = [NSString stringWithFormat:@"%@%@", [QYHChatDataStorage shareInstance].homePath, _string];
    
    NSURL *url = [NSURL fileURLWithPath:str];
    _audioPlayURL = url;
    
    
    NSError *error;
    //初始化
    self.audioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:setAudioDic error:&error];
    //开启音量检测
    self.audioRecorder.meteringEnabled = YES;
    self.audioRecorder.delegate = self;
    
}




////把图片和声音传到服务器上服务器会返回上传资源的地址
//-(void)sendContentToServer:(id) resource
//{
//
//    __weak __block ToolView *copy_self = self;
//
//    AFHTTPRequestOperationManager * m = [[AFHTTPRequestOperationManager alloc]init];
//    AFHTTPRequestOperation * op = [m POST:HTTPSERVER parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//
//
//        //根据地址上传声音
//        if ([resource isKindOfClass:[NSURL class]])
//        {
//            NSError * error;
//            NSString *path = @"/Users/ibokan/Library/Application Support/iPhone Simulator/7.1/Applications/B17EE653-D33C-4B46-B700-8845399FFE4D/Documents/1411779524.aac";
//            NSURL *url = [NSURL fileURLWithPath:path];
//
//            NSLog(@"%@", url);
//            NSLog(@"%@", resource);
//
//            NSLog(@"%@", path);
//            NSLog(@"%@", _string);
//
//            [formData appendPartWithFileURL:url name:@"file" error:&error];
//            if (error) {
//                NSLog(@"拼接资源失败%@",[error localizedDescription]);
//            }
//        }
//
//        //上传图片
//        if ([resource isKindOfClass:[UIImage class]]) {
//            //把图片转换成NSData类型的数据
//            NSData *imageData = UIImagePNGRepresentation(resource);
//
//
//            //把图片拼接到数据中
//            [formData appendPartWithFileData:imageData name:@"file" fileName:@"123.png" mimeType:@"image/png"];
//        }
//
//
//
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil]);
//
//        NSDictionary *mydic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
//
//        //获取上传地址的路径
//        NSURL *myURL = [NSURL URLWithString:mydic[@"success"]];
//        NSLog(@"%@", myURL);
////        [copy_self sendMessage:copy_self.sentType Content:myURL];
//
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"失败！！%@",error);
//    }];
//    op.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [op start];
//}


//录音的音量探测
- (void)detectionVoice
{
    [self.audioRecorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    CGFloat lowPassResults = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));
    
    //把声音的音量传给调用者
    self.volumeBlock(lowPassResults);
}


//通过屏幕旋转改变function的高度
-(void) changeFunctionHeight: (float) height
{
    CGRect frame = self.functionView.frame;
    frame.size.height = height;
    self.functionView.frame = frame;
    self.moreView.frame = frame;
}



//轻击sendText切换键盘
-(void)tapGesture:(UITapGestureRecognizer *) sender
{
    NSLog(@"tapGesture");
    if ([self.sendTextView.inputView isEqual:self.faceMoreView])
    {
        self.sendTextView.inputView = nil;
        
        [self.changeKeyBoardButton setImage:[UIImage imageNamed:@"dd_emotion"] forState:UIControlStateNormal];
        
        [self.sendTextView reloadInputViews];
    }
    
    if (![self.sendTextView isFirstResponder])
    {
        [self.sendTextView becomeFirstResponder];
    }
}


//给键盘添加done键
-(void) addDone
{
    //TextView的键盘定制回收按钮
    UIToolbar * toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    
    UIBarButtonItem * item1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(tapDone:)];
    UIBarButtonItem * item2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * item3 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar.items = @[item2,item1,item3];
    
    self.sendTextView.inputAccessoryView =toolBar;
}


-(void)tapDone:(id)sender
{
    [self.sendTextView resignFirstResponder];
}



//通过文字的多少改变toolView的高度
-(void)textViewDidChange:(UITextView *)textView
{
    CGSize contentSize = self.sendTextView.contentSize;
    
    if (self.sizeBlock) {
        self.sizeBlock(contentSize);
    }
    
}


//解决：  iOS7及以上的版本上，UITextView输入中文时，在输入多行后，光标有时会上下跳动，输入文字的时候内容有时会往上跳，光标都显示不出来。
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    //fix ios7 bug (modified by 老岳).
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        CGRect r = [textView caretRectForPosition:textView.selectedTextRange.end];
        CGFloat caretY =  MAX(r.origin.y - textView.frame.size.height + r.size.height + 8, 0);
        if (textView.contentOffset.y < caretY && r.origin.y != INFINITY) {
            textView.contentOffset = CGPointMake(0, caretY);
        }
    }
}

//切换声音按键和文字输入框
-(void)tapVoiceChangeButton:(UIButton *) sender
{
    
    if (self.sendVoiceButton.hidden == YES)
    {
        self.sendTextView.hidden = YES;
        self.sendVoiceButton.hidden = NO;
        [self.voiceChangeButton setImage:[UIImage imageNamed:@"dd_input_normal"] forState:UIControlStateNormal];
        
        if ([self.sendTextView isFirstResponder]) {
            [self.sendTextView resignFirstResponder];
        }
        
        self.sizeBlock(CGSizeMake(0, 36));
    }
    else
    {
        self.sendTextView.hidden = NO;
        self.sendVoiceButton.hidden = YES;
        [self.voiceChangeButton setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
        
        CGSize contentSize = self.sendTextView.contentSize;
        self.sizeBlock(contentSize);
        
        if (![self.sendTextView isFirstResponder]) {
            [self.sendTextView becomeFirstResponder];
        }
    }
}


//发送信息（点击发送）
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"])
    {
        
        [self sendAction];
        
        return NO;
    }
    if ([text isEqualToString:@""])
    {

        [self deleteEmojiFace];
    
         return NO;
    }
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.08 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        CGSize contentSize = self.sendTextView.contentSize;
//        self.sizeBlock(contentSize);
//    });
   
    
    return YES;
}


- (void)sendAction
{

    if (!self.sendTextView.text.length) {
      
        return;
    }
    
    NSString *text = [self.sendTextView.text copy];
    
    self.sendTextView.text = @"";
    
    self.sendButton.enabled = NO;
    
    //通过block回调把text的值传递到Controller中共
    if (self.textBlock) {
        self.textBlock(text);
    }
    
    CGSize contentSize = self.sendTextView.contentSize;
    
    if (self.sizeBlock) {
        self.sizeBlock(contentSize);
    }
    
}



//发送声音按钮回调的方法
-(void)tapSendVoiceButton:(UIButton *) sender
{
    NSLog(@"sendVoiceButton");
    
     self.cancelBlock(0);
    //点击发送按钮没有触发长按手势要做的事儿
//    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"按住录音" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
//    [alter show];
}

//变成表情键盘
-(void)tapChangeKeyBoardButton:(UIButton *) sender
{
    if ([self.sendTextView.inputView isEqual:self.faceMoreView])
    {
        
        if (self.functionView.hidden) {
            
            [self getFunctionView];
        }else{
            self.sendTextView.inputView = nil;
            
            [self.changeKeyBoardButton setImage:[UIImage imageNamed:@"dd_emotion"] forState:UIControlStateNormal];
            
            [self.sendTextView reloadInputViews];
            
            self.faceMoreView.hidden = YES;
            self.moreView.hidden     = YES;
            self.functionView.hidden = YES;
        }
    }
    else
    {
       [self getFunctionView];
    }
    
    if (sender) {
        if (![self.sendTextView isFirstResponder])
        {
            [self.sendTextView becomeFirstResponder];
        }
    }
    
    
    
    if (self.sendTextView.hidden == YES) {
        self.sendTextView.hidden = NO;
        self.sendVoiceButton.hidden = YES;
        [self.voiceChangeButton setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
        
    }
    
}

//功能扩展
-(void)tapMoreButton:(UIButton *) sender
{
    if ([self.sendTextView.inputView isEqual:self.faceMoreView])
    {
        if (self.moreView.hidden) {
            
             [self getMoreView];
            
        }else{
            self.sendTextView.inputView = nil;
            
            [self.sendTextView reloadInputViews];
            
            self.faceMoreView.hidden = YES;
            self.moreView.hidden     = YES;
            self.functionView.hidden = YES;
        }
    }
    else
    {
        [self getMoreView];
    }
    
    if (sender) {
        if (![self.sendTextView isFirstResponder])
        {
            [self.sendTextView becomeFirstResponder];
        }
    }
    
    
    if (self.sendTextView.hidden == YES) {
        self.sendTextView.hidden = NO;
        self.sendVoiceButton.hidden = YES;
        
    }
    
}

- (void)getFunctionView{
    
    self.faceMoreView.hidden = NO;
    self.functionView.hidden = NO;
    [self.faceMoreView bringSubviewToFront:self.functionView];
    
    self.sendTextView.inputView = self.faceMoreView;
    
    [self.changeKeyBoardButton setImage:[UIImage imageNamed:@"dd_input_normal"] forState:UIControlStateNormal];
//    [self.functionView tapButton1:nil];
    [self.sendTextView reloadInputViews];
    
    self.functionView.frame = CGRectMake(0, 230, SCREEN_WIDTH, 230);
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.functionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 230);
        
    } completion:^(BOOL finished) {
        
        self.moreView.hidden = YES;
    }];

}


- (void)getMoreView{
    
    self.faceMoreView.hidden = NO;
    self.moreView.hidden     = NO;
    [self.faceMoreView bringSubviewToFront:self.moreView];
    
    self.sendTextView.inputView = self.faceMoreView;
    [self.sendTextView reloadInputViews];
    
    [self.changeKeyBoardButton setImage:[UIImage imageNamed:@"dd_emotion"] forState:UIControlStateNormal];
    
    self.moreView.frame = CGRectMake(0, 230, SCREEN_WIDTH, 230);
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.moreView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 230);
        
    } completion:^(BOOL finished) {
        
        self.functionView.hidden = YES;
    }];

}


#pragma mark - gesture delegate




- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    [self tapGesture:nil];
    return YES;
}


@end
