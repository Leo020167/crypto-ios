//
//  HPTextView.m
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

#import "HPGrowingTextView.h"
#import "HPTextViewInternal.h"
#import "CommonUtil.h"
#import <QuartzCore/QuartzCore.h>

#define DefaultTextLimitCount		140
#define placeHolderLabelPadeLeft	7
#define placeHolderLabelPadeOriginY 0

@interface HPGrowingTextView (private)
- (void)commonInitialiser;
- (void)resizeTextView:(NSInteger)newSizeH;
- (void)growDidStop;
@end

@implementation HPGrowingTextView
@synthesize internalTextView;
@synthesize delegate;

@synthesize font;
@synthesize textColor;
@synthesize inputTextColor;
@synthesize textAlignment;
@synthesize selectedRange;
@synthesize editable;
@synthesize dataDetectorTypes;
@synthesize animateHeightChange;
@synthesize returnKeyType;
@synthesize textCountLabel;
@synthesize placeHolder;
@synthesize maxTextLimitCount;
@synthesize textViewLoc;
@synthesize textViewBackgroundImage;

// having initwithcoder allows us to use HPGrowingTextView in a Nib. -- aob, 9/2011
- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

	if (self) {
		[self commonInitialiser];

		int lineNum = internalTextView.contentSize.height / internalTextView.font.lineHeight;

		if (lineNum != 1) {
			[self setBorderColor:[UIColor grayColor] borderWidth:1.0];	// 设置边框
			[self setMinNumberOfLines:lineNum];
			[self setMaxNumberOfLines:lineNum];
		}
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		[self commonInitialiser];
	}
	return self;
}

