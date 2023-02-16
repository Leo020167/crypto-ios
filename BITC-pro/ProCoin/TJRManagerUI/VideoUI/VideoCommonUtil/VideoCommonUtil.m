//
//  VideoCommonUtil.m
//  Redz
//
//  Created by Hay on 2018/11/14.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import "VideoCommonUtil.h"
#import "CommonUtil.h"
#import "VeDateUtil.h"

@implementation VideoCommonUtil


/**
 @brief 传入视频数据保存在指定文件夹下
 */
+ (void)getVideoOutputPathWithAsset:(PHAsset *)asset presetName:(NSString *)presetName success:(void (^)(NSString *fileName,NSString *fullOutputPath))success failure:(void (^)(NSString *errorMessage, NSError *error))failure
{
    PHVideoRequestOptions* options = [[[PHVideoRequestOptions alloc] init] autorelease];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
        AVURLAsset *videoAsset = (AVURLAsset*)avasset;
        [VideoCommonUtil startExportVideoWithVideoAsset:videoAsset presetName:presetName success:success failure:failure];
    }];
}

+ (void)startExportVideoWithVideoAsset:(AVURLAsset *)videoAsset presetName:(NSString *)presetName success:(void (^)(NSString *outputPath,NSString *fullOutputPath))success failure:(void (^)(NSString *errorMessage, NSError *error))failure
{
    // Find compatible presets by video asset.
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];
    
    // Begin to compress video
    // Now we just compress to low resolution if it supports
    // If you need to upload to the server, but server does't support to upload by streaming,
    // You can compress the resolution to lower. Or you can support more higher resolution.
    if ([presets containsObject:presetName]) {
        AVAssetExportSession *session = [[[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:presetName] autorelease];
        
        
        NSString *fileName = @"";
        if (TTIsStringWithAnyText(ROOTCONTROLLER_USER.userId)) {
            fileName = [NSString stringWithFormat:@"%@_%@.mp4", [VeDateUtil currentDateTimeIntervalToString], ROOTCONTROLLER_USER.userId];
        }else{
            fileName = [NSString stringWithFormat:@"%@_output.mp4", [VeDateUtil currentDateTimeIntervalToString]];
        }
        // 文件存储路径
        NSString *outputPath = [CommonUtil TTPathForDocumentsResourceEtag:fileName];
        // NSLog(@"video outputPath = %@",outputPath);
        session.outputURL = [NSURL fileURLWithPath:outputPath];
        
        // Optimize for network use.
        session.shouldOptimizeForNetworkUse = true;
        
        NSArray *supportedTypeArray = session.supportedFileTypes;
        if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
            session.outputFileType = AVFileTypeMPEG4;
        } else if (supportedTypeArray.count == 0) {
            if (failure) {
                failure(@"该视频类型暂不支持导出", nil);
            }
            NSLog(@"No supported file types 视频类型暂不支持导出");
            return;
        } else {
            session.outputFileType = [supportedTypeArray objectAtIndex:0];
        }
        
        
        //暂时不需要修正转向
//        AVMutableVideoComposition *videoComposition = [self fixedCompositionWithAsset:videoAsset];
//        if (videoComposition.renderSize.width) {
//            // 修正视频转向
//            session.videoComposition = videoComposition;
//        }
        
        // Begin to export video to the output path asynchronously.
        [session exportAsynchronouslyWithCompletionHandler:^(void) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (session.status) {
                    case AVAssetExportSessionStatusUnknown: {
                        NSLog(@"AVAssetExportSessionStatusUnknown");
                    }  break;
                    case AVAssetExportSessionStatusWaiting: {
                        NSLog(@"AVAssetExportSessionStatusWaiting");
                    }  break;
                    case AVAssetExportSessionStatusExporting: {
                        NSLog(@"AVAssetExportSessionStatusExporting");
                    }  break;
                    case AVAssetExportSessionStatusCompleted: {
                        NSLog(@"AVAssetExportSessionStatusCompleted");
                        if (success) {
                            success(fileName,outputPath);
                        }
                    }  break;
                    case AVAssetExportSessionStatusFailed: {
                        NSLog(@"AVAssetExportSessionStatusFailed");
                        if (failure) {
                            failure(@"视频导出失败", session.error);
                        }
                    }  break;
                    case AVAssetExportSessionStatusCancelled: {
                        NSLog(@"AVAssetExportSessionStatusCancelled");
                        if (failure) {
                            failure(@"导出任务已被取消", nil);
                        }
                    }  break;
                    default: break;
                }
            });
        }];
    } else {
        if (failure) {
            NSString *errorMessage = [NSString stringWithFormat:@"当前设备不支持该预设:%@", presetName];
            failure(errorMessage, nil);
        }
    }
}

@end
