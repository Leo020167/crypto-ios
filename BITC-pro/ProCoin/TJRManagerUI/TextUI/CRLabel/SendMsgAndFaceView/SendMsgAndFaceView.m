//
//  SendMsgAndFaceView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 13-4-13.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

// ////////////////////////////////////////////////////
//                      _ooOoo_                      //
//                     o8888888o                     //
//                     88" . "88                     //
//                     (| -_- |)                     //
//                     O\  =  /O                     //
//                  ____/`---'\____                  //
//                .'  \\|     |//  `.                //
//               /  \\|||  :  |||//  \               //
//              /  _||||| -:- |||||-  \              //
//              |   | \\\  -  /// |   |              //
//              | \_|  ''\---/''  |   |              //
//              \  .-\__  `-`  ___/-. /              //
//            ___`. .'  /--.--\  `. . __             //
//         ."" '<  `.___\_<|>_/___.'  >'"".          //
//        | | :  `- \`.;`\ _ /`;.`/ - ` : | |        //
//        \  \ `-.   \_ __\ /__ _/   .-` /  /        //
//   ======`-.____`-.___\_____/___.-`____.-'======   //
//                      `=---='                      //
//  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^    //
//               佛祖保佑       永无BUG                //
//                                                   //
// ////////////////////////////////////////////////////

#import "SendMsgAndFaceView.h"
#import "CommonUtil.h"
#import "TJRBaseViewController.h"

#define StockCellHeight			  35

#define FaceWidth				  36
#define FaceHeight				  34

#define keyboardCell			  @"KeyboardPortraitCell"

NSString *const SendMsgAndFaceDidChangeFrameNotification = @"SendMsgAndFaceDidChangeFrameNotification";
NSString *const SendMsgAndFaceWillShowNotification = @"SendMsgAndFaceWillShowNotification";
NSString *const SendMsgAndFaceHideEndNotification = @"SendMsgAndFaceHideEndNotification";
NSString *const SendMsgAndFaceFrameEndUserInfoKey = @"SendMsgAndFaceFrameEndUserInfoKey";
NSString *const SendMsgAndFaceViewKey = @"SendMsgAndFaceViewKey";
NSString *const SendMsgAndFaceViewSpecialKey = @"SendMsgAndFaceViewSpecialKey";
NSString *const SendMsgAndFaceViewSpecialObserverName = @"SendMsgAndFaceViewSpecialObserverName";

@implementation SendMsgAndFaceView

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
    phoneRect = [[UIScreen mainScreen] bounds];
	[[NSBundle mainBundle] loadNibNamed:@"SendMsgAndFaceView" owner:self options:nil];
	CGRect frame = self.msgView.frame;
	frame.origin = CGPointZero;
	frame.size = self.frame.size;
	self.msgView.frame = frame;
	[self addSubview:self.msgView];
    self.msgBackgroundImageView.frame = frame;
    self.msgBackgroundImageView.hidden = YES;
    self.textView.delegate = self;
    // textView里面的HPGrowingTextView会根据宽度计算最大行数，会自动改变textView的高度，可能会影响布局
    CGRect textViewRect =_textView.frame;
    textViewRect.size.width = self.frame.size.width - 30;
    self.textView.frame = textViewRect;
    
    CGRect canceRect =_btnCance.frame;
    canceRect.origin.x = 15;
    _btnCance.frame = canceRect;
    
    CGRect sendRect = _btnSendMsg.frame;
    sendRect.origin.x = self.frame.size.width - sendRect.size.width - 15;
    _btnSendMsg.frame = sendRect;
    
    CGRect faceRect = _btnAddFace.frame;
    faceRect.origin.x = sendRect.origin.x - sendRect.size.width - 6;
    _btnAddFace.frame = faceRect;
    
    CGRect recordRect = _btnRecord.frame;
    recordRect.origin.x = faceRect.origin.x - recordRect.size.width - 6;
    _btnRecord.frame = recordRect;
    // 取消UITextView的自我更正功能，避免输出各种烦人的系统Log
    _textView.internalTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    [self addKeyboardObserver];

    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    _allFaceView = [[TJRFaceView alloc] initWithFrame:CGRectMake(0, 0, width, 216)];
    _allFaceView.delegate = self;
    _bottomCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, phoneHeight, width, IPHONEX_BOTTOM_HEIGHT)];
    _bottomCoverView.backgroundColor = [UIColor colorWithRed:229.0/255 green:229.0/255 blue:229.0/255 alpha:1.0];
    _bottomCoverView.hidden = YES;
    recordView = [[TJRRecordView alloc] initWithFrame:CGRectMake(0, 0, width, 180)];
	recordView.delegate = self;
	maxNumberOfLines = 1;
	minNumberOfLines = 1;
	isFirst = YES;
	[self interfaceChange];
    [CommonUtil viewMasksToBounds:_btnSendMsg cornerRadius:3.5f borderColor:RGBA (204, 204, 204, 1)];
    [CommonUtil viewMasksToBounds:_textView cornerRadius:3.5f borderColor:nil];
	_textView.textCountLabel.hidden = YES;
	/* _textView.returnKeyType = UIReturnKeySend; */
//    [_textView setIsCanPaste:NO];

    [_btnSendMsg setBackgroundImage:[CommonUtil createImageWithColor:RGBA(88, 192, 235, 1) withViewForSize:_btnSendMsg] forState:UIControlStateSelected];
    
}

/**
 *    添加键盘的监听(在viewDidAppear里加上)
 */
