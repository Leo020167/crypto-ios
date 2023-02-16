//
//  UIImage+Size.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-6.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "UIImage+Size.h"
#import "CommonUtil.h"
#import "VeDateUtil.h"
#import "TTCacheManager.h"
#import "QuartzCore/QuartzCore.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Accelerate/Accelerate.h>

@implementation UIImage (Size)

/**
 *    加模糊效果
 *    @param image 图片
 *    @param blur  模糊度
 *    @returns 图片
 */
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
	// 模糊度,
	if ((blur < 0.1f)) {
		blur = 0.1f;
	}
    
    if ((blur > 2.0f)) {
        blur = 2.0f;
    }

	// boxSize必须大于0
	int boxSize = (int)(blur * 100);
	boxSize -= (boxSize % 2) + 1;
	// 图像处理
	CGImageRef img = image.CGImage;
	// 需要引入#import <Accelerate/Accelerate.h>

	/*
	 *   This document describes the Accelerate Framework, which contains C APIs for vector and matrix math, digital signal processing, large number handling, and image processing.
	 *   本文档介绍了Accelerate Framework，其中包含C语言应用程序接口（API）的向量和矩阵数学，数字信号处理，大量处理和图像处理。
	 */

	// 图像缓存,输入缓存，输出缓存
	vImage_Buffer inBuffer, outBuffer;
	vImage_Error error;
	// 像素缓存
	void *pixelBuffer;

	// 数据源提供者，Defines an opaque type that supplies Quartz with data.
	CGDataProviderRef inProvider = CGImageGetDataProvider(img);
	// provider’s data.
	CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);

	// 宽，高，字节/行，data
	inBuffer.width = CGImageGetWidth(img);
	inBuffer.height = CGImageGetHeight(img);
	inBuffer.rowBytes = CGImageGetBytesPerRow(img);
	inBuffer.data = (void *)CFDataGetBytePtr(inBitmapData);

	// 像数缓存，字节行*图片高
	pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));

	outBuffer.data = pixelBuffer;
	outBuffer.width = CGImageGetWidth(img);
	outBuffer.height = CGImageGetHeight(img);
	outBuffer.rowBytes = CGImageGetBytesPerRow(img);

	// 第三个中间的缓存区,抗锯齿的效果
	void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
	vImage_Buffer outBuffer2;
	outBuffer2.data = pixelBuffer2;
	outBuffer2.width = CGImageGetWidth(img);
	outBuffer2.height = CGImageGetHeight(img);
	outBuffer2.rowBytes = CGImageGetBytesPerRow(img);

	// Convolves a region of interest within an ARGB8888 source image by an implicit M x N kernel that has the effect of a box filter.
	error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
	error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
	error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);

	if (error) {
		NSLog(@"error from convolution %ld", error);
	}

	//    NSLog(@"字节组成部分：%zu",CGImageGetBitsPerComponent(img));
	// 颜色空间DeviceRGB
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	// 用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
	CGContextRef ctx = CGBitmapContextCreate(
		outBuffer.data,
		outBuffer.width,
		outBuffer.height,
		8,
		outBuffer.rowBytes,
		colorSpace,
		CGImageGetBitmapInfo(image.CGImage));

	// 根据上下文，处理过的图片，重新组件
	CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
	UIImage *returnImage = [UIImage imageWithCGImage:imageRef];

	// clean up
	CGContextRelease(ctx);
	CGColorSpaceRelease(colorSpace);

	free(pixelBuffer);
	free(pixelBuffer2);
	CFRelease(inBitmapData);

	CGColorSpaceRelease(colorSpace);
	CGImageRelease(imageRef);

	return returnImage;
}

// 毛玻璃效果

