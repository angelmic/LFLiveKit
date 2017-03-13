//
//  PPFaceDetectionCamera.m
//  Pods
//
//  Created by richard on 2017/3/10.
//
//

#import "PPFaceDetectionCameraPrivate.h"
#import "PPFaceDetectionCamera+BufferHandler.h"
#import "PPFaceDetectionCamera+MatadataHandler.h"
#import "PPFaceDetectionCamera+BlockDelegate.h"
#import "GPUImage.h"

@implementation PPFaceDetectionCamera

- (void)beginDetecting:(PPFaceDetectionOptions)options withDelegate:(id<PPFaceDetectionDelegate>)delegate codeTypes:(NSArray *)machineCodeTypesOrNil
{
    [self __ensureStabilityOfOptionsViaAsserts:options withDelegate:delegate codeTypes:machineCodeTypesOrNil];
    
    self.detectionDelegate = delegate;
    
    if (options & kFaceFeatures) {
        self.delegate = self;
        
        NSDictionary *detectorOptions = @{
                                          CIDetectorAccuracy : CIDetectorAccuracyLow,
                                          };
        
        self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    } else {
        [self stopDetectionOnType:kFaceFeatures];
    }
    
    if (options & kFaceMetaData) {
        [self.captureSession removeOutput:self.faceOutput];
        
        self.faceOutput = [[AVCaptureMetadataOutput alloc] init];
        
        [self.faceOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.captureSession addOutput:self.faceOutput];
        [self.faceOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
    } else {
        [self stopDetectionOnType:kFaceMetaData];
    }
    
    if (options & kMachineReadableMetaData) {
        [self.captureSession removeOutput:self.machineReadableOutput];
        
        self.machineReadableOutput = [[AVCaptureMetadataOutput alloc] init];
        
        [self.machineReadableOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.captureSession addOutput:self.machineReadableOutput];
        [self.machineReadableOutput setMetadataObjectTypes:machineCodeTypesOrNil];
    } else {
        [self stopDetectionOnType:kMachineReadableMetaData];
    }
    
    if (options & kMachineAndFaceMetaData) {
        [self.captureSession removeOutput:self.mixedOutput];
        
        self.mixedOutput = [[AVCaptureMetadataOutput alloc] init];
        
        [self.mixedOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.captureSession addOutput:self.mixedOutput];
        [self.mixedOutput setMetadataObjectTypes:[machineCodeTypesOrNil arrayByAddingObject:AVMetadataObjectTypeFace]];
    } else {
        [self stopDetectionOnType:kMachineAndFaceMetaData];
    }
}

- (void)beginDetecting:(PPFaceDetectionOptions)options codeTypes:(NSArray *)machineCodeTypesOrNil withDetectionBlock:(PPFaceDetectionBlock)detectionBlock
{
    [self beginDetecting:options withDelegate:self codeTypes:machineCodeTypesOrNil];
    
    self.detectionBlock = detectionBlock;
}

- (void)stopDetectionOnType:(PPFaceDetectionOptions)options
{
    if (options & kFaceFeatures) {
        self.delegate = nil;
    }
    
    if (options & kFaceMetaData) {
        [self.captureSession removeOutput:self.faceOutput];
        self.faceOutput = nil;
    }
    
    if (options & kMachineReadableMetaData) {
        [self.captureSession removeOutput:self.machineReadableOutput];
        self.machineReadableOutput = nil;
    }
    
    if (options & kMachineAndFaceMetaData) {
        [self.captureSession removeOutput:self.mixedOutput];
        self.mixedOutput = nil;
    }
}

- (void)stopAllDetection
{
    [self stopDetectionOnType:kMachineReadableMetaData | kFaceMetaData | kFaceFeatures | kMachineAndFaceMetaData];
}

#pragma mark Asserts
- (void)__ensureStabilityOfOptionsViaAsserts:(PPFaceDetectionOptions)options withDelegate:(id<PPFaceDetectionDelegate>)delegate codeTypes:(NSArray *)machineCodeTypesOrNil
{
    
    NSAssert(!(options & kFaceMetaData && options & kMachineReadableMetaData),
             @"Do not use both kFaceMetaData && kMachineReadableMetaData, instead use kMachineAndFaceMetaData");
    NSAssert(!(options & kFaceMetaData && options & kMachineAndFaceMetaData),
             @"Do not use kFaceMetaData with kMachineAndFaceMetaData, just use kMachineAndFaceMetaData");
    NSAssert(!(options & kMachineAndFaceMetaData && options & kMachineReadableMetaData),
             @"Do not use kMachineReadableMetaData with kMachineAndFaceMetaData, just use kMachineAndFaceMetaData");
    
    if (options & kFaceMetaData) {
        NSAssert([delegate respondsToSelector:@selector(detectorWillOutputFaceMetadata:)],
                 @"Your detection delegate must respond to detectorWillOuputFaceMetadata: in order to detect kFaceMetadata");
    }
    
    if (options & kMachineReadableMetaData) {
        NSAssert([delegate respondsToSelector:@selector(detectorWillOutputMachineReadableMetadata:)],
                 @"Your detection delegate must respond to detectorWillOuputMachineReadableMetadata: in order to detect kMachineReadableMetaData");
        NSAssert(machineCodeTypesOrNil.count,
                 @"If you'd like to track machine codes, you need to supply an array of types to track");
    }
    
    if (options & kMachineAndFaceMetaData) {
        NSAssert([delegate respondsToSelector:@selector(detectorWillOutputMachineAndFaceMetadata:)],
                 @"Your detection delegate must respond to detectorWillOuputMachineAndFaceMetadata: in order to detect kMachineAndFaceMetaData");
        NSAssert(machineCodeTypesOrNil.count,
                 @"If you'd like to track machine codes, you need to supply an array of types to track");
    }
    
    if (options & kFaceFeatures) {
        NSAssert([delegate respondsToSelector:@selector(detectorWillOutputFaceFeatures:inClap:)],
                 @"Your detection delegate must respond to detectorWillOutputFaceFeatures:inClap: in order to detect kFaceFeatures");
    }
    
}

@end
