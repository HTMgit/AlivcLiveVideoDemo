//
//  AlivcLiveViewController.m
//  DevAlivcLiveVideo
//
//  Created by yly on 16/3/21.
//  Copyright © 2016年 Alivc. All rights reserved.
//


#import "AlivcLiveViewController.h"

#import <AlivcLiveVideo/AlivcLiveVideo.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#import "AppDelegate.h"
#import "LPloginVC.h"
#import "LPbeginPlayingVC.h"
#import "ZYHCommonService.h"
#import "LPlivePlayingControlView.h"

@interface AlivcLiveViewController ()<AlivcLiveSessionDelegate,LPlivePlayingControlViewDelegate>{
    BOOL isLight;//是否开启闪光灯；
    BOOL isBeauty;//是否美颜；
    BOOL isMutePush;//是否静音推流；
    BOOL isPushing;//是否正在推流；
    NSString * detailStr;//推流详情
    LPlivePlayingControlView * controlView;
    CALayer * orangeLayer;
    NSTimeInterval _seconds;
    AlivcLConfiguration *configuration;
}


@property (nonatomic, strong) AlivcLiveSession *liveSession;


/* 推流模式（横屏or竖屏）*/
@property (nonatomic, assign) BOOL isScreenHorizontal;
/* 推流地址 */
@property (nonatomic, strong) NSString *url;
/* 摄像头方向记录 */
@property (nonatomic, assign) AVCaptureDevicePosition currentPosition;
/* 曝光度记录 */
@property (nonatomic, assign) CGFloat exposureValue;
// UI

//@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *btnCutOut;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) IBOutlet UIImageView *imgConnect;
@property (weak, nonatomic) IBOutlet UILabel *labBegin;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;

// 调试
@property (nonatomic, strong) CTCallCenter *callCenter;
@property (nonatomic, strong) NSTimer *pushTimer;
@property (nonatomic, strong) NSMutableArray *logArray;

@property (nonatomic, assign) BOOL isCTCallStateDisconnected;
@property (nonatomic, assign) CGFloat lastPinchDistance;

@end

@implementation AlivcLiveViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString *)url isScreenHorizontal:(BOOL)isScreenHorizontal{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _url = url;
    _isScreenHorizontal = isScreenHorizontal;
    return self;
}

// stream = "rtmp://video-center.alivecdn.com/stlive/10001?vhost=live.ymz008.com&auth_key=260014-0-0-44cbc11f42a42c264157aa68dc1f553b";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.logArray = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self addGesture];

    [self createSession];
    
    _btnCutOut.hidden = YES;
    isPushing = NO;
    _imgConnect.hidden = YES;
    //开启和监听 设备旋转的通知（不开启的话，设备方向一直是UIInterfaceOrientationUnknown）
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    NSLog(@"版本号:%@", [AlivcLiveSession alivcLiveVideoVersion]);
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dicUserInfo = [userDefaults objectForKey:@"userInfo"];
    NSError * transforError ;
    LPuserModel * userInfo = [LPuserModel arrayOfModelsFromDictionaries:@[dicUserInfo] error:&transforError].lastObject;
    [_imgUser sd_setImageWithURL:[NSURL URLWithString:userInfo.faceUrl] placeholderImage:[UIImage imageNamed:@"userDef"]];
}

#pragma mark - 推流Session 创建 销毁
- (void)createSession{
    if (!configuration) {
        configuration = [[AlivcLConfiguration alloc] init];
    }
    configuration.url = self.url;
    configuration.videoMaxBitRate = 1500 * 1000;
    configuration.videoBitRate = 600 * 1000;
    configuration.videoMinBitRate = 400 * 1000;
    configuration.audioBitRate = 64 * 1000;
    configuration.videoSize = CGSizeMake(360, 640);// 横屏状态宽高不需要互换
    configuration.fps = 20;
    configuration.preset = AVCaptureSessionPresetiFrame1280x720;
    configuration.screenOrientation = self.isScreenHorizontal;
    // 重连时长
    configuration.reconnectTimeout = 5;
    // 水印
    configuration.waterMaskImage = [UIImage imageNamed:@"watermask"];
    configuration.waterMaskLocation = 1;
    configuration.waterMaskMarginX = 10;
    configuration.waterMaskMarginY = 10;
    // 摄像头方向
    if (self.currentPosition) {
        configuration.position = self.currentPosition;
    } else {
        configuration.position = AVCaptureDevicePositionFront;
        self.currentPosition = AVCaptureDevicePositionFront;
    }
    configuration.frontMirror = YES;
    
    // alloc session
    self.liveSession = [[AlivcLiveSession alloc] initWithConfiguration:configuration];
    self.liveSession.delegate = self;
    // 是否静音推流
    self.liveSession.enableMute = isMutePush;
    // 开始预览
    [self.liveSession alivcLiveVideoStartPreview];
    // 开始推流
    [self.liveSession alivcLiveVideoConnectServer];
    
    NSLog(@"开始推流");

    dispatch_async(dispatch_get_main_queue(), ^{
        // 预览view
        [self.view insertSubview:[self.liveSession previewView] atIndex:0];
    });
    
    self.exposureValue = 0;
}

