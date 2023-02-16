//
//  HPTextView.h
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import <UIKit/UIKit.h>

#define NoTextLimitCount -1

@class HPGrowingTextView;
@class HPTextViewInternal;

@protocol HPGrowingTextViewDelegate

@optional
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView;

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView;
- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView;

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextView:(HPGrowingTextView *)growingTextView changeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView;

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height;
- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height;

- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView;

- (void)growingTextViewClickFinish:(HPGrowingTextView *)growingTextView;
@end

@interface HPGrowingTextView : UIView <UITextViewDelegate>{
	HPTextViewInternal *internalTextView;

	int minHeight;
	int maxHeight;

	// class properties
	int maxNumberOfLines;
	int minNumberOfLines;

	BOOL animateHeightChange;
    NSTimeInterval animationDuration;

	// uitextview properties
	NSObject <HPGrowingTextViewDelegate> *delegate;
	NSString *text;
	UIFont *font;
	UIColor *textColor;
	NSTextAlignment textAlignment;
	NSRange selectedRange;
	BOOL editable;
	UIDataDetectorTypes dataDetectorTypes;
	UIReturnKeyType returnKeyType;

	UIEdgeInsets contentInset;

	UILabel *textCountLabel;					// 字数提示
	NSInteger textViewCount;					// 字数
	NSInteger maxTextLimitCount;				// 最大字数限制
}

// real class properties
@property int maxNumberOfLines;
@property int minNumberOfLines;
@property BOOL animateHeightChange;
@property (retain) UITextView *internalTextView;

// uitextview properties
@property (assign) IBOutlet id <HPGrowingTextViewDelegate> delegate;
@property (nonatomic, assign) NSString *text;
@property (nonatomic, assign) UIFont *font;
@property (nonatomic, assign) UIColor *textColor;
@property (nonatomic) NSTextAlignment textAlignment;	// default is UITextAlignmentLeft
@property (nonatomic) NSRange selectedRange;			// only ranges of length 0 are supported
@property (nonatomic, getter = isEditable) BOOL editable;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_0);

@property (nonatomic) UIReturnKeyType returnKeyType;
@property (assign) UIEdgeInsets contentInset;
@property (assign,nonatomic) NSInteger maxTextLimitCount;
@property (nonatomic, retain) UIImageView *textViewBackgroundImage;
@property (retain, nonatomic) UIColor *inputTextColor;			// 当输入框有提示语时，输入框文字的颜色,值为textColor的值,没必要时不用给这个赋值
// uitextview methods
// need others? use .internalTextView
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (BOOL)isFirstResponder;

- (BOOL)hasText;
- (void)scrollRangeToVisible:(NSRange)range;

- (void)setLimitLabel:(CGRect)rect;						// 开启字数限制
- (void)setTextCountLabelHidden:(BOOL)hidden;

#pragma mark -  重新设置字数提示的位置---参数是输入框的宽,(长屏时会错位)
- (void)setLimitLabelFrameWithTextViewWidth:(CGFloat)width toLeftPoint:(float)left;
- (NSInteger)count;										// 返回textView的字数
@property (nonatomic, retain) UILabel *textCountLabel;	// 字数提示label
@property (nonatomic, copy) NSString *placeHolder;		// placeHolder
@property (nonatomic, assign) NSInteger textViewLoc;	// 当前光标位置
#pragma mark - 设置边框
- (void)setBorderColor:(UIColor *)color borderWidth:(float)width;
- (void)setPlaceholderColor:(UIColor *)placeholderColor;
#pragma mark - 设置圆角
- (void)setCornerRadius:(float)radius;
+ (NSInteger)getTextLenthByString:(NSString *)_aStr;		// 获取文本长度
- (void)setBackgroundImage:(UIImage *)_bgImage;
- (void)insertText:(NSString *)text;

@end

