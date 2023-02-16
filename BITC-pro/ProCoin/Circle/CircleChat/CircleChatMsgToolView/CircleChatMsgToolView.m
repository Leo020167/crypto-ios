//
//  CircleChatMsgToolView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 11/13/15.
//  Copyright © 2015红跳蚤. All rights reserved.
//

#import "CircleChatMsgToolView.h"
#import "HPGrowingTextView.h"
#import "CircleChatFaceView.h"
#import "CircleChatExpandView.h"
#import "ChatVoiceRecorderVC.h"
#import "TTCacheManager.h"
#import "VoiceConverter.h"
#import "TJRVoicePlayView.h"
#import "CommonUtil.h"
#import "UIImage+Size.h"
#import "CircleChatEntity.h"
#import "CircleChatRecordView.h"
#import "TJRBaseSocket.h"

#define icon_btn_keyboard       @"circleChat_keyboard_icon_btn"
#define icon_btn_face           @"circleChat_face_icon_btn"
#define icon_btn_recoder        @"circleChat_recoder_icon_btn"

@interface CircleChatMsgToolView ()<CircleRecordDelegate,HPGrowingTextViewDelegate,CircleFaceDelegate,CircleExpandDelegate>{
    NSTimeInterval keyboardDuration;
    CGRect keyboardRec;
    
    BOOL bFaceClick;               //当前是否选中表情选择栏
    BOOL bExpandClick;             //当前是否选中项目选择栏
    BOOL bRecorderClick;           //当前是否选中录音按钮
    BOOL bKeyboardUp;
    BOOL bFristUp;
    
    CGRect phoneRectScreen;
    
    ChatVoiceRecorderVC     *voiceRecorderVC;       //录音视图
    
    BOOL bReqFinished;
    CGFloat screenHeight;
}

@property (retain, nonatomic) IBOutlet UIView *msgToolView;
@property (retain, nonatomic) CircleChatFaceView *faceView;
@property (retain, nonatomic) CircleChatExpandView *expandView;
@property (retain, nonatomic) CircleChatRecordView* recordView;

@property (retain, nonatomic) IBOutlet UIButton *faceBtn;
@property (retain, nonatomic) IBOutlet UIButton *recoderBtn;

@property (assign, nonatomic) CGRect defautlBottomRect;          //默认底部view的rect
@property (assign, nonatomic) CGRect currentBottomRect;          //当前

@end

@implementation CircleChatMsgToolView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initSendMsgAndFaceView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initSendMsgAndFaceView];
    }
    
    return self;
}

- (void)setTextView:(HPGrowingTextView *)textView {
    if (!textView) return;
    
    RELEASE(_textView);
    _textView = [textView retain];
}