- (void)addKeyboardObserver {
	if (isAddObserver) return;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideKeyboardView) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboardView) name:UIKeyboardWillHideNotification object:nil];
	isAddObserver = YES;
}

/**
 *    移除键盘监听(在viewDidDisappear里加上)
 */
- (void)removeKeyboardObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	isAddObserver = NO;
}

/**
 *   隐藏语音按钮
 *   @param isHide
 */
- (void)hideRecordButton:(BOOL)isHide {
	_btnRecord.hidden = isHide;

//    if (isHide) {
//        hideRecordChangeWidth = _btnAddFace.frame.origin.x - _btnRecord.frame.origin.x;
//        CGRect frame = _textView.frame;
//        frame.origin.x -= hideRecordChangeWidth;
//        frame.size.width += hideRecordChangeWidth;
//        _textView.frame = frame;
//
//        frame = _btnAddFace.frame;
//        frame.origin.x = _btnRecord.frame.origin.x;
//        _btnAddFace.frame = frame;
//    } else {
//        CGRect frame = _btnAddFace.frame;
//        frame.origin.x = 45;
//        _btnAddFace.frame = frame;
//
//        frame = _textView.frame;
//        frame.origin.x += hideRecordChangeWidth;
//        frame.size.width -= hideRecordChangeWidth;
//        _textView.frame = frame;
//    }
}

/**
 *   隐藏发送按钮
 *   @param isHide
 */
- (void)hideSendButton:(BOOL)isHide {
    _btnSendMsg.hidden = isHide;
    
        if (isHide) {
            CGFloat changeWidth = CGRectGetMaxX(_btnSendMsg.frame) - CGRectGetMaxX(_btnAddFace.frame);
            CGRect frame = _btnAddFace.frame;
            frame.origin.x += changeWidth;
            _btnAddFace.frame = frame;
    
            frame = _btnRecord.frame;
            frame.origin.x += changeWidth;
            _btnRecord.frame = frame;
        } else {
            CGFloat changeWidth = CGRectGetMaxX(_btnSendMsg.frame) - CGRectGetMaxX(_btnAddFace.frame);
            if (changeWidth ==  0) {
                changeWidth = CGRectGetWidth(_btnSendMsg.frame) + 6;
                CGRect frame = _btnAddFace.frame;
                frame.origin.x -= changeWidth;
                _btnAddFace.frame = frame;
                
                frame = _btnRecord.frame;
                frame.origin.x -= changeWidth;
                _btnRecord.frame = frame;
            }

        }
}



- (void)setUserId:(NSString *)userId {
	RELEASE(_userId);
	_userId = [userId copy];
	recordView.userId = userId;
}

#pragma mark - 监听输入的数字或拼音是否为股票(默认为NO)
- (void)setMonitorInputStock:(BOOL)monitorInputStock {
	_monitorInputStock = monitorInputStock;
	stockIndex = NSNotFound;
	RELEASE(inputStock);
	inputStock = nil;

	if (monitorInputStock) {
		self.showStockMaxRow = 2;

		if (!self.tvStock) {
			CGRect frame = self.frame;
			frame.size.height = 0;
			_tvStock = [[UITableView alloc] initWithFrame:frame];
			_tvStock.delegate = self;
			_tvStock.dataSource = self;
		}

		
	} else {
		RELEASE(_tvStock);
		_tvStock = nil;
	}
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	phoneWidth = newSuperview.frame.size.width;
	phoneHeight = newSuperview.frame.size.height;
}

- (void)didMoveToSuperview {
	[super didMoveToSuperview];
	[self.superview addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([@"frame" isEqualToString:keyPath]) {
		phoneWidth = self.superview.frame.size.width;
		phoneHeight = self.superview.frame.size.height;

		if (phoneWidth != self.allFaceView.frame.size.width) {
			CGRect frame = self.allFaceView.frame;
			frame.size.height = 99;
			frame.size.width = phoneWidth;
			self.allFaceView.frame = frame;
		}
	}
}

- (void)removeFromSuperview {
	[self.superview removeObserver:self forKeyPath:@"frame" context:nil];
	[super removeFromSuperview];
}

- (void)interfaceChange {
	if (!isFirst && (isLandscape == (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) ||	/* 横屏 */
				([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft)))) return;

	isFirst = NO;

	if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) ||	/* 横屏 */
		([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft)) {
		if (phoneWidth == 0) phoneWidth = MAX(UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width);

		if (phoneHeight == 0) phoneHeight = MIN(UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width);;
		CGRect frame = self.allFaceView.frame;
		frame.size.height = 99;
		frame.size.width = phoneWidth;
		self.allFaceView.frame = frame;
		isLandscape = YES;
	} else {/* 竖屏 */
		if (phoneWidth == 0) phoneWidth = UIScreen.mainScreen.bounds.size.width;

		if (phoneHeight == 0) phoneHeight = UIScreen.mainScreen.bounds.size.height;
		isLandscape = NO;
	}

	[self cellBackgroundBtnColor:self.btnFirstItem];
	[self cellBackgroundBtnColor:self.btnSecondItem];
	[self cellBackgroundBtnColor:self.btnThirdItem];
}

- (void)cellBackgroundBtnColor:(UIButton *)sender {
	[sender addTarget:self action:@selector(doSomething:) forControlEvents:UIControlEventTouchUpInside];
	[sender addTarget:self action:@selector(setBgColorForButton:) forControlEvents:UIControlEventTouchDown];
	[sender addTarget:self action:@selector(clearBgColorForButton:) forControlEvents:(UIControlEventTouchDragExit | UIControlEventTouchUpOutside | UIControlEventTouchDragOutside | UIControlEventTouchCancel)];
}