- (void)destroySession{
    [self.liveSession alivcLiveVideoDisconnectServer];
    [self.liveSession alivcLiveVideoStopPreview];
    [self.liveSession.previewView removeFromSuperview];
    self.liveSession = nil;
    NSLog(@"销毁推流");
}

#pragma mark - AlivcLiveVideo Delegate
- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session error:(NSError *)error{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *msg = [NSString stringWithFormat:@"%zd %@",error.code, error.localizedDescription];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Live Error" message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"重新连接", nil];
        alertView.delegate = self;
        [alertView show];
    });
    isPushing = NO;
    [self actionBtnChangeStatus:_btnCutOut];
    [self actionStopTimer];
    NSLog(@"liveSession Error : %@", error);
}

- (void)alivcLiveVideoLiveSessionNetworkSlow:(AlivcLiveSession *)session {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前网络环境较差" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
    detailStr = @"网速过慢，影响推流效果，拉流端会造成卡顿等，建议暂停直播";
    NSLog(@"网速过慢");
    
}

- (void)alivcLiveVideoLiveSessionConnectSuccess:(AlivcLiveSession *)session {
    
    if (!_btnCutOut.selected) {
        [self actionBtnChangeStatus:_btnCutOut];
    }
    if (!_pushTimer) {
        [self startDebug];
    }
    isPushing = YES;
    NSLog(@"推流  connect success!");
}


- (void)alivcLiveVideoReconnectTimeout:(AlivcLiveSession *)session error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"重连超时-error:%ld", error.code] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
    });
    isPushing = NO;
    [self actionBtnChangeStatus:_btnCutOut];
    [self actionStopTimer];
    NSLog(@"重连超时");
}


- (void)alivcLiveVideoOpenAudioSuccess:(AlivcLiveSession *)session {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"YES" message:@"麦克风打开成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //        [alertView show];
    //    });
}

- (void)alivcLiveVideoOpenVideoSuccess:(AlivcLiveSession *)session {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"YES" message:@"摄像头打开成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //        [alertView show];
    //    });
}


- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session openAudioError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"麦克风获取失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        //        [alertView show];
    });
}

- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session openVideoError:(NSError *)error {
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"摄像头获取失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //        [alertView show];
    //    });
}

- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session encodeAudioError:(NSError *)error {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"音频编码初始化失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //        [alertView show];
    //    });
    
}

- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session encodeVideoError:(NSError *)error {
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"视频编码初始化失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //        [alertView show];
    //    });
}

- (void)alivcLiveVideoLiveSession:(AlivcLiveSession *)session bitrateStatusChange:(ALIVC_LIVE_BITRATE_STATUS)bitrateStatus {
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"YES" message:[NSString stringWithFormat:@"ALIVC_LIVE_BITRATE_STATUS = %ld", bitrateStatus] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    //        [alertView show];
    //    });
    NSLog(@"码率变化 %ld", bitrateStatus);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self.liveSession alivcLiveVideoConnectServer];
    } else {
        [self.liveSession alivcLiveVideoDisconnectServer];
    }
}

#pragma mark - LPlivePlayingControlViewDelegate
-(void)livePlayingControl:(int)btnNum sender:(id)sender{
    controlView.hidden = YES;
    if (btnNum == -1) {
        return;
    }else if (btnNum == 0) {//旋转
//        UIButton * btn = (UIButton *)sender;
        _isScreenHorizontal =!_isScreenHorizontal;
        if (!_isScreenHorizontal) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];    appDelegate.allowRotation = NO;
            NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
            [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        }
        [self createSession];
//        [self.liveSession alivcLiveVideoConnectServer];
    }else if (btnNum == 1) {//摄像头
        [self cameraButtonClick:sender];
    }else if (btnNum == 2) {//闪光灯
        [self flashButtonClick:sender];
    }else if (btnNum == 3) {//美颜
        [self skinButtonClick:sender];
    }else if (btnNum == 4) {//静音
        [self muteButton:sender];
    }else if (btnNum == 5) {//管理set
        return;
    }
    
    