- (void)commonInitialiser {
    
	// Initialization code
	CGRect r = self.frame;
	r.origin.y = 0;
	r.origin.x = 0;
	self.inputTextColor = [UIColor blackColor];
	internalTextView = [[HPTextViewInternal alloc] initWithFrame:r];
    [internalTextView setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
	internalTextView.delegate = self;
	internalTextView.scrollEnabled = NO;
	internalTextView.contentInset = UIEdgeInsetsZero;
	internalTextView.showsHorizontalScrollIndicator = NO;
    internalTextView.contentMode = UIViewContentModeRedraw;
	internalTextView.text = @"-";
    internalTextView.enablesReturnKeyAutomatically = YES;
	[self addSubview:internalTextView];
    
    minHeight = internalTextView.frame.size.height;
    animateHeightChange = YES;
    animationDuration = 0.1f;
    internalTextView.text = @"";

    [self setPlaceholderColor:[UIColor lightGrayColor]];
    internalTextView.displayPlaceHolder = YES;
    
    self.contentInset = UIEdgeInsetsMake(0, 1, 0, 1);
    [self setReturnKeyType:UIReturnKeyDone];
    self.minNumberOfLines = 1;
    self.maxNumberOfLines = 3;
    [self setMaxTextLimitCount:140];
    self.font = [UIFont systemFontOfSize:16.0f];
    self.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(2, 0, 2, 0);
    self.backgroundColor = [UIColor whiteColor];
    [self setCornerRadius:6];
    [self setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
    internalTextView.font = self.font;
    
    textCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(internalTextView.frame.size.width - 100 - 2, -4, 100, 20)];
    textCountLabel.tag = 321;
    textCountLabel.textAlignment = NSTextAlignmentRight;
    textCountLabel.font = [UIFont boldSystemFontOfSize:13];
    textCountLabel.textColor = [UIColor lightGrayColor];
    textCountLabel.backgroundColor = [UIColor clearColor];
    textCountLabel.text = @"0/140";
    [self addSubview:textCountLabel];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect r = self.bounds;
    r.origin.y = 0;
    r.origin.x = contentInset.left;
    r.size.width -= contentInset.left + contentInset.right;

    internalTextView.frame = r;
    
    [self setLimitLabel:CGRectMake(internalTextView.frame.size.width - 100 - 2, -4, 100, 20)];
}

- (void)dealloc {
	[inputTextColor release];
	[placeHolder release];
	[textCountLabel release];
	[internalTextView release];
	[textViewBackgroundImage release];
	[super dealloc];
}

#pragma mark - 设置边框
- (void)setBorderColor:(UIColor *)color borderWidth:(float)width {
	[self.layer setBorderColor:[color CGColor]];
	[self.layer setBorderWidth:width];
}

#pragma mark - 设置圆角
- (void)setCornerRadius:(float)radius {
	if (radius > 0) {
		self.layer.masksToBounds = YES;
	} else {
		self.layer.masksToBounds = NO;
	}
	self.layer.cornerRadius = radius;
}

- (void)sizeToFit {
	CGRect r = self.frame;

	if (([self.text length] > 0) || (r.size.height > minHeight)) {
		return;
	} else {
		r.size.height = minHeight;
		self.frame = r;
	}
}

-(CGSize)sizeThatFits:(CGSize)size
{
    if (self.text.length == 0) {
        size.height = minHeight;
    }
    return size;
}


- (void)setContentInset:(UIEdgeInsets)inset {
    
	contentInset = inset;
    
	CGRect r = self.frame;
	r.origin.y = inset.top - inset.bottom;
	r.origin.x = inset.left;
	r.size.width -= inset.left + inset.right;

	internalTextView.frame = r;
	textViewBackgroundImage.frame = r;
    
	[self setMaxNumberOfLines:maxNumberOfLines];
	[self setMinNumberOfLines:minNumberOfLines];
}

- (UIEdgeInsets)contentInset {
	return contentInset;
}

-(void)setMaxNumberOfLines:(int)n
{
    if(n == 0 && maxHeight > 0) return; // the user specified a maxHeight themselves.
    
    // Use internalTextView for height calculations, thanks to Gwynne <http://blog.darkrainfall.org/>
    NSString *saveText = internalTextView.text, *newText = @"-";
    
    internalTextView.delegate = nil;
    internalTextView.hidden = YES;
    
    for (int i = 1; i < n; ++i)
        newText = [newText stringByAppendingString:@"\n|W|"];
    
    internalTextView.text = newText;
    
    maxHeight = [self measureHeight];
    
    internalTextView.text = saveText;
    internalTextView.hidden = NO;
    internalTextView.delegate = self;
    
    [self sizeToFit];
    
    maxNumberOfLines = n;
}

- (int)maxNumberOfLines {
	return maxNumberOfLines;
}

-(void)setMinNumberOfLines:(int)m
{
    if(m == 0 && minHeight > 0) return; // the user specified a minHeight themselves.
    
    // Use internalTextView for height calculations, thanks to Gwynne <http://blog.darkrainfall.org/>
    NSString *saveText = internalTextView.text, *newText = @"-";
    
    internalTextView.delegate = nil;
    internalTextView.hidden = YES;
    
    for (int i = 1; i < m; ++i)
        newText = [newText stringByAppendingString:@"\n|W|"];
    
    internalTextView.text = newText;
    
    minHeight = [self measureHeight];
    
    internalTextView.text = saveText;
    internalTextView.hidden = NO;
    internalTextView.delegate = self;
    
    [self sizeToFit];
    
    minNumberOfLines = m;
}

- (int)minNumberOfLines {
	return minNumberOfLines;
}

- (CGFloat)measureHeight
{
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        return ceilf([self.internalTextView sizeThatFits:self.internalTextView.frame.size].height);
    }
    else {
        return self.internalTextView.contentSize.height;
    }
}

- (void)resetScrollPositionForIOS7
{
    CGRect r = [internalTextView caretRectForPosition:internalTextView.selectedTextRange.end];
    CGFloat caretY =  MAX(r.origin.y - internalTextView.frame.size.height + r.size.height + 8, 0);
    if (internalTextView.contentOffset.y < caretY && r.origin.y != INFINITY)
        internalTextView.contentOffset = CGPointMake(0, caretY);
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshHeight];
    
    if (textView.text.length <= 0) {
        internalTextView.scrollEnabled = NO;
    }
    textViewCount = [HPGrowingTextView getTextLenthByString:textView.text];
    
    // 显示字数提示
    if (textCountLabel) {
        if (maxTextLimitCount == NoTextLimitCount) {
            textCountLabel.textColor = [UIColor lightGrayColor];
            textCountLabel.text = [NSString stringWithFormat:@"%ld/字符", (long)textViewCount];
        } else {
            if (textViewCount > maxTextLimitCount) {
                textCountLabel.textColor = [UIColor redColor];
                textCountLabel.text = @"超出字数限制";
            } else {
                textCountLabel.textColor = [UIColor lightGrayColor];
                textCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)textViewCount, (long)maxTextLimitCount];
            }
        }
    }
}