- (UIImage *)applyLightEffect {
	UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];

	return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyExtraLightEffect {
	UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];

	return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyDarkEffect {
	UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];

	return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor {
	const CGFloat EffectColorAlpha = 0.6;
	UIColor *effectColor = tintColor;
	unsigned long componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);

	if (componentCount == 2) {
		CGFloat b;

		if ([tintColor getWhite:&b alpha:NULL]) {
			effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
		}
	} else {
		CGFloat r, g, b;

		if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
			effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
		}
	}
	return [self applyBlurWithRadius:10 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage {
	// Check pre-conditions.
	if ((self.size.width < 1) || (self.size.height < 1)) {
		NSLog(@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
		return nil;
	}

	if (!self.CGImage) {
		NSLog(@"*** error: image must be backed by a CGImage: %@", self);
		return nil;
	}

	if (maskImage && !maskImage.CGImage) {
		NSLog(@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
		return nil;
	}

	CGRect imageRect = {CGPointZero, self.size};
	UIImage *effectImage = self;

	BOOL hasBlur = blurRadius > __FLT_EPSILON__;
	BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;

	if (hasBlur || hasSaturationChange) {
		UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
		CGContextRef effectInContext = UIGraphicsGetCurrentContext();
		CGContextScaleCTM(effectInContext, 1.0, -1.0);
		CGContextTranslateCTM(effectInContext, 0, -self.size.height);
		CGContextDrawImage(effectInContext, imageRect, self.CGImage);

		vImage_Buffer effectInBuffer;
		effectInBuffer.data = CGBitmapContextGetData(effectInContext);
		effectInBuffer.width = CGBitmapContextGetWidth(effectInContext);
		effectInBuffer.height = CGBitmapContextGetHeight(effectInContext);
		effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);

		UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
		CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
		vImage_Buffer effectOutBuffer;
		effectOutBuffer.data = CGBitmapContextGetData(effectOutContext);
		effectOutBuffer.width = CGBitmapContextGetWidth(effectOutContext);
		effectOutBuffer.height = CGBitmapContextGetHeight(effectOutContext);
		effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);

		if (hasBlur) {
			// A description of how to compute the box kernel width from the Gaussian
			// radius (aka standard deviation) appears in the SVG spec:
			// http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
			//
			// For larger values of 's' (s >= 2.0), an approximation can be used: Three
			// successive box-blurs build a piece-wise quadratic convolution kernel, which
			// approximates the Gaussian kernel to within roughly 3%.
			//
			// let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
			//
			// ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
			//
			CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
			uint32_t radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);

			if (radius % 2 != 1) {
				radius += 1;// force radius to be odd so that the three box-blur methodology works.
			}
			vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
			vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
			vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
		}
		BOOL effectImageBuffersAreSwapped = NO;

		if (hasSaturationChange) {
			CGFloat s = saturationDeltaFactor;
			CGFloat floatingPointSaturationMatrix[] = {
				0.0722 + 0.9278 * s, 0.0722 - 0.0722 * s, 0.0722 - 0.0722 * s, 0,
				0.7152 - 0.7152 * s, 0.7152 + 0.2848 * s, 0.7152 - 0.7152 * s, 0,
				0.2126 - 0.2126 * s, 0.2126 - 0.2126 * s, 0.2126 + 0.7873 * s, 0,
				0,					 0,					  0,				   1,
			};
			const int32_t divisor = 256;
			NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix) / sizeof(floatingPointSaturationMatrix[0]);
			int16_t saturationMatrix[matrixSize];

			for (NSUInteger i = 0; i < matrixSize; ++i) {
				saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
			}

			if (hasBlur) {
				vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
				effectImageBuffersAreSwapped = YES;
			} else {
				vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
			}
		}

		if (!effectImageBuffersAreSwapped) effectImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		if (effectImageBuffersAreSwapped) effectImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}

	// Set up output context.
	UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
	CGContextRef outputContext = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(outputContext, 1.0, -1.0);
	CGContextTranslateCTM(outputContext, 0, -self.size.height);

	// Draw base image.
	CGContextDrawImage(outputContext, imageRect, self.CGImage);

	// Draw effect image.
	if (hasBlur) {
		CGContextSaveGState(outputContext);

		if (maskImage) {
			CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
		}
		CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
		CGContextRestoreGState(outputContext);
	}

	// Add in color tint.
	if (tintColor) {
		CGContextSaveGState(outputContext);
		CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
		CGContextFillRect(outputContext, imageRect);
		CGContextRestoreGState(outputContext);
	}

	// Output image is ready.
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return outputImage;
}