//    else if (btnNum == 1) {//slider
//        [self skinSliderAction:sender];
//    }else if (btnNum == 2) {//静音
//        [self muteButton:sender];
//    }else if (btnNum == 3) {//断开链接
//        [self disconnectButtonClick:sender];
//    }else if (btnNum == 4) {//摄像头
//        [self cameraButtonClick:sender];
//    }else if (btnNum == 5) {//闪光灯
//        [self flashButtonClick:sender];
//    }else if (btnNum == 6) {//美颜
//        [self skinButtonClick:sender];
//    }else if (btnNum == 7) {//关闭
//        [self buttonCloseClick:nil];
//    }
}

#pragma mark - Debug

- (void)startDebug {
    if(!self.pushTimer){
        self.pushTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeUpdate) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.pushTimer forMode:NSDefaultRunLoopMode];
    }
}

-(void)actionStopTimer{
    [self.pushTimer invalidate];
    self.pushTimer = nil;
    [orangeLayer removeFromSuperlayer];
}

- (void)timeUpdate{
    NSInteger currentTime = ++_seconds;
    _labBegin.text = [NSString stringWithFormat:@"%02d:%02d", (int)currentTime / 60, (int)currentTime % 60];
    if (!orangeLayer) {
        orangeLayer = [CALayer layer];
        orangeLayer.frame = CGRectMake(28.0, 5.0, 6.0, 6.0);
        orangeLayer.backgroundColor =[UIColor orangeColor].CGColor;// fHexColor(@"0xff6000").CGColor;
        orangeLayer.cornerRadius = 3.0f;
    }
    if (currentTime % 2 == 0) {
        [orangeLayer removeFromSuperlayer];
    } else {
        [_labBegin.layer addSublayer:orangeLayer];
    }
    
    
    // 获取调试信息
    AlivcLDebugInfo *i = [self.liveSession dumpDebugInfo];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    
    NSString *currentDateStr = [dateFormatter   stringFromDate:currentDate];
    
    NSMutableString *msg = [[NSMutableString alloc] init];
    [msg appendFormat:@"%@\n",currentDateStr];
    [msg appendFormat:@"CycleDelay(%0.2fms)\n",i.cycleDelay];
    [msg appendFormat:@"bitrate(%zd) buffercount(%zd)\n",[self.liveSession alivcLiveVideoBitRate] ,self.liveSession.dumpDebugInfo.localBufferVideoCount];
    [msg appendFormat:@" efc(%zd) pfc(%zd)\n",i.encodeFrameCount, i.pushFrameCount];
    [msg appendFormat:@"%0.2ffps %0.2fKB/s %0.2fKB/s\n", i.fps,i.encodeSpeed, i.speed/1024];
    [msg appendFormat:@"%lluB pushSize(%lluB) status(%zd)",i.localBufferSize, i.pushSize, i.connectStatus];
    [msg appendFormat:@" %0.2fms\n",i.localDelay];
    [msg appendFormat:@"video_pts:%zd\naudio_pts:%zd\n", i.currentVideoPTS,i.currentAudioPTS];
    [msg appendFormat:@"fps:%f\n", i.fps];
    
    detailStr = msg;
}


#pragma mark - 手势
- (void)addGesture {
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.view addGestureRecognizer:gesture];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.view addGestureRecognizer:pinch];
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleSwipe:)];
    [self.view addGestureRecognizer:recognizer];
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:self.view];
    CGPoint percentPoint = CGPointZero;
    percentPoint.x = point.x / CGRectGetWidth(self.view.bounds);
    percentPoint.y = point.y / CGRectGetHeight(self.view.bounds);
    [self.liveSession alivcLiveVideoFocusAtAdjustedPoint:percentPoint autoFocus:YES];
    
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gesture {
    
    if (_currentPosition == AVCaptureDevicePositionFront) {
        return;
    }
    
    if (gesture.numberOfTouches != 2) {
        return;
    }
    CGPoint p1 = [gesture locationOfTouch:0 inView:self.view];
    CGPoint p2 = [gesture locationOfTouch:1 inView:self.view];
    CGFloat dx = (p2.x - p1.x);
    CGFloat dy = (p2.y - p1.y);
    CGFloat dist = sqrt(dx*dx + dy*dy);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _lastPinchDistance = dist;
    }
    
    CGFloat change = dist - _lastPinchDistance;
    [self.liveSession alivcLiveVideoZoomCamera:(change / 1000 )];

}