- (void)initSendMsgAndFaceView {
    
    phoneRectScreen = [[UIScreen mainScreen] bounds];
    
    [[NSBundle mainBundle] loadNibNamed:@"CircleChatMsgToolView" owner:self options:nil];
    CGRect frame = self.msgToolView.frame;
    frame.origin = CGPointZero;
    frame.size = self.frame.size;
    self.msgToolView.frame = frame;
    _defautlBottomRect = self.frame;
    _currentBottomRect = self.frame;
    
    _textView.textCountLabel.hidden = YES;
    _textView.maxTextLimitCount = 3;
    _textView.minNumberOfLines = 1;
    keyboardDuration = 0.3;
    bFristUp = YES;
    bReqFinished = YES;
    _bDragBack = NO;
    
    screenHeight = phoneRectScreen.size.height - IPHONEX_BOTTOM_HEIGHT;
    
    _textView.delegate = self;
    [_textView setReturnKeyType:UIReturnKeySend];
    
    self.faceView = [[[CircleChatFaceView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 216)]autorelease];
    [self.faceView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    
    self.expandView = [[[CircleChatExpandView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 216)]autorelease];
    [self.expandView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    self.recordView = [[CircleChatRecordView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 216)];
    [self.recordView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
    
    self.recordView.circleDelegate = self;
    self.faceView.delegate = self;
    self.expandView.delegate = self;
    
    [self addSubview:self.faceView];
    [self addSubview:self.expandView];
    [self addSubview:self.recordView];
    _faceView.hidden = YES;
    _expandView.hidden = YES;
    _recordView.hidden = YES;
    
    [self addSubview:self.msgToolView];
    [self addKeyboardObserver];
    
    self.backgroundColor = [UIColor clearColor];
    [CommonUtil viewMasksToBounds:_textView cornerRadius:3 borderColor:RGBA(238, 238, 238, 1) borderWidth:1];
    
}

/**
 *    添加键盘的监听(在viewDidAppear里加上)
 */
- (void)addKeyboardObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

/**
 *    移除键盘监听(在viewDidDisappear里加上)
 */
- (void)removeKeyboardObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)faceButtonClicked:(id)sender {
    
    _expandView.hidden = YES;
    _faceView.hidden = NO;
    _recordView.hidden = YES;
    
    if (bKeyboardUp) {
        bFaceClick = YES;
        bExpandClick = NO;
        [_textView resignFirstResponder];
        [_faceBtn setImage:[UIImage imageNamed:icon_btn_keyboard] forState:UIControlStateNormal];
    }else{
        bExpandClick = NO;
        if (bFaceClick) {
            [_textView becomeFirstResponder];
            [_faceBtn setImage:[UIImage imageNamed:icon_btn_face] forState:UIControlStateNormal];
        }else{
            
            [self showFace];
            bFaceClick = YES;
            [_faceBtn setImage:[UIImage imageNamed:icon_btn_keyboard] forState:UIControlStateNormal];
        }
    }
    [_recoderBtn setImage:[UIImage imageNamed:icon_btn_recoder] forState:UIControlStateNormal];
    _textView.hidden = NO;
    bRecorderClick = NO;
}


- (IBAction)expandButtonClicked:(id)sender {
    
    _expandView.hidden = NO;
    _faceView.hidden = YES;
    _recordView.hidden = YES;
    
    if (bKeyboardUp) {
        bExpandClick = YES;
        bFaceClick = NO;
        [_textView resignFirstResponder];
    }else{
        bFaceClick = NO;
        if (bExpandClick) {
            [_textView becomeFirstResponder];
        }else{
            
            [self showExpandView];
            bExpandClick = YES;
            [_faceBtn setImage:[UIImage imageNamed:icon_btn_face] forState:UIControlStateNormal];
        }
    }
    [_recoderBtn setImage:[UIImage imageNamed:icon_btn_recoder] forState:UIControlStateNormal];
    _textView.hidden = NO;
    bRecorderClick = NO;
    
}

- (IBAction)recoderButtonClicked:(id)sender {
    
    _expandView.hidden = YES;
    _faceView.hidden = YES;
    _recordView.hidden = NO;
    
    bExpandClick = NO;
    bFaceClick = NO;
    
    if (bKeyboardUp) {
        bRecorderClick = YES;
        [_textView resignFirstResponder];
        [_recoderBtn setImage:[UIImage imageNamed:icon_btn_keyboard] forState:UIControlStateNormal];
    }else{
        if (bRecorderClick) {
            bRecorderClick = NO;
            [_textView becomeFirstResponder];
            _textView.hidden = NO;
            [_recoderBtn setImage:[UIImage imageNamed:icon_btn_recoder] forState:UIControlStateNormal];
        }else{
            [self showRecoderView];
            bRecorderClick = YES;
            [_recoderBtn setImage:[UIImage imageNamed:icon_btn_keyboard] forState:UIControlStateNormal];
        }
    }
    [_faceBtn setImage:[UIImage imageNamed:icon_btn_face] forState:UIControlStateNormal];
}



#pragma mark -
#pragma mark - Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    keyboardDuration = animationDuration;
    keyboardRec = keyboardRect;
    bKeyboardUp = YES;
    [_faceBtn setImage:[UIImage imageNamed:icon_btn_face] forState:UIControlStateNormal];
    [_recoderBtn setImage:[UIImage imageNamed:icon_btn_recoder] forState:UIControlStateNormal];
    
    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:willBecomeFirstResponder:)]) {
        [_delegate msgToolView:self willBecomeFirstResponder:_textView];
    }
    
    self.frame = CGRectMake(0, keyboardRec.origin.y - _currentBottomRect.size.height, self.frame.size.width, keyboardRec.size.height + _currentBottomRect.size.height);
    
    self.msgToolView.frame = CGRectMake(0, self.frame.size.height - _currentBottomRect.size.height, self.frame.size.width, _currentBottomRect.size.height);
    
    [UIView animateWithDuration:keyboardDuration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        
        self.msgToolView.frame = CGRectMake(0, 0, self.frame.size.width, _currentBottomRect.size.height);
        //faceview随时贴在输入框下面
        _faceView.frame = CGRectMake(0, _currentBottomRect.size.height, keyboardRec.size.width, _faceView.frame.size.height);
        _expandView.frame = CGRectMake(0, _currentBottomRect.size.height, keyboardRec.size.width, _expandView.frame.size.height);
        _recordView.frame = CGRectMake(0, _currentBottomRect.size.height, keyboardRec.size.width, _recordView.frame.size.height);
        
        if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
            [_delegate msgToolView:self keyboardReset:CGRectMake(keyboardRec.origin.x, 0, keyboardRec.size.width, keyboardRec.size.height)];
        }
        
    }completion:^(BOOL finished){
        
    }];
}