/**
 *   压缩并保存图片(默认保存到缓存里)
 *   @param image 原始图片
 *   @param userId 用户id
 *   @param thumbSize 压缩尺寸
 *   @returns 本地document下文件名
 */
+ (NSString *)createThumbImage:(UIImage *)image userId:(NSString *)userId size:(CGSize)thumbSize {
	return [self createThumbImage:image userId:userId size:thumbSize isSaveCacheData:YES];
}


/**
 *   不压缩图片并保存图片
 *   @param image 原始图片
 *   @param userId 用户id
 *   @returns 本地document下文件名
 */
+ (NSString *)createOriginalImage:(UIImage *)image userId:(NSString *)userId{
    
    NSString *fileName = @"";// 文件名
    if (TTIsStringWithAnyText(userId)) {
        fileName = [NSString stringWithFormat:@"%@_%@.png", [VeDateUtil currentDateTimeIntervalToString], userId];
    }else{
        fileName = [NSString stringWithFormat:@"%@_reg.png", [VeDateUtil currentDateTimeIntervalToString]];
    }
    
    // 文件存储路径
    NSString* filePath = [CommonUtil TTPathForDocumentsResourceEtag:fileName];

    //重新生成新的图片
    UIGraphicsBeginImageContext(image.size);
    CGRect thumbRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:thumbRect];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage,1.0);
    
        // 写入文件
    [thumbImageData writeToFile:filePath atomically:NO];
    // 备份到缓存
    [TTCacheManager storeDataForUserImage:thumbImageData fileName:fileName];

    return fileName;


}

/**
 *    压缩并保存图片
 *    @param image 原始图片
 *    @param userId 用户id
 *    @param thumbSize 压缩尺寸
 *    @param isSaveCacheData  是否保存到缓存里
 *    @returns 本地document下文件名
 */
+ (NSString *)createThumbImage:(UIImage *)image userId:(NSString *)userId size:(CGSize)thumbSize isSaveCacheData:(BOOL)isSaveCacheData {
	NSString *fileName = @"";// 文件名
    
    if (TTIsStringWithAnyText(userId)) {
        fileName = [NSString stringWithFormat:@"%@_%@.png", [VeDateUtil currentDateTimeIntervalToString], userId];
    }else{
        fileName = [NSString stringWithFormat:@"%@_reg.png", [VeDateUtil currentDateTimeIntervalToString]];
    }
    
	// 文件存储路径
    NSString* filePath = [CommonUtil TTPathForDocumentsResourceEtag:fileName];
    
    //第一次按thumbSize压缩
	UIGraphicsBeginImageContext(thumbSize);
	CGRect thumbRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
	[image drawInRect:thumbRect];
	UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage,1.0);

    //当thumbImageData超过256K，再次进行压缩
    while (thumbImageData.length > 256000) {
        CGFloat compressionQuality = (float)256000 / thumbImageData.length;
        UIGraphicsBeginImageContext(thumbRect.size);
        [image drawInRect:thumbRect];
        thumbImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        thumbImageData = UIImageJPEGRepresentation(thumbImage, compressionQuality);
    }
    
    // 写入文件
	[thumbImageData writeToFile:filePath atomically:NO];

	// 备份到缓存
	if (thumbImageData && isSaveCacheData) {
		[TTCacheManager storeDataForUserImage:thumbImageData fileName:fileName];
	}

	return fileName;
}



// 获取动图时间
+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}


/**
 *    压缩gif并保存图片
 *    @param data 原始gif数据
 *    @param userId 用户id
 *    @param thumbSize 压缩尺寸
 *    @param isSaveCacheData  是否保存到缓存里
 *    @returns 本地document下文件名
 */