- (void)handleSwipe:(UIPanGestureRecognizer *)swipe {
 
    if (swipe.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [swipe translationInView:self.view];
        CGFloat absX = fabs(translation.x);
        CGFloat absY = fabs(translation.y);
        
        if (MAX(absX, absY) < 10) {
            return;
        }
        if (absY > absX) {
            if (translation.y<0) {
                self.exposureValue += 0.01;
                [self.liveSession alivcLiveVideoChangeExposureValue:self.exposureValue];
                
            }else{
                self.exposureValue -= 0.01;
                [self.liveSession alivcLiveVideoChangeExposureValue:self.exposureValue];
            }
        }
    }
}


#pragma mark - Notification
- (void)appResignActive{
    
    // 退入后台停止推流 因为iOS后台机制，不能满足充分的摄像头采集和GPU渲染
    [self destroySession];
    
    // 监听电话
    _callCenter = [[CTCallCenter alloc] init];
    _isCTCallStateDisconnected = NO;
    _callCenter.callEventHandler = ^(CTCall* call) {
        if ([call.callState isEqualToString:CTCallStateDisconnected])
        {
            _isCTCallStateDisconnected = YES;
        }
        else if([call.callState isEqualToString:CTCallStateConnected])
            
        {
            _callCenter = nil;
        }
    };
    
    NSLog(@"退入后台");
    
}

- (void)appBecomeActive{
    
    if (_isCTCallStateDisconnected) {
        sleep(2);
    }
    // 回到前台重新推流
    [self createSession];
    
    NSLog(@"回到前台");
}

#pragma mark - Actions

- (void)actionShowMore:(id)sender {
    if (!controlView) {
        controlView = [[LPlivePlayingControlView alloc]initWithFrame:CGRectMake(0, 0, kNMDeviceWidth, kNMDeviceHeight)];
        controlView.delegate = self;
        [self.view addSubview:controlView];
        [controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.top.equalTo(self.view.mas_top);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    }
    controlView.hidden = NO;
}



- (void)buttonCloseClick:(id)sender {
    __weak typeof(self) weakSelf = self;
    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:nil message:@"\n确定要退出当前直播吗？\n"];
    [alert bk_addButtonWithTitle:@"确定"
                         handler:^{
                             [weakSelf destroySession];
                             [_pushTimer invalidate];
                             _pushTimer = nil;
                             
                             AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];    appDelegate.allowRotation = NO;
                             NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                             [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
                             
                             [weakSelf.navigationController popViewControllerAnimated:YES];
                       }];
    [alert bk_setCancelButtonWithTitle:@"取消"
                               handler:^{
                               }];
    [alert show];
//    BOOL isHave = 0;
//    for (UIViewController * vc in arr) {
//        if ([vc isKindOfClass:[LPbeginPlayingVC class]]) {
//            [self.navigationController popViewControllerAnimated:YES];
//            isHave = YES;
//        }
//    }
//    if (!isHave && arr.count) {
//        LPbeginPlayingVC *login = [[LPbeginPlayingVC alloc] init];
//        UINavigationController * nav =[[UINavigationController alloc]initWithRootViewController:login];
//        //    self.window.rootViewController = nav;
//        [[UIApplication sharedApplication].keyWindow setRootViewController:nav];
//    }else{
//        if (!arr.count) {
//            [self dismissViewControllerAnimated:YES completion:nil];
//        } else {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cameraButtonClick:(UIButton *)button {
    
    if (self.currentPosition == AVCaptureDevicePositionBack) {
        self.liveSession.devicePosition = AVCaptureDevicePositionFront;
    }else{
        self.liveSession.devicePosition = AVCaptureDevicePositionBack;
    }
    self.currentPosition = self.liveSession.devicePosition;
    
//    self.liveSession.devicePosition = button.isSelected ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
//    self.currentPosition = self.liveSession.devicePosition;
}