- (void)showFace{
    
    self.frame = CGRectMake(0, screenHeight - _faceView.frame.size.height - _currentBottomRect.size.height, self.frame.size.width, _faceView.frame.size.height + _currentBottomRect.size.height);
    
    _faceView.frame = CGRectMake(0, self.frame.size.height, _faceView.frame.size.width, _faceView.frame.size.height);
    
    if (bFristUp) {
        self.msgToolView.frame = CGRectMake(0, self.frame.size.height - _currentBottomRect.size.height, self.msgToolView.frame.size.width, _currentBottomRect.size.height);
        bFristUp = NO;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:willBecomeFirstResponder:)]) {
        [_delegate msgToolView:self willBecomeFirstResponder:_textView];
    }
    
    [UIView animateWithDuration:keyboardDuration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        
        _faceView.frame = CGRectMake(0, self.frame.size.height - _faceView.frame.size.height, _faceView.frame.size.width, _faceView.frame.size.height);
        self.msgToolView.frame = CGRectMake(0, 0, self.msgToolView.frame.size.width, _currentBottomRect.size.height);
        
        if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
            [_delegate msgToolView:self keyboardReset:CGRectMake(_faceView.frame.origin.x, _faceView.frame.origin.y - _currentBottomRect.size.height, _faceView.frame.size.width, _faceView.frame.size.height)];
        }
        
    }completion:^(BOOL finished){
        
    }];
}

- (void)showExpandView{
    
    self.frame = CGRectMake(0, screenHeight - _expandView.frame.size.height - _currentBottomRect.size.height, self.frame.size.width, _expandView.frame.size.height + _currentBottomRect.size.height);
    
    _expandView.frame = CGRectMake(0, self.frame.size.height, _expandView.frame.size.width, _expandView.frame.size.height);
    
    if (bFristUp)  {
        self.msgToolView.frame = CGRectMake(0, self.frame.size.height - _currentBottomRect.size.height, self.msgToolView.frame.size.width, _currentBottomRect.size.height);
        bFristUp = NO;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:willBecomeFirstResponder:)]) {
        [_delegate msgToolView:self willBecomeFirstResponder:_textView];
    }
    
    [UIView animateWithDuration:keyboardDuration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        
        _expandView.frame = CGRectMake(0, self.frame.size.height - _expandView.frame.size.height, _expandView.frame.size.width, _expandView.frame.size.height);
        self.msgToolView.frame = CGRectMake(0, 0, self.msgToolView.frame.size.width, _currentBottomRect.size.height);
        
        if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
            [_delegate msgToolView:self keyboardReset:CGRectMake(_expandView.frame.origin.x, _expandView.frame.origin.y - _currentBottomRect.size.height, _expandView.frame.size.width, _expandView.frame.size.height)];
        }
    }completion:^(BOOL finished){
        
    }];
}

