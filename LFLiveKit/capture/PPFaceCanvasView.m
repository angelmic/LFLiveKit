//
//  PPFaceCanvasView.m
//  Pods
//
//  Created by richard on 2017/3/20.
//
//

#import "PPFaceCanvasView.h"

@interface PPFaceCanvasView ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UIImageView *eyesImageView;
@property (nonatomic, strong) UIImageView *faceImageView;

@end

@implementation PPFaceCanvasView

#pragma mark - Getter
- (UIImageView *)headImageView
{
    if (_headImageView == nil) {
        _headImageView = [UIImageView new];
        [self addSubview:_headImageView];
    }
    return _headImageView;
}

- (UIImageView *)eyesImageView
{
    if (_eyesImageView == nil) {
        _eyesImageView = [UIImageView new];
        [self addSubview:_eyesImageView];
    }
    return _eyesImageView;
}

- (UIImageView *)faceImageView
{
    if (_faceImageView == nil) {
        _faceImageView = [UIImageView new];
        [self addSubview:_faceImageView];
        [self sendSubviewToBack:_faceImageView];
    }
    return _faceImageView;
}

#pragma mark - Setter
- (void)setHeadImage:(UIImage *)headImage
{
    if (_headImage != headImage) {
        _headImage = headImage;
        self.headImageView.image = _headImage;
    }
}

- (void)setEyesImage:(UIImage *)eyesImage
{
    if (_eyesImage != eyesImage) {
        _eyesImage = eyesImage;
        self.eyesImageView.image = _eyesImage;
    }
}

- (void)setFaceImage:(UIImage *)faceImage
{
    if (_faceImage != faceImage) {
        _faceImage = faceImage;
        self.faceImageView.image = _faceImage;
    }
}

#pragma mark - Update
- (void)updateMaskWithAngle:(CGFloat)angle
{
    CGFloat faceH = self.frame.size.height;
    CGFloat faceW = self.frame.size.width;
    
    //self.eyesImageView.transform = CGAffineTransformIdentity;
    
    // face
    if (_faceImage != nil) {
        self.faceImageView.transform = CGAffineTransformIdentity;
        CGFloat X = - faceW * 0.3;
        CGFloat Y = - faceH * 0.2;
        CGFloat W = faceW * 1.6;
        CGFloat H = faceH * 1.5;
        
        self.faceImageView.frame = CGRectMake(X, Y, W, H);
        self.faceImageView.transform = CGAffineTransformMakeRotation(M_PI * angle / 180.0);
    }
    
    // eyes
    if (_eyesImage != nil) {
        self.eyesImageView.transform = CGAffineTransformIdentity;
        CGFloat eyesX = 0.0;
        CGFloat eyesY = faceH * 0.15;
        CGFloat eyesH = faceH * 0.3;
        CGFloat eyesW = faceW;
        
        self.eyesImageView.frame = CGRectMake(eyesX, eyesY, eyesW, eyesH);
        
        self.eyesImageView.transform = CGAffineTransformMakeRotation(M_PI * angle / 180.0);
    }
    
    //self.eyesImageView.transform = CGAffineTransformMakeRotation(M_PI * angle / 180.0);
}

@end