- (void)setBgColorForButton:(UIButton *)sender {
	[sender setBackgroundColor:RGBA(89, 189, 228, 0.5)];
}

- (void)clearBgColorForButton:(UIButton *)sender {
	[sender setBackgroundColor:[UIColor whiteColor]];
}

- (void)doSomething:(UIButton *)sender {
	double delayInSeconds = 0.2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));

	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			[self clearBgColorForButton:sender];
		});
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

/**
 *   设置显示按钮,背景等,有需求自己加
 *   @param type 类型(有需求自己加)
 */
- (void)setShowType:(SendMsgAndFaceViewShowType)type {
	switch (type) {
		case SendMsgAndFaceViewShowType_StockTalk:
			{
                [_btnRecord setImage:[UIImage imageNamed:@"chat_mic"] forState:UIControlStateNormal];
//				_btnRecord.hidden = YES;// 先把原来的录音按钮隐藏，再做下面的逻辑
//				UIButton *micBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//				micBtn.tag = 1000;
//				[micBtn setFrame:CGRectMake(7.0, 7.0, 35, 35)];
//				[micBtn setBackgroundImage:[UIImage imageNamed:@"chat_mic"] forState:UIControlStateNormal];
//				[micBtn addTarget:self action:@selector(customButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
//				[_btnAddFace setFrame:CGRectMake(48, 7.0, 39, 35)];
//				[_textView setFrame:CGRectMake(93, 7.0, 159, 31)];
//				[_textView setLimitLabelFrameWithTextViewWidth:_textView.frame.size.width toLeftPoint:100];
//				[_msgView addSubview:micBtn];
			}
			break;

		default:
			break;
	}
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView {
	return YES;
}

- (void)growingTextViewClickFinish:(HPGrowingTextView *)growingTextView {
    
    if (_delegate && [_delegate respondsToSelector:@selector(btnKeyboardClickFinish)]) {
		[_delegate btnKeyboardClickFinish];
    
    } else if (_delegate && [_delegate respondsToSelector:@selector(btnSendMsgOnClick:msgOrFileName:isVoice:length:)]) {
        [self.delegate btnSendMsgOnClick:_btnSendMsg msgOrFileName:self.textView.text isVoice:NO length:self.textView.count];
    }else {
		/* if (self.textView.hasText) {
		 *    [self btnSendMsgAction:nil];
		 *   } else {
		 *   } */
        [self hideFaceViewAndKeyboard];

	}
}

- (void)setBtnSendMsgEnabled:(BOOL)isEnabled {
	_btnSendMsg.enabled = isEnabled;
	_btnSendMsg.selected = isEnabled;
}

- (void)TJRRecordViewRecordFinish:(BOOL)isSaveFile {
	[self setBtnSendMsgEnabled:isSaveFile];
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    
    NSString* text = growingTextView.text;
    
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];//截取汉字拼音特殊字符（中间并不是空格）
    
	[self setBtnSendMsgEnabled:(growingTextView.text && growingTextView.text.length > 0)];

	if (self.monitorInputStock) {
		if ((stockIndex != NSNotFound) && (stockIndex < text.length)) {
			inputStock = [[text substringFromIndex:stockIndex] copy];

			if (inputStock.length > 6) {
				return [self clearMonitorInputStockWithSearch:YES];
			}
		} else {
			inputStock = @"";
		}
		[self searchString:inputStock];
	}
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(SendMsgAndFaceView:textViewDidChange:)]) {
        [self.delegate SendMsgAndFaceView:self textViewDidChange:growingTextView];
    }
    
}

- (void)postNotificationForSpecial:(NSString *)specialS {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:specialS,SendMsgAndFaceViewSpecialKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SendMsgAndFaceViewSpecialObserverName object:nil userInfo:dic];
}

#pragma mark - 判断输入的数字是否为股票
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (_specialObserverKeyArray && [_specialObserverKeyArray containsObject:text]) {
        [self performSelector:@selector(postNotificationForSpecial:) withObject:text afterDelay:0.1];
        return YES;
    }
    if (self.monitorInputStock && TTIsStringWithAnyText(text)) {
		if ([CommonUtil isMatched:text byRegex:@"^[0-9]{1,6}$"]) {	/* 输入数字 */
			if (!TTIsStringWithAnyText(inputStock)) {
				if (lastStockInputType % 31 != 0) {	/* 当上一次输入英文 */
					[self clearMonitorInputStockWithSearch:YES];
				}
				stockIndex = range.location;
				lastStockInputType = 31;
			}
		} else if ([CommonUtil isMatched:text byRegex:@"^[A-Za-z]+$"]) {/* 输入英文 */
			if (!TTIsStringWithAnyText(inputStock)) {
				if (lastStockInputType % 32 != 0) {	/* 当上一次输入数字 */
					[self clearMonitorInputStockWithSearch:YES];
				}
				stockIndex = range.location;
				lastStockInputType = 32;
			}
		} else {
			if (lastStockInputType > 0) {
				[self clearMonitorInputStockWithSearch:YES];
			}
		}
	}
    if ([text isEqualToString:@"\r\r"]) {
        return NO; // 当不需要换行时，返回NO；
    }
    
	if ([text isEqualToString:@"\n"]) {
		[self growingTextViewClickFinish:growingTextView];
		return NO; // 当不需要换行时，返回NO；
	}
	return YES;
}