- (void)showRecoderView{
    
    self.frame = CGRectMake(0, screenHeight - _recordView.frame.size.height - _currentBottomRect.size.height, self.frame.size.width, _recordView.frame.size.height + _currentBottomRect.size.height);
    
    _recordView.frame = CGRectMake(0, self.frame.size.height, _recordView.frame.size.width, _recordView.frame.size.height);
    
    if (bFristUp)  {
        self.msgToolView.frame = CGRectMake(0, self.frame.size.height - _currentBottomRect.size.height, self.msgToolView.frame.size.width, _currentBottomRect.size.height);
        bFristUp = NO;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:willBecomeFirstResponder:)]) {
        [_delegate msgToolView:self willBecomeFirstResponder:_textView];
    }
    
    [UIView animateWithDuration:keyboardDuration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        
        _recordView.frame = CGRectMake(0, self.frame.size.height - _recordView.frame.size.height, _recordView.frame.size.width, _recordView.frame.size.height);
        self.msgToolView.frame = CGRectMake(0, 0, self.msgToolView.frame.size.width, _currentBottomRect.size.height);
        
        if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
            [_delegate msgToolView:self keyboardReset:CGRectMake(_recordView.frame.origin.x, _recordView.frame.origin.y - _currentBottomRect.size.height, _recordView.frame.size.width, _recordView.frame.size.height)];
        }
    }completion:^(BOOL finished){
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    keyboardDuration = animationDuration;
    
    bKeyboardUp = NO;
    
    if (!_bDragBack) {
        [self hideKeyboard];
    }
}


- (void)hideKeyboard{
    
    [UIView animateWithDuration:keyboardDuration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        
        if (bFaceClick) {
            self.frame = CGRectMake(0, screenHeight - _faceView.frame.size.height - _currentBottomRect.size.height, self.frame.size.width, _faceView.frame.size.height + _currentBottomRect.size.height);
            
            _faceView.frame = CGRectMake(0, self.frame.size.height - _faceView.frame.size.height, _faceView.frame.size.width, _faceView.frame.size.height);
            self.msgToolView.frame = CGRectMake(0, 0, self.msgToolView.frame.size.width, _currentBottomRect.size.height);
            bExpandClick = NO;
            bFristUp = NO;
            
            if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
                [_delegate msgToolView:self keyboardReset:CGRectMake(_faceView.frame.origin.x, _faceView.frame.origin.y - _defautlBottomRect.size.height, _faceView.frame.size.width, _faceView.frame.size.height)];
            }
            
        }else if (bExpandClick) {
            self.frame = CGRectMake(0, screenHeight - _expandView.frame.size.height - _currentBottomRect.size.height, self.frame.size.width, _expandView.frame.size.height + _currentBottomRect.size.height);
            
            _expandView.frame = CGRectMake(0, self.frame.size.height - _expandView.frame.size.height, _expandView.frame.size.width, _expandView.frame.size.height);
            self.msgToolView.frame = CGRectMake(0, 0, self.msgToolView.frame.size.width, _currentBottomRect.size.height);
            bFaceClick = NO;
            bFristUp = NO;
            
            if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
                [_delegate msgToolView:self keyboardReset:CGRectMake(_expandView.frame.origin.x, _expandView.frame.origin.y - _defautlBottomRect.size.height, _expandView.frame.size.width, _expandView.frame.size.height)];
            }
            
        }else if (bRecorderClick){
            self.frame = CGRectMake(0, screenHeight - _recordView.frame.size.height - _currentBottomRect.size.height, self.frame.size.width, _recordView.frame.size.height + _currentBottomRect.size.height);
            
            _recordView.frame = CGRectMake(0, self.frame.size.height - _recordView.frame.size.height, _recordView.frame.size.width, _recordView.frame.size.height);
            self.msgToolView.frame = CGRectMake(0, 0, self.msgToolView.frame.size.width, _currentBottomRect.size.height);
            
            bFaceClick = NO;
            bExpandClick = NO;
            
            if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
                [_delegate msgToolView:self keyboardReset:CGRectMake(_recordView.frame.origin.x, _recordView.frame.origin.y - _defautlBottomRect.size.height, _recordView.frame.size.width, _recordView.frame.size.height)];
            }
            
        }else {
            self.frame = CGRectMake(0, screenHeight - _currentBottomRect.size.height, self.frame.size.width, _currentBottomRect.size.height);
            
            CGFloat originY = bKeyboardUp?screenHeight - _currentBottomRect.size.height:0;
            self.msgToolView.frame = CGRectMake(0, 0, self.frame.size.width, _currentBottomRect.size.height);
            
            _faceView.frame = CGRectMake(0, screenHeight, _faceView.frame.size.width, _faceView.frame.size.height);
            _expandView.frame = CGRectMake(0, screenHeight, _expandView.frame.size.width, _expandView.frame.size.height);
            _recordView.frame = CGRectMake(0, screenHeight, _recordView.frame.size.width, _recordView.frame.size.height);
            
            if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
                [_delegate msgToolView:self keyboardReset:CGRectMake(keyboardRec.origin.x,  originY, keyboardRec.size.width, keyboardRec.size.height)];
            }
        }
        
    }completion:^(BOOL finished){
        
    }];
}


