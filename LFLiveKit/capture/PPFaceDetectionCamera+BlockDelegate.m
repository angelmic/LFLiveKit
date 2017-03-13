//
//  PPFaceDetectionCamera+BlockDelegate.m
//  Pods
//
//  Created by richard on 2017/3/10.
//
//

#import "PPFaceDetectionCamera+BlockDelegate.h"
#import "PPFaceDetectionCameraPrivate.h"

@implementation PPFaceDetectionCamera (BlockDelegate)

- (void)detectorWillOutputFaceFeatures:(NSArray *)faceFeatureObjects inClap:(CGRect)clap
{
    self.detectionBlock(kFaceFeatures, faceFeatureObjects, clap);
}

- (void)detectorWillOutputFaceMetadata:(NSArray *)faceMetadataObjects
{
    self.detectionBlock(kFaceMetaData, faceMetadataObjects, CGRectZero);
}

- (void)detectorWillOutputMachineReadableMetadata:(NSArray *)machineReadableMetadataObjects
{
    self.detectionBlock(kMachineReadableMetaData, machineReadableMetadataObjects, CGRectZero);
}

- (void)detectorWillOutputMachineAndFaceMetadata:(NSArray *)mixedMetadataObjects
{
    self.detectionBlock(kMachineAndFaceMetaData, mixedMetadataObjects, CGRectZero);
}

@end
