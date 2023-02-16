//
//  RZWebImageView.h
//  Redz
//
//  Created by Hay on 2018/9/30.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>



#define RZWebImageViewDefaultPlaceHolderImage   [UIImage imageNamed:@"util_Image_bg_loading_img"]
#define RZWebImageViewDefaultUserHeaderImage    [UIImage imageNamed:@"util_Image_bg_no_head"]
#define RZWebImageViewDefaultRectanglePlaceHolderImage  [UIImage imageNamed:@"util_Image_bg_loading_img_rectangle"]

@interface RZWebImageView : UIImageView

#pragma mark - 判断该图片是否已存缓存
+ (BOOL)checkImageHasCache:(NSString *)urlStr;
#pragma mark - 获取某网络图片的缓存UIImage数据类型
+ (UIImage *)getUIImageTypeFromUrl:(NSString *)urlStr;

#pragma mark - 显示网络图片
/**
 * @brief 允许图片点击操作
 * @param imageDidTouchEvent  为强引用block，所以在里面操作数据请避免循环引用
 */
- (void)showImageWithUrl:(NSString *)urlStr imageCanTouch:(BOOL)canTouch imageDidTouchEvent:(void (^)(void))touchEvent;
- (void)showImageWithUrl:(NSString *)urlStr;
- (void)showImageWithUrl:(NSString *)urlStr placeholderImage:(UIImage *)placeholderImage;

#pragma mark - 显示头像图片
/** 主要根据app中头像的特点进行特殊处理*/
/**
 * @brief 允许图片点击操作
 * @param headerImageDidTouchEvent  为强引用block，所以在里面操作数据请避免循环引用
 */
- (void)showHeaderImageViewWithUrl:(NSString *)urlStr imageCanTouch:(BOOL)canTouch headerImageDidTouchEvent:(void (^)(void))touchEvent;
- (void)showHeaderImageViewWithUrl:(NSString *)urlStr;
- (void)showHeaderImageViewWithUrl:(NSString *)urlStr placeholderImage:(UIImage *)placeholderImage;

@end