- (void)resignKeyboard{
    bFaceClick = NO;
    bExpandClick = NO;
    bRecorderClick = NO;
    bFristUp = YES;
    if (bKeyboardUp) {
        [_textView resignFirstResponder];
    }else{
        //出现face时点击背景
        [self restoreKeyboard:_currentBottomRect];
    }
}

- (void)restoreKeyboard:(CGRect)rect{
    
    [UIView animateWithDuration:keyboardDuration delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        
        self.frame = CGRectMake(0, screenHeight - rect.size.height, self.frame.size.width, rect.size.height);
        
        self.msgToolView.frame = CGRectMake(0, 0, self.frame.size.width, rect.size.height);
        _faceView.frame = CGRectMake(0, _faceView.frame.size.height, _faceView.frame.size.width, _faceView.frame.size.height);
        _expandView.frame = CGRectMake(0, _expandView.frame.size.height, _expandView.frame.size.width, _expandView.frame.size.height);
        _recordView.frame = CGRectMake(0, _recordView.frame.size.height, _recordView.frame.size.width, _recordView.frame.size.height);
        
        if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
            [_delegate msgToolView:self keyboardReset:CGRectMake(keyboardRec.origin.x, self.frame.size.height - rect.size.height , keyboardRec.size.width, keyboardRec.size.height)];
        }
    }completion:^(BOOL finished){
    }];
}

- (BOOL)checkKeyboardUp{
    return bKeyboardUp || bFaceClick || bRecorderClick || bExpandClick;
}


#pragma mark - Text View Delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = _textView.frame;
    r.size.height -= diff;
    _textView.frame = r;
    
    CGRect frame = self.frame;
    frame.origin.y += diff;
    frame.size.height -= diff;
    self.frame = frame;
    
    frame = self.msgToolView.frame;
    
    _currentBottomRect = frame;
    
    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
        [_delegate msgToolView:self keyboardReset:_currentBottomRect];
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView changeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardClicked:)]) {
        [_delegate msgToolView:self keyboardClicked:text];
    }
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    if (growingTextView.text.length <= 0) {
        _currentBottomRect = _defautlBottomRect;
    }
    [_faceView setfaceSendBtnEnable:growingTextView.text.length>0];
    
    if (bKeyboardUp) {
        
        self.frame = CGRectMake(0, keyboardRec.origin.y - _currentBottomRect.size.height, self.frame.size.width, keyboardRec.size.height + _currentBottomRect.size.height);
        self.msgToolView.frame = CGRectMake(0, self.frame.size.height - keyboardRec.size.height - _currentBottomRect.size.height, self.frame.size.width, _currentBottomRect.size.height);
        
    }

}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    return YES;
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView{
    
}

