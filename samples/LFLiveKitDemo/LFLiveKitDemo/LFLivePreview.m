//
//  LFLivePreview.m
//  LFLiveKit
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 live Interactive. All rights reserved.
//

#import "LFLivePreview.h"
#import "UIControl+YYAdd.h"
#import "UIView+YYAdd.h"
#import "LFLiveKit.h"

inline static NSString *formatedSpeed(float bytes, float elapsed_milli) {
    if (elapsed_milli <= 0) {
        return @"N/A";
    }

    if (bytes <= 0) {
        return @"0 KB/s";
    }

    float bytes_per_sec = ((float)bytes) * 1000.f /  elapsed_milli;
    if (bytes_per_sec >= 1000 * 1000) {
        return [NSString stringWithFormat:@"%.2f MB/s", ((float)bytes_per_sec) / 1000 / 1000];
    } else if (bytes_per_sec >= 1000) {
        return [NSString stringWithFormat:@"%.1f KB/s", ((float)bytes_per_sec) / 1000];
    } else {
        return [NSString stringWithFormat:@"%ld B/s", (long)bytes_per_sec];
    }
}

@interface LFLivePreview ()<LFLiveSessionDelegate>

@property (nonatomic, strong) UIButton *faceDetectionButton;
@property (nonatomic, strong) UIButton *beautyButton;
@property (nonatomic, strong) UIButton *maskButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *startLiveButton;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) LFLiveDebug   *debugInfo;
@property (nonatomic, strong) LFLiveSession *session;

@property (nonatomic, strong) UILabel *stateLabel;

@end

@implementation LFLivePreview

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self requestAccessForVideo];
        [self requestAccessForAudio];
        [self addSubview:self.containerView];
        [self.containerView addSubview:self.stateLabel];
        [self.containerView addSubview:self.closeButton];
        [self.containerView addSubview:self.cameraButton];
        [self.containerView addSubview:self.beautyButton];
        [self.containerView addSubview:self.faceDetectionButton];
        [self.containerView addSubview:self.maskButton];
        [self.containerView addSubview:self.startLiveButton];
    }
    return self;
}

#pragma mark -- Public Method
- (void)requestAccessForVideo
{
    __weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
    case AVAuthorizationStatusNotDetermined: {
        // 许可对话没有出现，发起授权许可
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_self.session setRunning:YES];
                    });
                }
            }];
        break;
    }
    case AVAuthorizationStatusAuthorized: {
        // 已经开启授权，可继续
        dispatch_async(dispatch_get_main_queue(), ^{
            [_self.session setRunning:YES];
        });
        break;
    }
    case AVAuthorizationStatusDenied:
    case AVAuthorizationStatusRestricted:
        // 用户明确地拒绝授权，或者相机设备无法访问

        break;
    default:
        break;
    }
}

- (void)requestAccessForAudio
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
            
        }
            break;
            
    case AVAuthorizationStatusAuthorized:
        {
            
        }
            break;
            
    case AVAuthorizationStatusDenied:
    case AVAuthorizationStatusRestricted:
        break;
            
    default:
        break;
    }
}

#pragma mark -- LFStreamingSessionDelegate
/** live status changed will callback */
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state
{
    NSLog(@"liveStateDidChange: %ld", (unsigned long)state);
    switch (state) {
    case LFLiveReady:
        _stateLabel.text = @"未連接";
        break;
    case LFLivePending:
        _stateLabel.text = @"連線中";
        break;
    case LFLiveStart:
        _stateLabel.text = @"已連接";
        break;
    case LFLiveError:
        _stateLabel.text = @"連接錯誤";
        break;
    case LFLiveStop:
        _stateLabel.text = @"未連接";
        break;
    default:
        break;
    }
}

/** live debug info callback */
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo
{
    NSLog(@"debugInfo uploadSpeed: %@", formatedSpeed(debugInfo.currentBandwidth, debugInfo.elapsedMilli));
}

/** callback socket errorcode */
- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode
{
    NSLog(@"errorCode: %ld", (unsigned long)errorCode);
}

