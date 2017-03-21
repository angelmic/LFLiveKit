//
//  PPFaceCanvasView.h
//  Pods
//
//  Created by richard on 2017/3/20.
//
//

#import <UIKit/UIKit.h>

@interface PPFaceCanvasView : UIView

@property (nonatomic, strong) UIImage *headImage;
@property (nonatomic, strong) UIImage *eyesImage;
@property (nonatomic, strong) UIImage *faceImage;

- (void)updateMaskWithAngle:(CGFloat)angle;

@end