- (NSLayoutConstraint *)heightConstraint {
    if (!heightConstraint) {
        for (NSLayoutConstraint *lc in self.constraints) {
            if (lc.firstAttribute == NSLayoutAttributeHeight && lc.firstItem == self) {
                heightConstraint = lc;
                break;
            }
        }
    }
    return heightConstraint;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
	float diff = (growingTextView.frame.size.height - height);
	CGRect r = _textView.frame;

	r.size.height -= diff;
	_textView.frame = r;

	CGRect frame = self.msgView.frame;
	frame.origin = CGPointZero;
	frame.size.height -= diff;
	self.msgView.frame = frame;

    if (self.translatesAutoresizingMaskIntoConstraints) {
        frame = self.frame;
        frame.origin.y += diff;
        frame.size.height -= diff;
        self.frame = frame;
    } else {
        self.heightConstraint.constant -= diff;
    }
	NSValue *frameValue = [NSValue valueWithCGRect:self.frame];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self, SendMsgAndFaceViewKey, frameValue, SendMsgAndFaceFrameEndUserInfoKey, nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:SendMsgAndFaceDidChangeFrameNotification object:nil userInfo:userInfo];
}

- (void)setInputType:(DefaultInputItemType)inputType {
    _inputType = inputType;
    
    if (_inputType != DefaultInputItemType_NONe) {	/* 快捷输入文字 */
        if (!_defaultInputItemView.superview && self.superview) {
            [self.superview addSubview:_defaultInputItemView];
        }
        CGRect frame = _defaultInputItemView.frame;
        frame.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(frame)) / 2;
        frame.origin.y = CGRectGetMinY(self.frame) - CGRectGetHeight(frame);
        _defaultInputItemView.frame = frame;
    }
    _defaultInputItemView.hidden = (inputType == DefaultInputItemType_NONe);
}

#pragma mark - 默认输入项的按钮事件
- (IBAction)inputItemAction:(UIButton *)sender {
	self.textView.text = [sender titleForState:UIControlStateNormal];
    [self hideFaceViewAndKeyboard];
	[self btnSendMsgAction:self.btnSendMsg];
}

#pragma mark - 去掉字符串里所有的Emoji表情
- (NSString *)removeEmojiFromString:(NSString *)string {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:string
                                                               options:0
                                                                 range:NSMakeRange(0, [string length])
                                                          withTemplate:@""];
    return modifiedString;
    
    if (!string) return @"";

	__block NSMutableString *temp = [NSMutableString string];

	[string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
		^(NSString * substring, NSRange substringRange, NSRange enclosingRange, BOOL * stop) {
			const unichar hs = [substring characterAtIndex:0];

			if (0xd800 <= hs && hs <= 0xdbff) {
				const unichar ls = [substring characterAtIndex:1];
				const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;

				[temp appendString:(0x1d000 <= uc && uc <= 0x1f77f) ? @"":substring];
			} else {
				[temp appendString:(0x2100 <= hs && hs <= 0x26ff) ? @"":substring];
			}
		}];

	return temp;
}

#pragma mark - 发表
- (IBAction)btnSendMsgAction:(UIButton *)sender {
	[self clearMonitorInputStockWithSearch:YES];

	if (recordView.isHasRecordFile) {	/* 当前有语音文件 */
		NSString *fileName = [recordView getMp3FileName];

		if (TTIsStringWithAnyText(fileName)) {
			if (self.delegate && [self.delegate respondsToSelector:@selector(btnSendMsgOnClick:msgOrFileName:isVoice:length:)]) {
				[self.delegate btnSendMsgOnClick:_btnSendMsg msgOrFileName:fileName isVoice:YES length:[recordView recordTimeLength]];
			}
		}
	} else {
		/* self.textView.text = [self removeEmojiFromString:self.textView.text]; */
		self.textView.text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		if (self.delegate && [self.delegate respondsToSelector:@selector(btnSendMsgOnClick:msgOrFileName:isVoice:length:)]) {
			[self.delegate btnSendMsgOnClick:_btnSendMsg msgOrFileName:self.textView.text isVoice:NO length:self.textView.count];
		}
	}
}

/**
 *   将当前语音保存到缓存
 *   @param url  语音url
 */
- (void)saveVoiceToCacheWithUrl:(NSString *)url {
	[recordView saveVoiceToCacheWithUrl:url];
}

/**
 *    清除所有的语音文件和文字
 */
- (void)cleanRecordVoiceFileAndText {
	[recordView deleteRecordFile];	/* 删除当前的语音文件 */
	_textView.text = @"";
}

#pragma mark - 隐藏表情和键盘

/**
 *    隐藏表情和键盘
 */
- (void)hideFaceViewAndKeyboard {
    switch (keyboardType) {
        case SendMsgAndFaceViewKeyboardType_Txet:
            keyboardType = SendMsgAndFaceViewKeyboardType_Hide;
            [_textView resignFirstResponder];
            [self hideKeyboardView];
            [self clearMonitorInputStockWithSearch:YES];
            break;
        case SendMsgAndFaceViewKeyboardType_Face:
        case SendMsgAndFaceViewKeyboardType_Voice:
            [self hideFaceViewOrVoiceView];
            keyboardType = SendMsgAndFaceViewKeyboardType_Hide;
            [self hideKeyboardView];
        default:
            break;
    }
}

