//
//  RZFaceTextInputView.m
//  Tjrv
//
//  Created by Hay on 2019/3/11.
//  Copyright © 2019年 淘金路. All rights reserved.
//

#import "RZFaceTextInputView.h"
#import "CommonUtil.h"
#import "CircleChatFaceView.h"

@interface RZFaceTextInputView()<HPGrowingTextViewDelegate,CircleFaceDelegate>
{
    NSTimeInterval faceAnimateInterval;
    BOOL isFaceResponder;               //是否表情响应
}

@property (retain, nonatomic) CircleChatFaceView *faceView;

@property (retain, nonatomic) IBOutlet HPGrowingTextView *growingTextView;
@property (retain, nonatomic) IBOutlet UIButton *faceButton;
@property (retain, nonatomic) IBOutlet UIView *inputView;
@property (retain, nonatomic) IBOutlet UIControl *backgroundView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *inputViewLayoutBottomConstraint;         //input view的底部约束



@end

@implementation RZFaceTextInputView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initFaceTextInputView];
}

#pragma mark - 初始化
- (void)initFaceTextInputView
{
    faceAnimateInterval = 0.3;
    isFaceResponder = NO;
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [_faceButton setImage:[UIImage imageNamed:@"circleChat_face_icon_btn"] forState:UIControlStateNormal];
    _growingTextView.delegate = self;
    _growingTextView.textCountLabel.hidden = YES;
    _growingTextView.internalTextView.returnKeyType = UIReturnKeySend;
    [CommonUtil viewMasksToBounds:_growingTextView cornerRadius:3.5f borderColor:RGBA (211, 211, 222, 1)];
    _inputViewLayoutBottomConstraint.constant = -_inputView.frame.size.height;
    [self layoutIfNeeded];          //让inputView设置好后再下一步
    self.faceView = [[[CircleChatFaceView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 216)]autorelease];
    self.faceView.delegate = self;
    [self addSubview:_faceView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_growingTextView release];
    [_inputViewLayoutBottomConstraint release];
    [_inputView release];
    [_backgroundView release];
    [_faceButton release];
    [super dealloc];
}

#pragma mark - 弹起
- (void)inputViewBecomeFirstResponder
{
    self.userInteractionEnabled = YES;            //不再隐藏背景点击
    [_growingTextView becomeFirstResponder];
}

- (void)inputViewResignFirstResponder
{
    self.userInteractionEnabled = NO;           //隐藏背景点击
    [_growingTextView resignFirstResponder];
    [self hidenFaceView];
}

- (void)setText:(NSString *)text
{
    _growingTextView.text = text;
}

- (void)setPlaceHolder:(NSString *)text
{
    [_growingTextView setPlaceHolder:text];
}


#pragma mark - 按钮点击事件
- (IBAction)backgroundOperationEvent:(id)sender
{
    [self inputViewResignFirstResponder];
}

- (IBAction)faceButtonPressed:(id)sender
{
    if(isFaceResponder){
        isFaceResponder = NO;
        [_faceButton setImage:[UIImage imageNamed:@"circleChat_face_icon_btn"] forState:UIControlStateNormal];
        [_growingTextView becomeFirstResponder];
        [self hidenFaceView];
    }else{
        isFaceResponder = YES;
        [_faceButton setImage:[UIImage imageNamed:@"circleChat_keyboard_icon_btn"] forState:UIControlStateNormal];
        [_growingTextView resignFirstResponder];
        [self showFaceView];
    }
}

#pragma mark - 通知消息
- (void)keyboardWillShow:(NSNotification *)notification
{
    isFaceResponder = NO;
    [_faceButton setImage:[UIImage imageNamed:@"circleChat_face_icon_btn"] forState:UIControlStateNormal];
    [self hidenFaceView];
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _inputViewLayoutBottomConstraint.constant = keyboardFrame.size.height + IPHONEX_BOTTOM_HEIGHT;
    [self layoutIfNeeded];
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    if(isFaceResponder){
        [UIView animateWithDuration:faceAnimateInterval animations:^{
            _inputViewLayoutBottomConstraint.constant = _faceView.frame.size.height + IPHONEX_BOTTOM_HEIGHT;
            [self layoutIfNeeded];
        }];
        
    }else{
        _inputViewLayoutBottomConstraint.constant = -_inputView.frame.size.height;
        [self layoutIfNeeded];
    }
    
    
}

