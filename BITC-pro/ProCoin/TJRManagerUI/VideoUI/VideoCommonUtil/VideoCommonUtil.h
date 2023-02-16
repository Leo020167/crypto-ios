//
//  VideoCommonUtil.h
//  Redz
//
//  Created by Hay on 2018/11/14.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoCommonUtil : NSObject

/**
 @brief 传入视频数据保存在指定文件夹下
 @param asset : 视频资源
 @param presetName : AVAssetExportPreset640x480
 @param success : block fileName-返回一个已经保存在固定位置的文件名，在上传函数中会自动拼接  fullOutputPath-完整文件路径
 */
+ (void)getVideoOutputPathWithAsset:(PHAsset *)asset presetName:(NSString *)presetName success:(void (^)(NSString *fileName,NSString *fullOutputPath))success failure:(void (^)(NSString *errorMessage, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
