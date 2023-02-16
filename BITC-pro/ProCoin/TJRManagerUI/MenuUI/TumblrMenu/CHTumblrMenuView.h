//
//  CHTumblrMenuView.h
//  TumblrMenu
//
//  Created by HangChen on 12/9/13.
//  Copyright (c) 2013 Hang Chen (https://github.com/cyndibaby905)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <UIKit/UIKit.h>
typedef void (^CHTumblrMenuViewSelectedBlock)(void);
typedef void (^CHTumblrMenuViewDidDismiss)(void);

@interface CHTumblrMenuView : UIView<UIGestureRecognizerDelegate,CAAnimationDelegate>

@property (nonatomic,copy)CHTumblrMenuViewDidDismiss dismissBlock;

@property (nonatomic, readonly)UIImageView *backgroundImgView;
- (void)addMenuItemWithTitle:(NSString*)title andIcon:(UIImage*)icon andSelectedBlock:(CHTumblrMenuViewSelectedBlock)block;

/**
 *  更换Item项的图标和标题
 *
 *  @param imageName 图标图片名称
 *  @param title     标题
 *  @param index     Item的索引
 */
- (void)changeItemImage:(NSString *)imageName title:(NSString *)title index:(NSUInteger)index;

/** 默认显示，superView为在最上层的页面(包括presentViewController)*/
- (void)show;

/** 设置某个view作为背景并在该view上显示 */
- (void)showWithBackView:(UIView *)view;

/** 在view上显示该MenuView */
- (void)showInView:(UIView *)view;
@end