- (void)refreshHeight
{
    
    //size of content, so we can set the frame of self
    NSInteger newSizeH = [self measureHeight];
    if (newSizeH < minHeight || !internalTextView.hasText) {
        newSizeH = minHeight; //not smalles than minHeight
    }
    else if (maxHeight && newSizeH > maxHeight) {
        newSizeH = maxHeight; // not taller than maxHeight
    }
    
    /*
     setMinNumberOfLines和setMaxNumberOfLines 方法中使用了sizeToFit方法，已经将internalTextView的高度改为maxHeight等大，上面的代码又将newSizeH值改为minHeight或maxHeight，所以if里面的代码不会执行，内容超出限制，就不能滚动查看

     */
//    if (internalTextView.frame.size.height != newSizeH)
    {
        // if our new height is greater than the maxHeight
        // sets not set the height or move things
        // around and enable scrolling
        if (newSizeH >= maxHeight)
        {
            if(!internalTextView.scrollEnabled){
                internalTextView.scrollEnabled = YES;
                [internalTextView flashScrollIndicators]; // 闪一下滚动条，暗示是否有可滚动的内容
            }
            
        } else {
            internalTextView.scrollEnabled = NO;
        }
        
        // [fixed] Pasting too much text into the view failed to fire the height change,
        // thanks to Gwynne <http://blog.darkrainfall.org/>
        if (newSizeH <= maxHeight)
        {
            if(animateHeightChange) {
                
                [UIView animateWithDuration:animationDuration
                                      delay:0
                                    options:(UIViewAnimationOptionAllowUserInteraction|
                                             UIViewAnimationOptionBeginFromCurrentState)
                                 animations:^(void) {
                                     [self resizeTextView:newSizeH];
                                 }
                                 completion:^(BOOL finished) {
                                     if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
                                         [delegate growingTextView:self didChangeHeight:newSizeH];
                                     }
                                 }];
            } else {
                [self resizeTextView:newSizeH];
                // [fixed] The growingTextView:didChangeHeight: delegate method was not called at all when not animating height changes.
                // thanks to Gwynne <http://blog.darkrainfall.org/>
                
                if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
                    [delegate growingTextView:self didChangeHeight:newSizeH];
                }
            }
        }
    }
    // Display (or not) the placeholder string
    
    BOOL wasDisplayingPlaceholder = internalTextView.displayPlaceHolder;
    internalTextView.displayPlaceHolder = self.internalTextView.text.length == 0;
    
    if (wasDisplayingPlaceholder != internalTextView.displayPlaceHolder) {
        [internalTextView setNeedsDisplay];
    }
    
    
    // scroll to caret (needed on iOS7)
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        [self performSelector:@selector(resetScrollPositionForIOS7) withObject:nil afterDelay:0.1f];
    }
    
    // Tell the delegate that the text view changed
    if ([delegate respondsToSelector:@selector(growingTextViewDidChange:)]) {
        [delegate growingTextViewDidChange:self];
    }
}

- (void)resizeTextView:(NSInteger)newSizeH {
	if ([delegate respondsToSelector:@selector(growingTextView:willChangeHeight:)]) {
		[delegate growingTextView:self willChangeHeight:newSizeH];
	}
    
    CGRect internalTextViewFrame = self.frame;
    if (self.translatesAutoresizingMaskIntoConstraints) {
        internalTextViewFrame.size.height = newSizeH;	// + padding
        self.frame = internalTextViewFrame;
    }
    internalTextViewFrame.origin.y = contentInset.top - contentInset.bottom;
    internalTextViewFrame.origin.x = contentInset.left;
    
    internalTextViewFrame.size.width = internalTextView.contentSize.width;
    
    if(!CGRectEqualToRect(internalTextView.frame, internalTextViewFrame)) internalTextView.frame = internalTextViewFrame;

    textViewBackgroundImage.frame = internalTextViewFrame;
}