#pragma mark -- Getter Setter
- (LFLiveSession *)session
{
    if (!_session) {
        /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/
        /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/
        /**      发现大家有不会用横屏的请注意啦，横屏需要在ViewController  supportedInterfaceOrientations修改方向  默认竖屏  ****/


        /***   默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏 ***/
        
        
        LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
        videoConfiguration.videoSize                = CGSizeMake(540, 960);
        videoConfiguration.videoBitRate             = 800*1024;
        videoConfiguration.videoMaxBitRate          = 1000*1024;
        videoConfiguration.videoMinBitRate          = 500*1024;
        videoConfiguration.videoFrameRate           = 24;
        videoConfiguration.videoMaxKeyframeInterval = 48;
        videoConfiguration.outputImageOrientation   = UIInterfaceOrientationPortrait;
        videoConfiguration.autorotate               = NO;
        videoConfiguration.sessionPreset            = LFCaptureSessionPreset540x960;
        
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:videoConfiguration captureType:LFLiveCaptureDefaultMask];
         
       // _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_High2]];

        /**    自己定制单声道  */
        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 1;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_64Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
         */

        /**    自己定制高质量音频96K */
        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
         */

        /**    自己定制高质量音频96K 分辨率设置为540*960 方向竖屏 */

        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;

           LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(540, 960);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 24;
           videoConfiguration.videoMaxKeyframeInterval = 48;
           videoConfiguration.orientation = UIInterfaceOrientationPortrait;
           videoConfiguration.sessionPreset = LFCaptureSessionPreset540x960;

           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */


        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向竖屏 */

        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;

           LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(720, 1280);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 15;
           videoConfiguration.videoMaxKeyframeInterval = 30;
           videoConfiguration.landscape = NO;
           videoConfiguration.sessionPreset = LFCaptureSessionPreset360x640;

           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */


        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向横屏  */

        /*
           LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
           audioConfiguration.numberOfChannels = 2;
           audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
           audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;

           LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
           videoConfiguration.videoSize = CGSizeMake(1280, 720);
           videoConfiguration.videoBitRate = 800*1024;
           videoConfiguration.videoMaxBitRate = 1000*1024;
           videoConfiguration.videoMinBitRate = 500*1024;
           videoConfiguration.videoFrameRate = 15;
           videoConfiguration.videoMaxKeyframeInterval = 30;
           videoConfiguration.landscape = YES;
           videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;

           _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
        */

        _session.delegate      = self;
        _session.showDebugInfo = YES;
        _session.preView       = self;
        _session.muted         = YES;
        _session.faceTracking  = YES;
        
        /*本地存储*/
//        _session.saveLocalVideo = YES;
//        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
//        unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//        _session.saveLocalVideoPath = movieURL;
        
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.alpha = 1.0;
        imageView.frame = CGRectMake(10, 64, 100, 100);
        imageView.image = [UIImage imageNamed:@"pi"];
        _session.warterMarkView = imageView;
        
        
        //[_session setCaptureDevicePosition:AVCaptureDevicePositionBack];
    }
    return _session;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.frame = self.bounds;
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _containerView;
}

- (UILabel *)stateLabel
{
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 80, 40)];
        _stateLabel.text = @"未連接";
        _stateLabel.textColor = [UIColor whiteColor];
        _stateLabel.font = [UIFont boldSystemFontOfSize:14.f];
    }
    return _stateLabel;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton      = [UIButton new];
        _closeButton.size = CGSizeMake(44, 44);
        _closeButton.left = self.width - 10 - _closeButton.width;
        _closeButton.top  = 20;
        
        [_closeButton setImage:[UIImage imageNamed:@"close_preview"] forState:UIControlStateNormal];
        
        _closeButton.exclusiveTouch = YES;
        
        [_closeButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {

        }];
    }
    return _closeButton;
}

- (UIButton *)cameraButton
{
    if (!_cameraButton) {
        _cameraButton        = [UIButton new];
        _cameraButton.size   = CGSizeMake(44, 44);
        _cameraButton.origin = CGPointMake(_closeButton.left - 10 - _cameraButton.width, 20);
        
        [_cameraButton setImage:[UIImage imageNamed:@"camra_preview"] forState:UIControlStateNormal];
        
        _cameraButton.exclusiveTouch = YES;
        
        __weak typeof(self) _self = self;
        [_cameraButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            AVCaptureDevicePosition devicePositon = _self.session.captureDevicePosition;
            _self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
        }];
    }
    return _cameraButton;
}