#pragma mark - 取消按钮
- (IBAction)btnCanceAction:(UIButton *)sender {
    [self hideFaceViewAndKeyboard];
}

#pragma mark - 语音按钮
- (IBAction)btnRecordAction:(UIButton *)sender {
	if (self.delegate && [self.delegate respondsToSelector:@selector(btnVoiceOnClick:voiceViewIsShow:)]) {
		[self.delegate btnVoiceOnClick:sender voiceViewIsShow:!sender.selected];
    } else {
//        [self showOrHideVoiceView:!sender.selected];
        if (sender.isSelected) {
            [_textView becomeFirstResponder];
        } else {
            sender.selected = !sender.isSelected;
            [self showFaceViewOrVoiceViewWithType:SendMsgAndFaceViewKeyboardType_Voice];
        }
    }
}

#pragma mark - 添加表情按钮
- (IBAction)btnAddFaceAction:(UIButton *)sender {
    if (sender.isSelected) {
        [_textView becomeFirstResponder];
    } else {
        sender.selected = !sender.isSelected;
        [self showFaceViewOrVoiceViewWithType:SendMsgAndFaceViewKeyboardType_Face];
    }

	if (self.delegate && [self.delegate respondsToSelector:@selector(btnAddFaceOnClick:faceViewIsShow:)]) {
		[self.delegate btnAddFaceOnClick:_btnAddFace faceViewIsShow:!sender.selected];
    }
}

#pragma mark - 显示或隐藏表情界面
/**
 *  显示键盘
 */
- (void)showKeyboard {
    [self hideFaceViewOrVoiceView];
    [_textView becomeFirstResponder];
}


/**
 *    显示或隐藏表情界面
 *    @param isShowFace 显示或隐藏
 */
- (void)showOrHideFaceView:(BOOL)isShowFace {
//	if (recordView.isHasRecordFile) {
//        if (isShowKeyboard) {
//            [self showDelRecordAlertViewWithTag:0];
//        }
//        return;
//	}
//	_textView.userInteractionEnabled = YES;
//	lastKeyboardType = keyboardType;
//	keyboardType = SendMsgAndFaceViewKeyboardType_Change;
	_btnAddFace.selected = isShowFace;

	if (isShowFace) {	/* 显示表情 */
        [self showFaceViewOrVoiceViewWithType:SendMsgAndFaceViewKeyboardType_Face];
//		if (_btnRecord.selected) {
//			_btnRecord.selected = NO;
//		}
//
//		_textView.internalTextView.inputView = self.allFaceView;
//
//		if (lastKeyboardType == SendMsgAndFaceViewKeyboardType_NotShow) {
//			[_textView becomeFirstResponder];
//		} else {
//			[_textView.internalTextView reloadInputViews];
//		}
	} else {/* 关闭表情 */
        [self hideFaceViewOrVoiceView];
//		_textView.internalTextView.inputView = nil;
//
//		if (lastKeyboardType != SendMsgAndFaceViewKeyboardType_NotShow) {
//			[_textView.internalTextView reloadInputViews];
//		}
//        [_textView becomeFirstResponder];
	}
}

#pragma mark - 显示或隐藏语音界面

/**
 *    显示或隐藏语音界面
 *    @param isShowVoice
 */
- (void)showOrHideVoiceView:(BOOL)isShowVoice {
    if (isShowVoice) {
        [self showFaceViewOrVoiceViewWithType:SendMsgAndFaceViewKeyboardType_Voice];
//		if (_textView.count > 0) {
//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"删除文字" message:@"是否删除当前输入的文字?" delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"取消") otherButtonTitles:NSLocalizedStringForKey(@"删除"), nil];
//			alertView.tag = 1111;
//			[alertView show];
//			RELEASE(alertView);
//			return;
//		}
//
//		if (_btnAddFace.selected) _btnAddFace.selected = NO;
//        [self showFaceViewOrVoiceView:NO];
        
//		_textView.userInteractionEnabled = NO;
//		lastKeyboardType = keyboardType;
//		keyboardType = SendMsgAndFaceViewKeyboardType_Change;
//
//		_textView.internalTextView.inputView = recordView;
//		[_textView becomeFirstResponder];
//		[_textView.internalTextView reloadInputViews];
	} else {
        [self hideFaceViewOrVoiceView];
//		if (recordView.isHasRecordFile) {
//            [self showDelRecordAlertViewWithTag:2222];
//			return;
//		}
//        [self hideFaceViewOrVoiceView:NO];
//		[self showOrHideFaceView:NO];
	}
	_btnRecord.selected = isShowVoice;
}

- (void)showDelRecordAlertViewWithTag:(NSUInteger)tag {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"删除语音" message:@"是否删除当前的语音?" delegate:self cancelButtonTitle:NSLocalizedStringForKey(@"取消") otherButtonTitles:NSLocalizedStringForKey(@"删除"), nil];
    alertView.tag = tag;
    [alertView show];
    RELEASE(alertView);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.firstOtherButtonIndex) {
		if (alertView.tag == 1111) {/* 删除文字 */
			_textView.text = @"";
			[self btnRecordAction:_btnRecord];
		} else {/* 删除语音 */
			[recordView deleteRecordFile];
			if (alertView.tag == 2222) {
				[self btnRecordAction:_btnRecord];
            } else if (alertView.tag == 3333) {
                [self hideFaceViewAndKeyboard];
            } else {
				[self btnAddFaceAction:_btnAddFace];
			}
		}
	}
}