- (void)growDidStop {
    
    // scroll to caret (needed on iOS7)
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        [self resetScrollPositionForIOS7];
    }
    
	if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
		[delegate growingTextView:self didChangeHeight:self.frame.size.height];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[internalTextView becomeFirstResponder];
}

- (BOOL)becomeFirstResponder {
	[super becomeFirstResponder];
	return [self.internalTextView becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
	[super resignFirstResponder];
	return [internalTextView resignFirstResponder];
}

- (BOOL)isFirstResponder {
	return [internalTextView isFirstResponder];
}

// /////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITextView properties
// /////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setText:(NSString *)newText {
	internalTextView.text = newText;
	// include this line to analyze the height of the textview.
	// fix from Ankit Thakur
	[self performSelector:@selector(textViewDidChange:) withObject:internalTextView];
}

- (NSString *)text {
	return internalTextView.text;
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setFont:(UIFont *)afont {
	internalTextView.font = afont;
	[self setMaxNumberOfLines:maxNumberOfLines];
	[self setMinNumberOfLines:minNumberOfLines];
}

- (UIFont *)font {
	return internalTextView.font;
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setTextColor:(UIColor *)color {
	self.inputTextColor = color;
	internalTextView.textColor = color;
}

- (UIColor *)textColor {
	return internalTextView.textColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
	[super setBackgroundColor:backgroundColor];
	internalTextView.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor {
	return internalTextView.backgroundColor;
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setTextAlignment:(NSTextAlignment)aligment {
	internalTextView.textAlignment = aligment;
}

- (NSTextAlignment)textAlignment {
	return internalTextView.textAlignment;
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setSelectedRange:(NSRange)range {
	internalTextView.selectedRange = range;
}

- (NSRange)selectedRange {
	return internalTextView.selectedRange;
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setEditable:(BOOL)beditable {
	internalTextView.editable = beditable;
}

- (BOOL)isEditable {
	return internalTextView.editable;
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setReturnKeyType:(UIReturnKeyType)keyType {
	internalTextView.returnKeyType = keyType;
}

- (UIReturnKeyType)returnKeyType {
	return internalTextView.returnKeyType;
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setDataDetectorTypes:(UIDataDetectorTypes)datadetector {
	internalTextView.dataDetectorTypes = datadetector;
}

- (UIDataDetectorTypes)dataDetectorTypes {
	return internalTextView.dataDetectorTypes;
}

// /////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)hasText {
	return [internalTextView hasText];
}

- (void)scrollRangeToVisible:(NSRange)range {
	[internalTextView scrollRangeToVisible:range];
}

// ///////////////////////////////////////////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextViewDelegate

// /////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	internalTextView.textColor = inputTextColor;

	//    placeHolderLabel.hidden = YES;
	if ([delegate respondsToSelector:@selector(growingTextViewShouldBeginEditing:)]) {
		return [delegate growingTextViewShouldBeginEditing:self];
	} else {
		return YES;
	}
}

// /////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewShouldEndEditing:)]) {
		return [delegate growingTextViewShouldEndEditing:self];
	} else {
		return YES;
	}
}

// /////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidBeginEditing:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)]) {
		[delegate growingTextViewDidBeginEditing:self];
	}
}

// /////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidEndEditing:(UITextView *)textView {
	//    if (placeHolderLabel.text.length > 0 && internalTextView.text.length == 0) {
	//        placeHolderLabel.hidden = NO;
	//    }
	if ([delegate respondsToSelector:@selector(growingTextViewDidEndEditing:)]) {
		textViewLoc = self.selectedRange.location;
		[delegate growingTextViewDidEndEditing:self];
	}
}

// /////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)atext {
	// weird 1 pixel bug when clicking backspace when textView is empty
	if (![textView hasText] && [atext isEqualToString:@""]) return NO;

	// Added by bretdabaker: sometimes we want to handle this ourselves
	if ([delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)]) {
		return [delegate growingTextView:self shouldChangeTextInRange:range replacementText:atext];
	}

	if ([atext isEqualToString:@"\n"] && (self.returnKeyType == UIReturnKeyDone || self.returnKeyType == UIReturnKeySend)) {
		if ([delegate respondsToSelector:@selector(growingTextViewClickFinish:)]) {
			[delegate growingTextViewClickFinish:self];
			return NO;
		}
		// 改成按发送键不换行
		[textView resignFirstResponder];
		return NO;
	}
    
    if ([delegate respondsToSelector:@selector(growingTextView:changeTextInRange:replacementText:)]) {
        [delegate growingTextView:self changeTextInRange:range replacementText:atext];
    }
    
	return YES;
}