- (UIButton *)beautyButton
{
    if (!_beautyButton) {
        _beautyButton        = [UIButton new];
        _beautyButton.size   = CGSizeMake(44, 44);
        _beautyButton.origin = CGPointMake(_cameraButton.left - 10 - _beautyButton.width, 20);
        
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty"] forState:UIControlStateNormal];
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty_close"] forState:UIControlStateSelected];
        
        _beautyButton.exclusiveTouch = YES;
        
        __weak typeof(self) _self = self;
        [_beautyButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            _self.session.beautyFace    = !_self.session.beautyFace;
            _self.beautyButton.selected = !_self.session.beautyFace;
            
        }];
    }
    return _beautyButton;
}

- (UIButton *)faceDetectionButton
{
    if (!_faceDetectionButton) {
        _faceDetectionButton = [UIButton new];
        _faceDetectionButton.size = CGSizeMake(44, 44);
        _faceDetectionButton.origin = CGPointMake(_beautyButton.left - 10 - _faceDetectionButton.width, 20);
        
        [_faceDetectionButton setImage:[UIImage imageNamed:@"face_detection"] forState:UIControlStateNormal];
        [_faceDetectionButton setImage:[UIImage imageNamed:@"face_detection_close"] forState:UIControlStateSelected];
        
        _faceDetectionButton.exclusiveTouch = YES;
        
        __weak typeof(self) _self = self;
        [_faceDetectionButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            _self.session.faceTracking         = !_self.session.faceTracking;
            _self.faceDetectionButton.selected = !_self.session.faceTracking;
            
        }];
    }
    
    return _faceDetectionButton;
}

- (UIButton *)maskButton
{
    if (!_maskButton) {
        _maskButton        = [UIButton new];
        _maskButton.size   = CGSizeMake(44, 44);
        _maskButton.origin = CGPointMake(_faceDetectionButton.left - 10 - _maskButton.width, 20);
        
        [_maskButton setImage:[UIImage imageNamed:@"mask_00"] forState:UIControlStateNormal];
        
        _maskButton.exclusiveTouch = YES;
        
        __weak typeof(self) _self = self;
        NSInteger __block seleted = 0;
        [_maskButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            seleted++;
            
            switch (seleted % 4) {
                case 0:
                    seleted = 0;
                    _self.session.eyesMaskImage = nil;
                    _self.session.faceMaskImage = nil;
                    [_self.maskButton setImage:[UIImage imageNamed:@"mask_00"] forState:UIControlStateNormal];
                    break;
                    
                case 1:
                    seleted = 1;
                    _self.session.eyesMaskImage = [UIImage imageNamed:@"ti"];
                    _self.session.faceMaskImage = nil;
                    [_self.maskButton setImage:[UIImage imageNamed:@"mask_01"] forState:UIControlStateNormal];
                    break;
                    
                case 2:
                    seleted = 2;
                    _self.session.faceMaskImage = [UIImage imageNamed:@"hacker"];
                    _self.session.eyesMaskImage = nil;
                    [_self.maskButton setImage:[UIImage imageNamed:@"mask_02"] forState:UIControlStateNormal];
                    break;
                    
                case 3:
                    seleted = 3;
                    _self.session.eyesMaskImage = [UIImage imageNamed:@"allpay"];
                    _self.session.faceMaskImage = nil;
                    [_self.maskButton setImage:[UIImage imageNamed:@"mask_03"] forState:UIControlStateNormal];
                    break;
                    
                default:
                    break;
            }
            
        }];
    }
    return _maskButton;
}


- (UIButton *)startLiveButton
{
    if (!_startLiveButton) {
        _startLiveButton        = [UIButton new];
        _startLiveButton.size   = CGSizeMake(self.width - 60, 44);
        _startLiveButton.left   = 30;
        _startLiveButton.bottom = self.height - 50;
        
        _startLiveButton.layer.cornerRadius = _startLiveButton.height/2;
        
        [_startLiveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startLiveButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_startLiveButton setTitle:@"開始直播" forState:UIControlStateNormal];
        [_startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
        _startLiveButton.exclusiveTouch = YES;
        
        __weak typeof(self) _self = self;
        [_startLiveButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            _self.startLiveButton.selected = !_self.startLiveButton.selected;
            if (_self.startLiveButton.selected) {
                [_self.startLiveButton setTitle:@"結束直播" forState:UIControlStateNormal];
                LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
                stream.url = @"rtmp://live.hkstv.hk.lxdns.com:1935/live/stream168";
                [_self.session startLive:stream];
            } else {
                [_self.startLiveButton setTitle:@"開始直播" forState:UIControlStateNormal];
                [_self.session stopLive];
            }
        }];
    }
    return _startLiveButton;
}

@end