+ (NSString *)createGifThumbImage:(NSData *)data userId:(NSString *)userId size:(CGSize)thumbSize isSaveCacheData:(BOOL)isSaveCacheData {
    
    if (!data) {
        return nil;
    }
    NSString *fileName = @"";// 文件名
    
    if (TTIsStringWithAnyText(userId)) {
        fileName = [NSString stringWithFormat:@"%@_%@.gif", [VeDateUtil currentDateTimeIntervalToString], userId];
    }else{
        fileName = [NSString stringWithFormat:@"%@_reg.gif", [VeDateUtil currentDateTimeIntervalToString]];
    }

    // 文件存储路径
    NSString* filePath = [CommonUtil TTPathForDocumentsResourceEtag:fileName];

    [data writeToFile:filePath atomically:NO];
    
//     使用系统原生的方法将gif拆成image进行压缩，最后在合成gif（系统的方法多帧图片时GIF大小会很大，不能用）
//
//    NSDictionary *dic = [self getGifInfo:data];
//    NSMutableArray *imageArray = [NSMutableArray array];
//    [imageArray addObjectsFromArray:dic[@"images"]];
//    //对gif图的每一帧进行压缩
//    //如果图片过大就压缩，少于屏幕大小
//    CGRect phoneRectScreen = [[UIScreen mainScreen] bounds];
//
//    NSString *rectStr = dic[@"bounds"];
//    CGSize imageSize = CGRectFromString(rectStr).size;
//
//    //如果图片过大就压缩，少于屏幕大小
//    while (MAX(imageSize.width, imageSize.height) > phoneRectScreen.size.height || MIN(imageSize.width, imageSize.height) > phoneRectScreen.size.width) {
//        imageSize.width *= 0.9;
//        imageSize.height *= 0.9;
//
//        NSMutableArray *newImageArray = [NSMutableArray array];
//        for (UIImage *image in imageArray) {
//            UIGraphicsBeginImageContext(imageSize);
//            CGRect thumbRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
//            [image drawInRect:thumbRect];
//            UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
//            [newImageArray addObject:thumbImage];
//            UIGraphicsEndImageContext();
//        }
//        [imageArray removeAllObjects];
//        [imageArray addObjectsFromArray:newImageArray];
//    }
//
//    UIImage *firstImage = [imageArray firstObject];
//    NSData *firstImageData = UIImageJPEGRepresentation(firstImage, 1.0);
//    CGFloat compressionQuality = (float)128000 / firstImageData.length;
//
//    //当thumbImageData超过128K，再次进行压缩
//    while (firstImageData.length > 128000) {
//        NSMutableArray *newImageArray = [NSMutableArray array];
//        for (UIImage *image in imageArray) {
//            // 压缩图片
//            NSData *thumbImageData = UIImageJPEGRepresentation(image, compressionQuality);
//            [newImageArray addObject:[UIImage imageWithData:thumbImageData]];
//        }
//        [imageArray removeAllObjects];
//        [imageArray addObjectsFromArray:newImageArray];
//
//        firstImage = [imageArray firstObject];
//        firstImageData = UIImageJPEGRepresentation(firstImage, 1.0);
//        compressionQuality = (float)128000 / firstImageData.length;
//    }
//    // 将图片重新合成GIF，并写入文件
//    [self exportGifImages:[imageArray copy] delays:dic[@"delays"] loopCount:0 filePath:filePath];
//

    return fileName;
}

/*
 * @brief 指定每一帧播放时长把多张图片合成gif图,并写入本地 （当images过多，合成的gif过大）
 */
+ (NSString *)exportGifImages:(NSArray *)images delays:(NSArray *)delays loopCount:(NSUInteger)loopCount filePath:(NSString *)filePath
{

    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:filePath],kUTTypeGIF, images.count, NULL);
    if(!loopCount){
        loopCount = 0;
    }
    NSDictionary *gifProperties = @{ (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @(loopCount), // 0 means loop forever
                                             }
                                     };
    float delay = 0.1; //默认每一帧间隔0.1秒
    for (int i=0; i<images.count; i++) {
        UIImage *itemImage = images[i];
        if(delays && i<delays.count){
            delay = [delays[i] floatValue];
        }
        //每一帧对应的延迟时间
        NSDictionary *frameProperties = @{(__bridge id)kCGImagePropertyGIFDictionary: @{
                                                  (__bridge id)kCGImagePropertyGIFDelayTime: @(delay), // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                                  }
                                          };
        CGImageDestinationAddImage(destination,itemImage.CGImage, (__bridge CFDictionaryRef)frameProperties);
    }
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)gifProperties);
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to finalize image destination");
    }
    CFRelease(destination);
    return filePath;
}