- (void)growingTextViewClickFinish:(HPGrowingTextView *)growingTextView{
    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:sendClicked:msgOrFileName:type:length:)]) {
        [_delegate msgToolView:self sendClicked:growingTextView msgOrFileName:growingTextView.text type:CIRCLE_CHAT_TYPE_TEXT length:0];
    }
}

#pragma mark - 表情单击事件
- (void)faceOnClickWithName:(NSString *)name {
    if (!TTIsStringWithAnyText(name)) return;
    
    [_textView insertText:name];
}

- (void)faceOnClickBackspace {
    NSString *text = _textView.text;
    if (!TTIsStringWithAnyText(text)) return;
    NSString *lastChar = [text substringFromIndex:text.length - 1];
    if ([@"]" isEqualToString:lastChar]) {
        NSRange range = [text rangeOfString:@"[" options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            _textView.text = [text substringToIndex:range.location];
            return;
        }
    }
    _textView.text = [text substringToIndex:text.length - 1];
}

- (void)faceOnClickSend{
    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:sendClicked:msgOrFileName:type:length:)]) {
        [_delegate msgToolView:self sendClicked:_textView msgOrFileName:_textView.text type:CIRCLE_CHAT_TYPE_TEXT length:0];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
        [_delegate msgToolView:self keyboardReset:CGRectMake(_faceView.frame.origin.x, _faceView.frame.origin.y - _defautlBottomRect.size.height, _faceView.frame.size.width, _faceView.frame.size.height)];
    }
}

#pragma mark - 拓展页
- (void)expandView:(CircleChatExpandView *)expandView image:(UIImage*)image{
    NSString *fileName = [UIImage createThumbImage:image userId:ROOTCONTROLLER_USER.userId size:image.size];
    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:sendClicked:msgOrFileName:type:length:)]) {
        [_delegate msgToolView:self sendClicked:_textView msgOrFileName:fileName type:CIRCLE_CHAT_TYPE_IMG length:0];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
        [_delegate msgToolView:self keyboardReset:CGRectMake(_expandView.frame.origin.x, _expandView.frame.origin.y - _defautlBottomRect.size.height, _expandView.frame.size.width, _expandView.frame.size.height)];
    }
}

- (void)expandViewOnPaper:(CircleChatExpandView *)expandView{
    
}

- (void)resetRole:(BOOL)bAdmin{
    self.expandView.bAdmin = bAdmin;
}

- (void)setPrivateChat:(BOOL)bPrivate{
    self.expandView.bPrivate = bPrivate;
}

#pragma mark - RecordView
- (void)recordView:(CircleChatRecordView *)recordView recordOnClickSend:(NSString*)fileName length:(NSInteger)length{
    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:sendClicked:msgOrFileName:type:length:)]) {
        [_delegate msgToolView:self sendClicked:_textView msgOrFileName:fileName type:CIRCLE_CHAT_TYPE_VOICE length:length];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(msgToolView:keyboardReset:)]) {
        [_delegate msgToolView:self keyboardReset:CGRectMake(_recordView.frame.origin.x, _recordView.frame.origin.y - _defautlBottomRect.size.height, _recordView.frame.size.width, _recordView.frame.size.height)];
    }
}
- (void)cleanRecordData{
    [_recordView clean];
}

-(void)dealloc{
    [self removeKeyboardObserver];
    [_msgToolView release];
    [_expandView release];
    [_faceView release];
    [_faceBtn release];
    [_recoderBtn release];
    [super dealloc];
}
@end