#pragma mark - 表情和键盘是否都隐藏
- (BOOL)isFaceAndKeyboardAllHide {
	return keyboardType == SendMsgAndFaceViewKeyboardType_Hide;
}

#pragma mark - 显示键盘调整页面
- (void)keyboardWillShow:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:SendMsgAndFaceWillShowNotification object:nil userInfo:nil];
	NSDictionary *userInfo = [notification userInfo];

	NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];

	keyboardRect = [aValue CGRectValue];
	keyboardRect = [self convertRect:keyboardRect fromView:nil];

	if ((maxNumberOfLines != 1) || (minNumberOfLines != 1)) {	/* 不为1行时会出问题,所以要重设 */
		self.textView.minNumberOfLines = minNumberOfLines;
		self.textView.maxNumberOfLines = maxNumberOfLines;
	}

//	if (keyboardType == SendMsgAndFaceViewKeyboardType_NotShow) {
//		lastKeyboardType = keyboardType;
//		keyboardType = SendMsgAndFaceViewKeyboardType_Txet;
//	}
    if (keyboardType == SendMsgAndFaceViewKeyboardType_Face ||
        keyboardType == SendMsgAndFaceViewKeyboardType_Voice) {
        [self hideFaceViewOrVoiceView];
    }
    [self showTextKeyboardView];
}

- (void)showTextKeyboardView {
	if ((defaultFrame.size.height == 0) || (defaultFrame.size.height > self.frame.size.height)) {
		defaultFrame = self.frame;
	}
    if (_inputType != DefaultInputItemType_NONe) {	/* 快捷输入文字 */
        if (!_defaultInputItemView.superview && self.superview) {
            [self.superview addSubview:_defaultInputItemView];
        }
        CGRect frame = _defaultInputItemView.frame;
        frame.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(frame)) / 2;
        frame.origin.y = CGRectGetMinY(self.frame) - CGRectGetHeight(frame);
        _defaultInputItemView.frame = frame;
    }
	[UIView animateWithDuration:0.25 delay:0
						options:UIViewAnimationOptionTransitionNone
					 animations:^{
        [self changeFrameWithRect:keyboardRect];

        if (self.monitorInputStock) {	/* 查询股票 */
            if (!(self.tvStock.superview) && self.superview) {
                [self.superview addSubview:self.tvStock];
            } else {
                CGRect frame = self.tvStock.frame;
                if (frame.origin.y != self.frame.origin.y - frame.size.height - _stockViewIsolationHeight) {
                    frame.size.height = MIN(_showStockMaxRow, queryResult.count) * StockCellHeight;
                    frame.origin.y = self.frame.origin.y - frame.size.height - _stockViewIsolationHeight;
                    self.tvStock.frame = frame;
                }
            }
        }
        [self showOrHideDefaultInputView:NO];
    } completion:^(BOOL finished) {
        keyboardType = SendMsgAndFaceViewKeyboardType_Txet;
        [self postFameWithNotification];
    }];
}

/**
 *  显示表情键盘或者语音键盘
 *
 *  @param type 当前显示的键盘
 */
- (void)showFaceViewOrVoiceViewWithType:(SendMsgAndFaceViewKeyboardType)type {
    if (type == SendMsgAndFaceViewKeyboardType_Voice || type == SendMsgAndFaceViewKeyboardType_Face) {
        UIView *showView = type == SendMsgAndFaceViewKeyboardType_Face ? _allFaceView : recordView;
        [self hideFaceViewOrVoiceView];
        if (type == SendMsgAndFaceViewKeyboardType_Voice) {
            RELEASE(textViewString);
            textViewString = [_textView.text copy];
            _textView.text = @"";
        }
        CGRect frame = showView.frame;
        frame.origin.y = CGRectGetHeight(phoneRect);
        showView.frame = frame;
        if (!showView.superview) {
            TJRBaseViewController *viewController = [CommonUtil getControllerWithContainView:self];
            [viewController.view addSubview:showView];
        }
        if (iPhoneX && !_bottomCoverView.superview) {
            TJRBaseViewController *viewController = [CommonUtil getControllerWithContainView:self];
            [viewController.view addSubview:_bottomCoverView];
        }
        [UIView animateWithDuration:0.25 animations:^{
            //  iPHONE X有底部栏，将表情视图往上移动状态栏的高度，改变输入框位置时要加上底部栏高度
            CGRect frame = showView.frame;
            frame.origin.y = CGRectGetHeight(phoneRect) - CGRectGetHeight(frame) - IPHONEX_BOTTOM_HEIGHT;
            showView.frame = frame;
            if (iPhoneX) {
                CGRect rect = _bottomCoverView.frame;
                rect.origin.y = phoneHeight - IPHONEX_BOTTOM_HEIGHT;
                _bottomCoverView.frame = rect;
                _bottomCoverView.hidden = NO;
            }
            frame.size.height += IPHONEX_BOTTOM_HEIGHT;
            [self changeFrameWithRect:frame];
            [self postFameWithNotification];
        } completion:^(BOOL finished) {
            keyboardType = type;
        }];
    }
}

/**
 *  隐藏表情键盘或者语音键盘
 *
 *  @param isFaceView 当前隐藏的是否是表情键盘
 */
