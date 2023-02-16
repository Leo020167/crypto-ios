//
//  UIImage+Size.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-6.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HEAD_ICON_SIZE CGSizeMake(300, 300)

@interface UIImage (Size)
/**
 *    加模糊效果
 *    @param image 图片
 *    @param blur  模糊度
 *    @returns 图片
 */
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

/**
 *   压缩并保存图片
 *   @param image 原始图片
 *   @param userId 用户id
 *   @param thumbSize 压缩尺寸
 *   @returns 本地document下文件名
 */
+ (NSString *)createThumbImage:(UIImage *)image userId:(NSString *)userId size:(CGSize)thumbSize;

/**
 *   不压缩图片并保存图片
 *   @param image 原始图片
 *   @param userId 用户id
 *   @returns 本地document下文件名
 */
+ (NSString *)createOriginalImage:(UIImage *)image userId:(NSString *)userId;

/**
 *   压缩并保存图片
 *   @param image 原始图片
 *   @param userId 用户id
 *   @param thumbSize 压缩尺寸
 *   @param isSaveCacheData  是否保存到缓存里
 *   @returns 本地document下文件名
 */
+ (NSString *)createThumbImage:(UIImage *)image userId:(NSString *)userId size:(CGSize)thumbSize isSaveCacheData:(BOOL)isSaveCacheData;

/**
 *    压缩gif并保存图片
 *    @param data 原始gif数据
 *    @param userId 用户id
 *    @param thumbSize 压缩尺寸
 *    @param isSaveCacheData  是否保存到缓存里
 *    @returns 本地document下文件名
 */
+ (NSString *)createGifThumbImage:(NSData *)data userId:(NSString *)userId size:(CGSize)thumbSize isSaveCacheData:(BOOL)isSaveCacheData;

/**
 *    压缩并保存图片
 *    @param image 原始图片
 *    @returns 压缩后的图片
 */
+ (UIImage *)compressImage:(UIImage *)image;

/**
 *    压缩图片
 *    @param image 原始图片
 *    @param maxLength 压缩后最大的字节数
 *    @returns 压缩后的图片
 */
+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength;

// 获取动图时间
+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source;

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;
// 截图,全屏(不裁剪状态栏的20区域)
+ (UIImage *)screenShotNotCutByView:(UIView *)_view;
// 截图,全屏
+ (UIImage *)screenShotByView:(UIView *)_view;
// 截图，指定区域
+ (UIImage *)screenShotByView:(UIView *)_view inRect:(CGRect)_rect;
- (UIImage *)resizeImageWithCapInsets:(UIEdgeInsets)capInsets;

/**
 *  将字符串生成二维码
 *
 *  @param qrString 二维码字符串
 *  @param size     大小
 *
 *  @return 
 */
+ (UIImage *)createQRForString:(NSString *)qrString withSize:(CGFloat)size;

/**
 *  给图片加颜色
 *
 *  @param red   red description
 *  @param green green description
 *  @param blue  blue description
 *
 *  @return return value description
 */
- (UIImage*)imageBlackToTransparentWithRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end

