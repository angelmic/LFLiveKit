//
//  PPFaceDetectionCamera+MatadataHandler.m
//  Pods
//
//  Created by richard on 2017/3/10.
//
//

#import "PPFaceDetectionCamera+MatadataHandler.h"

@implementation PPFaceDetectionCamera (MetadataHandler)

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (captureOutput == self.faceOutput) {
        if ([self.detectionDelegate respondsToSelector:@selector(detectorWillOutputFaceMetadata:)]) {
            [self.detectionDelegate detectorWillOutputFaceMetadata:metadataObjects];
        }
    }
    
    if (captureOutput == self.machineReadableOutput) {
        if ([self.detectionDelegate respondsToSelector:@selector(detectorWillOutputMachineReadableMetadata:)]) {
            [self.detectionDelegate detectorWillOutputMachineAndFaceMetadata:metadataObjects];
        }
    }
    
    if (captureOutput == self.mixedOutput) {
        if ([self.detectionDelegate respondsToSelector:@selector(detectorWillOutputMachineAndFaceMetadata:)]) {
            [self.detectionDelegate detectorWillOutputMachineAndFaceMetadata:metadataObjects];
        }
    }
}

@end