// /////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChangeSelection:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewDidChangeSelection:)]) {
		[delegate growingTextViewDidChangeSelection:self];
	}
}

- (void)setMaxTextLimitCount:(NSInteger)maxCount {
	maxTextLimitCount = maxCount;

	if (maxTextLimitCount == NoTextLimitCount) {
		textCountLabel.text = [NSString stringWithFormat:@"%ld/字符", (long)textViewCount];
	} else {
		textCountLabel.text = [NSString stringWithFormat:@"0/%ld", (long)maxCount];
	}
}

#pragma mark -  字数提示的label
- (void)setLimitLabel:(CGRect)rect {
	
    if (textCountLabel.tag == 321) {
        textCountLabel.frame = rect;
    }
}

#pragma mark -  重新设置字数提示的位置---参数是输入框的宽,(长屏时会错位)
- (void)setLimitLabelFrameWithTextViewWidth:(CGFloat)width toLeftPoint:(float)left {
	if (textCountLabel == nil) return;

	CGRect frame = textCountLabel.frame;
	frame.origin.x = width - left;
	textCountLabel.frame = frame;
}

#pragma mark - 计算中文字数
+ (NSInteger)getTextLenthByString:(NSString *)_aStr {

	float number = 0.0;

	for (int index = 0; index < [_aStr length]; index++) {
		NSString *character = [_aStr substringWithRange:NSMakeRange(index, 1)];

		if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3) {
			number++;
		} else {
			number = number + 0.5;
		}
	}

	return ceil(number);
}

- (NSInteger)count {
	return textViewCount;
}

- (NSString *)placeholder
{
    return internalTextView.placeholder;
}

- (void)setPlaceHolder:(NSString *)placeholder
{
    [internalTextView setPlaceholder:placeholder];
    [internalTextView setNeedsDisplay];
}

- (UIColor *)placeholderColor
{
    return internalTextView.placeholderColor;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    [internalTextView setPlaceholderColor:placeholderColor];
}


- (void)setTextCountLabel:(UILabel *)_textCountLabel {
	if (textCountLabel) {
		[textCountLabel removeFromSuperview];
		[textCountLabel release];
	}
	textCountLabel = [_textCountLabel retain];
}

- (void)setTextCountLabelHidden:(BOOL)hidden{
    textCountLabel.hidden = hidden;
}

- (void)insertText:(NSString *)_text {
	[internalTextView insertText:_text];
	[self performSelector:@selector(textViewDidChange:) withObject:internalTextView];
}

#pragma mark - 设置背景图片
- (void)setBackgroundImage:(UIImage *)_bgImage {
	self.backgroundColor = [UIColor clearColor];
	self.layer.borderWidth = 0;
	internalTextView.backgroundColor = [UIColor clearColor];

	textViewBackgroundImage = [[UIImageView alloc] initWithFrame:self.bounds];
	textViewBackgroundImage.image = _bgImage;
	textViewBackgroundImage.contentMode = UIViewContentModeScaleToFill;

	textViewBackgroundImage.frame = self.bounds;
	[self addSubview:textViewBackgroundImage];
	[self sendSubviewToBack:textViewBackgroundImage];
}


@end