- (void)hideFaceViewOrVoiceView {
    UIView *hideView = nil;
    if (keyboardType == SendMsgAndFaceViewKeyboardType_Face) {
        _btnAddFace.selected = NO;
        hideView = _allFaceView;
    } else if (keyboardType == SendMsgAndFaceViewKeyboardType_Txet) {
        [_textView resignFirstResponder];
    } else if (keyboardType == SendMsgAndFaceViewKeyboardType_Voice) {
        _textView.text = textViewString;
        if (recordView.isHasRecordFile) [recordView deleteRecordFile];
        _btnRecord.selected = NO;
        hideView = recordView;
    }
    if (hideView) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = hideView.frame;
            frame.origin.y = CGRectGetHeight(phoneRect);
            hideView.frame = frame;
            if (iPhoneX) {
                CGRect coverFrame = _bottomCoverView.frame;
                coverFrame.origin.y = CGRectGetHeight(phoneRect);
                _bottomCoverView.frame = coverFrame;
            }
            [self postFameWithNotification];
        } completion:^(BOOL finished) {
            [hideView removeFromSuperview];
            if (iPhoneX) {
                _bottomCoverView.hidden = YES;
                [_bottomCoverView removeFromSuperview];
            }
            if (keyboardType == SendMsgAndFaceViewKeyboardType_Hide) {
                [self animationDidStop:nil finished:nil context:nil];
            }
        }];
    }
}

/**
 *  通过通知发布当前的frame
 */
- (void)postFameWithNotification {
    NSValue *frameValue = [NSValue valueWithCGRect:self.frame];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self, SendMsgAndFaceViewKey, frameValue, SendMsgAndFaceFrameEndUserInfoKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SendMsgAndFaceDidChangeFrameNotification object:nil userInfo:userInfo];
    
}

- (void)changeFrameWithRect:(CGRect)rect {
    if (self.translatesAutoresizingMaskIntoConstraints) {
        CGRect frame = self.frame;
        
        CGFloat y = 0;
        CGFloat temp = 0;
        if (self.superview) {
            CGRect rect = [ROOTCONTROLLER.view convertRect:self.superview.frame toView:ROOTCONTROLLER.view];
            temp = CGRectGetHeight([[UIScreen mainScreen] bounds]) - CGRectGetMaxY(rect);
        }
        y = CGRectGetHeight(self.superview.frame) - CGRectGetHeight(rect) + temp;
        frame.origin.y = y - CGRectGetHeight(frame);
        self.frame = frame;
    } else {
        if (!bottomConstraint) {
            for (NSLayoutConstraint *c in self.superview.constraints) {
                if ((c.firstItem == self || c.secondItem == self) &&
                    c.firstAttribute == NSLayoutAttributeBottom) {
                    bottomConstraint = c;
                    if (self.isOutOfBottom) outBottomHeight = c.constant;
                    break;
                }
            }
        }
        bottomConstraint.constant = CGRectGetHeight(rect);
        
        [self setNeedsUpdateConstraints];
        [self.superview layoutIfNeeded];
    }
	
}

#pragma mark - 显示或隐藏默认输入项
- (void)showOrHideDefaultInputView:(BOOL)isHide {
	CGRect frame = _defaultInputItemView.frame;

	frame.origin.y = self.frame.origin.y - frame.size.height;
	_defaultInputItemView.frame = frame;

	if (isHide) {
		_defaultInputItemView.hidden = YES;
	} else {
		if (_inputType != DefaultInputItemType_NONe) {
			_defaultInputItemView.hidden = NO;

			if (lastInputType != _inputType) {
				switch (_inputType) {
					case DefaultInputItemType_AddStock :
						[self.btnFirstItem setTitle:@"为什么突然看好这股票?" forState:UIControlStateNormal];
						[self.btnSecondItem setTitle:@"是不是收到这股票的消息?" forState:UIControlStateNormal];
						[self.btnThirdItem setTitle:@"这股票炒什么题材的?" forState:UIControlStateNormal];
						break;

					case DefaultInputItemType_DelStock :
						[self.btnFirstItem setTitle:@"为什么突然删了这股票？" forState:UIControlStateNormal];
						[self.btnSecondItem setTitle:@"不看好这股票了？" forState:UIControlStateNormal];
						[self.btnThirdItem setTitle:@"是不是听到了什么利空？" forState:UIControlStateNormal];
						break;

					case DefaultInputItemType_DaZhang:
						[self.btnFirstItem setTitle:@"恭喜你又赚钱啦!" forState:UIControlStateNormal];
						[self.btnSecondItem setTitle:@"什么时候请客?" forState:UIControlStateNormal];
						[self.btnThirdItem setTitle:@"这股票为什么突然大涨?" forState:UIControlStateNormal];
						break;

					default:
						break;
				}

				lastInputType = _inputType;
			}
		}
	}
}

#pragma mark - 隐藏键盘调整页面

- (void)notifacationHideKeyboardView {
	[self.textView resignFirstResponder];
	[self animationDidStop:nil finished:nil context:nil];
}

/**
 *    隐藏键盘调整页面
 */
- (void)hideKeyboardView {
      if (keyboardType != SendMsgAndFaceViewKeyboardType_Hide) return;
    [UIView animateWithDuration:0.25 animations:^{
        if (self.translatesAutoresizingMaskIntoConstraints) {
            CGRect frame = self.frame;
            
            if (self.isOutOfBottom) {
                frame.origin.y = defaultFrame.origin.y;
            } else {
                frame.origin.y += keyboardRect.size.height;
            }
            self.frame = frame;
        } else {
            bottomConstraint.constant = outBottomHeight;
            [self setNeedsUpdateConstraints];
            [self.superview layoutIfNeeded];
        }
        [self postFameWithNotification];
        [self showOrHideDefaultInputView:YES];
    } completion:^(BOOL finished) {	/* 键盘隐藏动画完毕 */
        if (keyboardType == SendMsgAndFaceViewKeyboardType_Hide) {
            [self animationDidStop:nil finished:nil context:nil];
        }
    }];
}
/**
 *   键盘已隐藏，调整页面（用于解决用户使用第三方键盘时输入框没有正常收起的问题）
 */
