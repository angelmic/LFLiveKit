//
//  PPFaceDetectionCameraPrivate.h
//  Pods
//
//  Created by richard on 2017/3/10.
//
//


#import "GPUImage.h"
#import "PPFaceDetectionCamera.h"

@interface PPFaceDetectionCamera ()

@property (weak) id<PPFaceDetectionDelegate> detectionDelegate;
@property (copy) PPFaceDetectionBlock        detectionBlock;

//Properties relating to kFaceFeatures
@property NSArray          *coreImageFaceFeatures;
@property CIDetector       *faceDetector;
@property CGRect           clap;
@property NSInteger        idleCount;
@property BOOL             processingInProgress;

//Properties relating to kFaceMetadata
@property AVCaptureMetadataOutput *faceOutput;

//Properties relating to kMachineReadableMetaData
@property AVCaptureMetadataOutput *machineReadableOutput;

//Properties relating to kMachineAndFaceMetaData
@property AVCaptureMetadataOutput *mixedOutput;

@end
