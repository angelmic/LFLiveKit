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
        [self addSubview:_headImageView];
    }
    return _eyesImageView;
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

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGFloat faceH = frame.size.height;
    CGFloat faceW = frame.size.width;
    
    // eyes
    if (_eyesImage != nil) {
        CGFloat eyesX = 0.0;
        CGFloat eyesY = faceH * 0.2;
        CGFloat eyesH = faceH * 0.2;
        CGFloat eyesW = faceW;
        
        self.eyesImageView.frame = CGRectMake(eyesX, eyesY, eyesW, eyesH);
    }
}

@end
