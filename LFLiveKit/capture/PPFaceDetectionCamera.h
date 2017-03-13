//
//  PPFaceDetectionCamera.h
//  Pods
//
//  Created by richard on 2017/3/10.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GPUImageStillCamera.h"

typedef NS_OPTIONS(NSUInteger, PPFaceDetectionOptions) {
    /**
     *  This will output CIFaceFeatures using a CIDetector.
     */
    kFaceFeatures               = 1 << 0,
    
    /**
     *  This will output AVMetadataFaceObjects using AVCaptureMetadataOutput
     */
    kFaceMetaData               = 1 << 1,
    
    /**
     *  This will output AVMetadataMachineReadableCodeObjects using AVCaptureMetadataOutput
     */
    kMachineReadableMetaData    = 1 << 2,
    
    /**
     *  This will allow you to output both kMachineReadableMetaData and kFaceMetaData
     */
    kMachineAndFaceMetaData     = 1 << 3
};

#pragma mark - PPFaceDetectionDelegate
@protocol PPFaceDetectionDelegate <NSObject>

@optional
/**
 *  Callback for kFaceFeatures option.
 *
 *  @param faceFeatureObjects           Array containing CIFaceFeature objects, or empty array if none detected.
 *  @param clap                         Use in conjunction with current device orientation to translate CIFaceFeatures to bounds in view being displayed to user.
 *
 *                                      See GPUImage's Filter Showcase or Apple's SquareCamDemo for examples of this.
 */
- (void)detectorWillOutputFaceFeatures:(NSArray *)faceFeatureObjects inClap:(CGRect)clap;

/**
 *  Callback for kFaceMetadata option
 *
 *  @param faceMetadataObjects          Array containing face metadata objects, or empty array if none detected.
 */
- (void)detectorWillOutputFaceMetadata:(NSArray *)faceMetadataObjects;

/**
 *  Callback for kMachineReadableMetaData option
 *
 *  @param machineReadableMetadataObjects          Array containing machine readable metadata objects, or empty array if none detected.
 */
- (void)detectorWillOutputMachineReadableMetadata:(NSArray *)machineReadableMetadataObjects;

/**
 *  Callback for kMachineReadableMetaData option
 *
 *  @param mixedMetadataObjects                    Array containing mixed AVMetadataObjects both face and machine readable, or empty array if none detected.
 */
- (void)detectorWillOutputMachineAndFaceMetadata:(NSArray *)mixedMetadataObjects;

@end

#pragma mark - PPFaceDetectionBlock
/**
 *  If you prefer blocks over delegates, this is the block you will need to implement.
 *
 *  @param detectionType                This will signify the type of object stored in the detectedObjects array.
 *  @param detectedObjects              Objects detected, or empty array signifying no detection was possible.
 *  @param clapOrRectZero               Clap will only be returned for kFaceFeatures, use in conjunction with current device orientation to translate CIFaceFeatures
 *                                      to bounds in view being displayed to user. See GPUImage's Filter Showcase or Apple's SquareCamDemo for examples of this.
 *                                      Will otherwise be CGRectZero.
 *
 */
typedef void (^PPFaceDetectionBlock)(PPFaceDetectionOptions detectionType, NSArray *detectedObjects, CGRect clapOrRectZero);

#pragma mark - PPFaceDetectionCamera
@interface PPFaceDetectionCamera : GPUImageStillCamera

/**
 *  After initializing as you would a GPUImageVideoCamera or GPUImageStillCamera, call this method to begin detection
 *
 *  @param options               Types of objects to detect, can be used as joined or of options, ie: kFaceFeatures | kFaceMetaData will detect both
 *                               features and metadata.
 *
 *  @param delegate              Delegate interested in receiving features as they are output
 *  @param machineCodeTypesOrNil For kMachineReadableMetaData, you must supply a type of machine code to detect ie: AVMetadataObjectTypeQRCode
 *
 *  All possible values for machineCodeTypesOrNil are defined here: https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVMetadataMachineReadableCodeObject_Class/Reference/Reference.html
 */
- (void)beginDetecting:(PPFaceDetectionOptions)options withDelegate:(id<PPFaceDetectionDelegate>)delegate codeTypes:(NSArray *)machineCodeTypesOrNil;

/**
 *  After initializing as you would a GPUImageVideoCamera or GPUImageStillCamera, call this method to begin detection
 *
 *  @param options               Types of objects to detect, can be used as joined or of options, ie: kFaceFeatures | kFaceMetaData will detect both
 *                               features and metadata.
 *
 *  @param delegate              Delegate interested in receiving features as they are output
 *  @param machineCodeTypesOrNil For kMachineReadableMetaData, you must supply a type of machine code to detect ie: AVMetadataObjectTypeQRCode
 *
 *  All possible values for machineCodeTypesOrNil are defined here: https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVMetadataMachineReadableCodeObject_Class/Reference/Reference.html
 */

- (void)beginDetecting:(PPFaceDetectionOptions)options codeTypes:(NSArray *)machineCodeTypesOrNil withDetectionBlock:(PPFaceDetectionBlock)detectionBlock;

/**
 *  Turn off specific detection types.
 *
 *  @param options               SMKDetectionOptions object/s, can be used as joined or of options, ie: kFaceFeatures | kFaceMetaData will turn off both.
 */
- (void)stopDetectionOnType:(PPFaceDetectionOptions)options;

/**
 *  Will stop all forms of detection, but will not stop camera capture, to stop camera capture, use usual GPUImageVideoCamera methods.
 */
- (void)stopAllDetection;

@end