/*
 * @brief 获取gif图中每一帧的信息
 */
+ (NSDictionary *)getGifInfo:(NSData *)data
{
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *delays = [NSMutableArray arrayWithCapacity:3];
    NSUInteger loopCount = 0;
    CGFloat totalTime;         // seconds
    CGFloat width;
    CGFloat height;
    
    getFrameInfo((__bridge CFDataRef)data, frames, delays, &totalTime, &width, &height, loopCount);
    NSDictionary *gifDic = @{@"images":frames,          //图片数组
                             @"delays":delays,          //每一帧对应的延迟时间数组
                             @"duration":@(totalTime),  //GIF图播放一遍的总时间
                             @"loopCount":@(loopCount), //GIF图播放次数  0-无限播放
                             @"bounds": NSStringFromCGRect(CGRectMake(0, 0, width, height))}; //GIF图的宽高
    return gifDic;
}

/*
 * @brief resolving gif information
 */
void getFrameInfo(CFDataRef data, NSMutableArray *frames, NSMutableArray *delayTimes, CGFloat *totalTime,CGFloat *gifWidth, CGFloat *gifHeight,NSUInteger loopCount)
{
    CGImageSourceRef gifSource = CGImageSourceCreateWithData(data, NULL);
    
    //获取gif的帧数
    size_t frameCount = CGImageSourceGetCount(gifSource);
    
    //获取GfiImage的基本数据
    NSDictionary *gifProperties = (__bridge NSDictionary *) CGImageSourceCopyProperties(gifSource, NULL);
    //由GfiImage的基本数据获取gif数据
    NSDictionary *gifDictionary =[gifProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary];
    //获取gif的播放次数 0-无限播放
    loopCount = [[gifDictionary objectForKey:(NSString*)kCGImagePropertyGIFLoopCount] integerValue];
    CFRelease((__bridge CFTypeRef)(gifProperties));
    
    for (size_t i = 0; i < frameCount; ++i) {
        //得到每一帧的CGImage
        CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        [frames addObject:[UIImage imageWithCGImage:frame]];
        CGImageRelease(frame);
        
        //获取每一帧的图片信息
        NSDictionary *frameDict = (__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL);
        
        //获取Gif图片尺寸
        if (gifWidth != NULL && gifHeight != NULL) {
            *gifWidth = [[frameDict valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
            *gifHeight = [[frameDict valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
        }
        
        //由每一帧的图片信息获取gif信息
        NSDictionary *gifDict = [frameDict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
        //取出每一帧的delaytime
        [delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime]];
        
        if (totalTime) {
            *totalTime = *totalTime + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFDelayTime] floatValue];
        }
        CFRelease((__bridge CFTypeRef)(frameDict));
    }
    CFRelease(gifSource);
}

/**
 *    压缩图片
 *    @param image 原始图片
 *    @returns 压缩后的图片
 */
+ (UIImage *)compressImage:(UIImage *)image{

    CGSize thumbSize = image.size;
    
    //第一次按thumbSize压缩
    UIGraphicsBeginImageContext(thumbSize);
    CGRect thumbRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    [image drawInRect:thumbRect];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage,1.0);
    
    //当thumbImageData超过128K，再次进行压缩
    while (thumbImageData.length > 128000 && MAX(image.size.width, image.size.height) > 480 && MIN(image.size.width, image.size.height) > 320) {	// 如果图片大就压缩
        CGFloat compressionQuality = (float)128000 / thumbImageData.length;
        thumbRect.size.width *= 0.85;
        thumbRect.size.height *= 0.85;
        UIGraphicsBeginImageContext(thumbRect.size);
        [image drawInRect:thumbRect];
        thumbImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        thumbImageData = UIImageJPEGRepresentation(thumbImage, compressionQuality);
    }
    return [UIImage imageWithData:thumbImageData];
}

/**
 *    压缩图片
 *    @param image 原始图片
 *    @param maxLength 压缩后最大的字节数
 *    @returns 压缩后的图片
 */
+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {

    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return image;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return resultImage;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    return resultImage;
}

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize {
	UIImage *sourceImage = self;
	UIImage *newImage = nil;
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);

	if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
		CGFloat widthFactor = targetWidth / width;
		CGFloat heightFactor = targetHeight / height;

		if (widthFactor > heightFactor) {
			scaleFactor = widthFactor;	// scale to fit height
		} else {
			scaleFactor = heightFactor;	// scale to fit width
		}

		scaledWidth = width * scaleFactor;
		scaledHeight = height * scaleFactor;

		// center the image
		if (widthFactor > heightFactor) {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
		} else if (widthFactor < heightFactor) {
			thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
		}
	}

	UIGraphicsBeginImageContext(targetSize);// this will crop
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	[sourceImage drawInRect:thumbnailRect];
	newImage = UIGraphicsGetImageFromCurrentImageContext();

	if (newImage == nil) {
		NSLog(@"could not scale image");
	}

	// pop the context to get back to the default
	UIGraphicsEndImageContext();
	return newImage;
}