- (void)skinButtonClick:(UIButton *)button {
    isBeauty= !isBeauty;
    [self.liveSession setEnableSkin:isBeauty];
}

- (void)skinSliderAction:(UISlider *)sender {
    [self.liveSession alivcLiveVideoChangeSkinValue:sender.value];
}


- (void)flashButtonClick:(UIButton *)button {
    if (_currentPosition == AVCaptureDevicePositionBack ) {
        isLight = ! isLight;
        self.liveSession.torchMode = isLight? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    }
}

- (void)muteButton:(UIButton *)sender {
    isMutePush = !isMutePush;
    self.liveSession.enableMute = isMutePush;
    if(isMutePush){
        _imgConnect.image = [UIImage imageNamed:@"m_mute"];
        _imgConnect.hidden = NO;
    }else{
        _imgConnect.hidden = YES;
    }
    if (!isPushing) {
        _imgConnect.image = [UIImage imageNamed:@"m_connect"];
        _imgConnect.hidden = NO;
    }
        
}

- (void)disconnectButtonClick:(UIButton *)sender {
    [self actionBtnChangeStatus:sender];
    if (self.liveSession.dumpDebugInfo.connectStatus == AlivcLConnectStatusNone) {
        [self.liveSession alivcLiveVideoConnectServer];
    }else{
        [self.liveSession alivcLiveVideoDisconnectServer];
    }
}

-(void)actionBtnChangeStatus:(UIButton *)sender{
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    sender.selected = !sender.selected;
    if (sender.selected) {
        sender.backgroundColor = [UIColor blueColor];
    }else{
        sender.backgroundColor = [UIColor clearColor];
    }
    if ([sender isEqual:_btnCutOut]) {
        _btnCutOut.hidden = sender.selected;
        _imgConnect.hidden = sender.selected;
        _imgConnect.image =[UIImage imageNamed:@"m_connect"];
    }
}

////旋转屏幕
- (void)actionRotateBackView:(UIButton *)sender {
    [self actionBtnChangeStatus:sender];
    if (sender.selected) {
        [self handleDeviceOrientationChange:nil];
    }else{
    }
}

- (void)handleDeviceOrientationChange:(NSNotification *)notification{
    if (!_isScreenHorizontal) {
        return;
    }
    
    //宣告一個UIDevice指標，並取得目前Device的狀況
    UIDevice *device = [UIDevice currentDevice] ;
    //取得當前Device的方向，來當作判斷敘述。（Device的方向型態為Integer）
    static CGFloat angle = 0;
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"螢幕朝上平躺");
            break;
            
        case UIDeviceOrientationFaceDown:
            NSLog(@"螢幕朝下平躺");
            break;
            
            //系統無法判斷目前Device的方向，有可能是斜置
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"螢幕向左橫置");
            angle = M_PI/2;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"螢幕向右橫置");
            angle = -M_PI/2;
            break;
            
        case UIDeviceOrientationPortrait:
            NSLog(@"螢幕直立");
            angle = 0;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"螢幕直立，上下顛倒");
            angle = -M_PI;
            break;
            
        default:
            NSLog(@"無法辨識");
            break;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
//    NSLog(@"旋转前 %f，%f",kNMDeviceHeight,kNMDeviceWidth);
//    CGAffineTransform spin = CGAffineTransformMakeRotation(angle);
//    if(angle == -M_PI/2 ){
//        _viewBtnBack.frame =CGRectMake(0, 0, kNMDeviceHeight,kNMDeviceWidth);
//    }else if(angle == M_PI/2){
//        _viewBtnBack.frame =CGRectMake(0, 0, kNMDeviceHeight,kNMDeviceWidth);
//    }else{
//        _viewBtnBack.frame =CGRectMake(0, 0, kNMDeviceWidth, kNMDeviceHeight);
//    }
//    
//    [_viewBtnBack setTransform:spin];
//    NSLog(@"旋转后 %f，%f",kNMDeviceHeight,kNMDeviceWidth);
    
//    [self loadBtnView];
    
//    [_viewBtnBack setNeedsLayout];
//    [_viewBtnBack setNeedsLayout];
//    [_viewBtnBack layoutSubviews];
//    //添加y方向约束
//    NSLayoutConstraint *picTop = [NSLayoutConstraint constraintWithItem:_labDetail attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_viewBtnBack attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10];
//    picTop.active = YES;
}


    
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
