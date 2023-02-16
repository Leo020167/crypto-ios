//
//  RZFaceTextInputView.h
//  Tjrv
//
//  Created by Hay on 2019/3/11.
//  Copyright © 2019年 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@protocol RZFaceTextInputViewDelegate <NSObject>

@optional
- (void)faceTextInputViiewDidFinished:(NSString *)inputText;

@end

/** 因为该view的宽高是整个屏幕的宽高，所以作为子类添加，
    父类必须是最外面的view,也就是父类view宽高也必须是屏幕的宽高
 */
@interface RZFaceTextInputView : UIView

@property (assign, nonatomic) id<RZFaceTextInputViewDelegate> delegate;

/** 弹起键盘*/
- (void)inputViewBecomeFirstResponder;
/** 缩下键盘*/
- (void)inputViewResignFirstResponder;

- (void)setText:(NSString *)text;
- (void)setPlaceHolder:(NSString *)text;

@end