#pragma mark - HPGrowingTextView delgate
/** 高度改变*/
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    CGFloat diff = height - growingTextView.frame.size.height;
    CGFloat originY = _inputView.frame.origin.y - diff;
    CGFloat changeHeight = _inputView.frame.size.height + diff;
    [CommonUtil viewHeightForAutoLayout:_inputView height:changeHeight];
    _inputViewLayoutBottomConstraint.constant = self.frame.size.height - (originY + changeHeight);
}

/** 点击完成*/
- (void)growingTextViewClickFinish:(HPGrowingTextView *)growingTextView
{
    NSString *str = [growingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([_delegate respondsToSelector:@selector(faceTextInputViiewDidFinished:)]){
        [_delegate faceTextInputViiewDidFinished:str];
    }
}

#pragma mark - 显示表情
- (void)showFaceView
{
    [UIView animateWithDuration:faceAnimateInterval animations:^{
        _faceView.frame = CGRectMake(0.0, self.frame.size.height - IPHONEX_BOTTOM_HEIGHT - _faceView.frame.size.height, _faceView.frame.size.width, _faceView.frame.size.height);
    }];
    
//    if (bFristUp) {
//        self.msgToolView.frame = CGRectMake(0, self.frame.size.height - _currentBottomRect.size.height, self.msgToolView.frame.size.width, _currentBottomRect.size.height);
//        bFristUp = NO;
//    }
//
//    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:willBecomeFirstResponder:)]) {
//        [_delegate msgToolView:self willBecomeFirstResponder:_textView];
//    }
//
//    [UIView animateWithDuration:keyboardDuration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
//
//        _faceView.frame = CGRectMake(0, self.frame.size.height - _faceView.frame.size.height, _faceView.frame.size.width, _faceView.frame.size.height);
//        self.msgToolView.frame = CGRectMake(0, 0, self.msgToolView.frame.size.width, _currentBottomRect.size.height);
//
//        if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
//            [_delegate msgToolView:self keyboardReset:CGRectMake(_faceView.frame.origin.x, _faceView.frame.origin.y - _currentBottomRect.size.height, _faceView.frame.size.width, _faceView.frame.size.height)];
//        }
//
//    }completion:^(BOOL finished){
//
//    }];
}

- (void)hidenFaceView
{
    if(isFaceResponder){            //如果在表情还在响应的时候隐藏faceView，就表明整个输入框都需要隐藏了
        [UIView animateWithDuration:faceAnimateInterval animations:^{
            _faceView.frame = CGRectMake(0.0, self.frame.size.height , _faceView.frame.size.width, _faceView.frame.size.height);
            _inputViewLayoutBottomConstraint.constant = -_inputView.frame.size.height;
            [self layoutIfNeeded];
        }];
    }else{
        [UIView animateWithDuration:faceAnimateInterval animations:^{
            _faceView.frame = CGRectMake(0.0, self.frame.size.height , _faceView.frame.size.width, _faceView.frame.size.height);
        }];
    }
    
}

#pragma mark - 表情回调事件
- (void)faceOnClickWithName:(NSString *)name
{
    if (!checkIsStringWithAnyText(name)) return;
    
    [_growingTextView insertText:name];
}

- (void)faceOnClickBackspace
{
    NSString *text = _growingTextView.text;
    if (!checkIsStringWithAnyText(text)) return;
    NSString *lastChar = [text substringFromIndex:text.length - 1];
    if ([@"]" isEqualToString:lastChar]) {
        NSRange range = [text rangeOfString:@"[" options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            _growingTextView.text = [text substringToIndex:range.location];
            return;
        }
    }
    _growingTextView.text = [text substringToIndex:text.length - 1];
}

- (void)faceOnClickSend
{
    NSString *str = [_growingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([_delegate respondsToSelector:@selector(faceTextInputViiewDidFinished:)]){
        [_delegate faceTextInputViiewDidFinished:str];
    }
    
//    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:sendClicked:msgOrFileName:type:length:)]) {
//        [_delegate msgToolView:self sendClicked:_textView msgOrFileName:_textView.text type:CIRCLE_CHAT_TYPE_TEXT length:0];
//    }
//    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
//        [_delegate msgToolView:self keyboardReset:CGRectMake(_faceView.frame.origin.x, _faceView.frame.origin.y - _defautlBottomRect.size.height, _faceView.frame.size.width, _faceView.frame.size.height)];
//    }
}
@end