- (void)didHideKeyboardView {
    if (keyboardType == SendMsgAndFaceViewKeyboardType_Txet && bottomConstraint.constant >0){

        [UIView animateWithDuration:0 animations:^{
            if (self.translatesAutoresizingMaskIntoConstraints) {
                CGRect frame = self.frame;

                if (self.isOutOfBottom) {
                    frame.origin.y = defaultFrame.origin.y;
                } else {
                    frame.origin.y += keyboardRect.size.height;
                }
                self.frame = frame;
            } else {
                bottomConstraint.constant = outBottomHeight;
                [self setNeedsUpdateConstraints];
                [self.superview layoutIfNeeded];
            }
            [self postFameWithNotification];
            [self showOrHideDefaultInputView:YES];
        } completion:^(BOOL finished) {    /* 键盘隐藏动画完毕 */
                [self animationDidStop:nil finished:nil context:nil];
        }];
    }
}

- (void)dealloc {
    RELEASE(textViewString);
    RELEASE(_specialObserverKeyArray);
	recordView.delegate = nil;
	RELEASE(recordView);
	_allFaceView.delegate = nil;
	RELEASE(queryResult);
	RELEASE(pastInputStock);
	RELEASE(_tvStock);
	RELEASE(inputStock);
	self.delegate = nil;
	[self removeKeyboardObserver];
	[_msgView release];
	[_allFaceView release];
    [_bottomCoverView release];
	[_btnAddFace release];
	[_btnSendMsg release];
	[_msgBackgroundImageView release];
	[_textView release];
	[_defaultInputItemView release];
	[_btnFirstItem release];
	[_btnSecondItem release];
	[_btnThirdItem release];
	[_btnRecord release];
    [_btnCance release];
    [super dealloc];
}

#pragma mark - 自定义按钮点击事件
- (void)customButtonEvent:(id)sender {
	UIButton *customBtn = (UIButton *)sender;

	if (self.delegate && [self.delegate respondsToSelector:@selector(customButtonPressedEvent:)]) {
		[self.delegate customButtonPressedEvent:customBtn.tag];
	}
}

#pragma mark - 动画完成调用函数
- (void)animationDidStop:(NSString *)animationId finished:(NSNumber *)finished context:(void *)context {
	/* 当键盘隐藏动画完毕 */
	[[NSNotificationCenter defaultCenter] postNotificationName:SendMsgAndFaceHideEndNotification object:nil userInfo:nil];
}

#pragma mark - 显示要查询的字符
- (void)searchString:(NSString *)text {
	if (pastInputStock && [pastInputStock isEqualToString:text]) return;	/* 如果这次输入和上次输入相同,就不再查询 */

	if ([CommonUtil isMatched:text byRegex:@"^[0-9]{1,6}$"]) {	/* 输入数字 */
		[self updateQueryResult:text type:0];
	} else if ([CommonUtil isMatched:text byRegex:@"^[A-Za-z]+$"]) {
		[self updateQueryResult:text type:2];
	} else {
		[self clearMonitorInputStockWithSearch:NO];
		[self updateQueryResult:@"" type:0];
	}
	RELEASE(pastInputStock);
	pastInputStock = [text copy];
}

#pragma mark - 从数据库中查询结果

/**
 *	@brief	从数据库中查询结果
 *
 *	@param  query   要查询的内容
 *	@param  type    查询类别 0:股票代码查询  1:股票中文名查询  2:股票拼音查询
 *
 *	@return	是否有查询结果
 */
- (BOOL)updateQueryResult:(NSString *)query type:(int)type {
	RELEASE(queryResult);

	CGRect frame = self.tvStock.frame;
    frame.size.width = CGRectGetWidth(self.frame);
	frame.size.height = MIN(_showStockMaxRow, queryResult.count) * StockCellHeight;
	frame.origin.y = self.frame.origin.y - frame.size.height - _stockViewIsolationHeight;
	self.tvStock.frame = frame;
	[self.tvStock reloadData];
	[self.tvStock setContentOffset:CGPointZero animated:NO];/* 滚回顶部 */
	return queryResult.count > 0;
}

#pragma mark - 列表
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return queryResult ? queryResult.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return StockCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:keyboardCell];

	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:keyboardCell owner:self options:nil] lastObject];
		[CommonUtil setTableViewCellSeparatorLineWithCell:cell lineImageName:@"keyboard_cell_bg" imageType:@"png"];
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self keyboardSkip:indexPath.row];
}

#pragma mark - 键盘结果选择
- (void)keyboardSkip:(NSUInteger)row {
	if (row >= queryResult.count) return;


	[self clearMonitorInputStockWithSearch:YES];
}

#pragma mark - 将输入股票判断全部重置(重置并且清空查询)
- (void)clearMonitorInputStockWithSearch:(BOOL)isSearch {
	if (self.monitorInputStock) {
		lastStockInputType = 0;
		stockIndex = NSNotFound;
		RELEASE(inputStock);
		inputStock = nil;
		RELEASE(pastInputStock);
		pastInputStock = nil;

		if (isSearch) [self searchString:@""];
	}
}

@end