// 截图,全屏(保留状态栏的20区域)
+ (UIImage *)screenShotNotCutByView:(UIView *)_view {
	CGFloat scale = ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] > 1.5) ? 2.0 : 1.0;

	UIGraphicsBeginImageContextWithOptions(_view.frame.size, NO, scale);

	// 渲染自身
	[_view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return finalImage;
}

// 截图,全屏(裁剪掉状态栏的20区域)
+ (UIImage *)screenShotByView:(UIView *)_view {
	CGFloat scale = ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] > 1.5) ? 2.0 : 1.0;

	UIGraphicsBeginImageContextWithOptions(_view.frame.size, NO, scale);

	// 渲染自身
	[_view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

    if ((![CommonUtil isPadDevice]) && CURRENT_DEVICE_VERSION>=7.0 && _view.frame.size.height>[[UIScreen mainScreen] bounds].size.height-20) {
        // 裁剪状态栏的20区域
        CGRect imageRect = CGRectMake(0 * finalImage.scale,
                                      20 * finalImage.scale,
                                      _view.frame.size.width * finalImage.scale,
                                      _view.frame.size.height * finalImage.scale);
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([finalImage CGImage], imageRect);
        UIImage *result = [UIImage	imageWithCGImage:imageRef
                                           scale			:finalImage.scale
                                      orientation		:finalImage.imageOrientation];
        
        CGImageRelease(imageRef);
        return result;
    }
	return finalImage;
}

// 截图，指定区域
+ (UIImage *)screenShotByView:(UIView *)_view inRect:(CGRect)_rect {
	// 截全屏
	UIImage *_image = [UIImage screenShotByView:_view];
	// 裁剪区域
	CGRect imageRect = CGRectMake(_rect.origin.x * _image.scale,
		_rect.origin.y * _image.scale,
		_rect.size.width * _image.scale,
		_rect.size.height * _image.scale);

	CGImageRef imageRef = CGImageCreateWithImageInRect([_image CGImage], imageRect);
	UIImage *result = [UIImage	imageWithCGImage:imageRef
								scale			:_image.scale
								orientation		:_image.imageOrientation];

	CGImageRelease(imageRef);
	return result;
}

- (UIImage *)resizeImageWithCapInsets:(UIEdgeInsets)capInsets {
	CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	UIImage *image = nil;

	if (systemVersion >= 5.0) {
		image = [self resizableImageWithCapInsets:capInsets];
		return image;
	}

	image = [self stretchableImageWithLeftCapWidth:capInsets.left topCapHeight:capInsets.top];
	return image;
}

#pragma mark - 将字符串生成二维码
+ (UIImage *)createQRForString:(NSString *)qrString withSize:(CGFloat)size {
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrCImage = qrFilter.outputImage;
    
    CGRect extent = CGRectIntegral(qrCImage.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:qrCImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark - 给图片加颜色
- (UIImage*)imageBlackToTransparentWithRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue {
    if (!self) return nil;
    const int imageWidth = self.size.width;
    const int imageHeight = self.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){// 将白色变成透明
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

#pragma mark - imageToTransparent
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

@end

