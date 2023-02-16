//
//  SendMsgAndFaceView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 13-4-13.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "TJRFaceView.h"
#import "TJRRecordView.h"

extern NSString *const SendMsgAndFaceDidChangeFrameNotification;
extern NSString *const SendMsgAndFaceWillShowNotification;
extern NSString *const SendMsgAndFaceHideEndNotification;
extern NSString *const SendMsgAndFaceFrameEndUserInfoKey;
extern NSString *const SendMsgAndFaceViewKey;
extern NSString *const SendMsgAndFaceViewSpecialKey;
extern NSString *const SendMsgAndFaceViewSpecialObserverName;

@class SendMsgAndFaceView;
@protocol SendMsgAndFaceViewDelegate <NSObject>

@optional

/*
 *   以下两个方法不用了,现在使用通知
 *   - (void)sendMsgAndFaceViewFrameChange:(CGRect)frame;
 *
 *   - (void)sendMsgAndFaceViewKeyboardDidHide;
 */

/**
 *    语音按钮单击时调用
 *    @param btnVoice 语音按钮
 *    @param isShow 输入语音的那个View是否处于显示状态
 */
- (void)btnVoiceOnClick:(UIButton *)btnVoice voiceViewIsShow:(BOOL)isShow;

/**
 *    表情按钮单击时调用
 *    @param btnAddFace 表情按钮
 *    @param isShow 输入表情的那个View是否处于显示状态
 */
- (void)btnAddFaceOnClick:(UIButton *)btnAddFace faceViewIsShow:(BOOL)isShow;

/**
 *    键盘的完成按钮单击时调用
 */
- (void)btnKeyboardClickFinish;

/**
 *    发表按钮单击时调用(以前的方法不再用了)
 *    @param btnSendMsg 发表按钮
 *    @param msgOrFileName 输入框里的内容或语音文件名
 *    @param isVoice 是否是语音输入
 *    @param length 输入为文字时,length代表文字的中文长度,语音输入时代表,语音时长
 */
- (void)btnSendMsgOnClick:(UIButton *)btnSendMsg msgOrFileName:(NSString *)msgOrFileName isVoice:(BOOL)isVoice length:(NSUInteger)length;

/**
 *    自定义按钮点击回调
 *    @param buttonIndex 识别多个自定义按钮点击事件标记
 */
- (void)customButtonPressedEvent:(NSInteger)buttonIndex;


// 文本内容改变监听
- (void)SendMsgAndFaceView:(SendMsgAndFaceView *)msgView textViewDidChange:(HPGrowingTextView *)growingTextView;

@end

typedef enum SendMsgAndFaceViewShowType {
	SendMsgAndFaceViewShowType_TalkieTalkie,/* 股友圈 */
	SendMsgAndFaceViewShowType_TalkieTalkiePlazaOneLine,/* 股友圈 */
	SendMsgAndFaceViewShowType_TalkieTalkieOneLine,	/* 股友圈(一行,发表页面用) */
	SendMsgAndFaceViewShowType_StockTalk/* 微访谈 */
} SendMsgAndFaceViewShowType;

typedef enum DefaultInputItemType {
	DefaultInputItemType_NONe,
	DefaultInputItemType_AddStock,	/* 添加自选股 */
	DefaultInputItemType_DelStock,	/* 删除自选股 */
	DefaultInputItemType_DaZhang/* 大涨 */
} DefaultInputItemType;

typedef NS_ENUM(NSUInteger, SendMsgAndFaceViewKeyboardType) {/* 输入类型 */
    SendMsgAndFaceViewKeyboardType_Hide = 0,    /* 键盘准备隐藏所有 */
    SendMsgAndFaceViewKeyboardType_Txet,        /* 文字键盘 */
    SendMsgAndFaceViewKeyboardType_Face,        /* 表情键盘 */
    SendMsgAndFaceViewKeyboardType_Voice        /* 语音键盘 */
};

@interface SendMsgAndFaceView : UIView <UIScrollViewDelegate, HPGrowingTextViewDelegate, TJRFaceClickDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, TJRRecordDelegate>{
    CGRect phoneRect;
    CGRect keyboardRect;
	CGRect defaultFrame;
	CGRect pastRect;/* msgview上次的Frame */
	float phoneHeight;
	float phoneWidth;
	BOOL isLandscape;
	BOOL isFirst;
	UIInterfaceOrientation statusBarOrientation;
	int minNumberOfLines;
	int maxNumberOfLines;
	DefaultInputItemType lastInputType;
	NSString *inputStock;	/* 记录输入的数字或拼音 */
	NSString *pastInputStock;	/* 记录上次输入的数字或拼音 */
	NSInteger stockIndex;	/* 记录输入的数字或拼音位置 */
	NSArray *queryResult;	/* 股票查询结果 */
    CGFloat hideRecordChangeWidth;
    NSString *textViewString;

	/* 上次匹配输入类型
	 * 0表示没有输入内容
	 * 1表示输入$开头,11表示输入数字,12表示输入英文,13表示输入中文
	 * 2表示输入#开头,21表示输入数字,22表示输入英文,23表示输入中文
	 * 3表示没有输入开头,31表示输入数字,32表示输入英文,33表示输入中文
	 */
	NSInteger lastStockInputType;

	TJRRecordView *recordView;
	SendMsgAndFaceViewKeyboardType keyboardType;
    BOOL isAddObserver;
    NSLayoutConstraint *bottomConstraint;
    NSLayoutConstraint *heightConstraint;
    CGFloat outBottomHeight;
}

@property (retain, nonatomic) IBOutlet UIView *msgView;	/* msg输入View(包含显示表情按钮,发表按钮,文字输入框和msg的背景imageview) */
@property (retain, nonatomic) IBOutlet UIButton *btnAddFace;/* 表情按钮 */
@property (retain, nonatomic) IBOutlet UIButton *btnSendMsg;/* 发表按钮 */
@property (retain, nonatomic) IBOutlet UIButton *btnCance;  /* 取消按钮 */

@property (retain, nonatomic) IBOutlet UIImageView *msgBackgroundImageView;	/* msg的背景imageview */
@property (retain, nonatomic) IBOutlet HPGrowingTextView *textView;	/* 文字输入框 */
@property (retain, nonatomic) IBOutlet UIView *defaultInputItemView;
@property (retain, nonatomic) IBOutlet UIButton *btnFirstItem;
@property (retain, nonatomic) IBOutlet UIButton *btnSecondItem;
@property (retain, nonatomic) IBOutlet UIButton *btnThirdItem;
@property (retain, nonatomic) IBOutlet UIButton *btnRecord;

@property (retain, nonatomic) TJRFaceView *allFaceView;	/* 表情的整个View */
@property (retain, nonatomic) UIView *bottomCoverView; /* 遮挡底部栏视图（用于iPhone X）*/
@property (assign, nonatomic) BOOL isOutOfBottom;	/* 隐藏时是否要看不到 */
@property (assign, nonatomic) DefaultInputItemType inputType;	/* 默认输入项显示类型 */

@property (retain, nonatomic) UITableView *tvStock;	/* 显示股票的列表 */
@property (assign, nonatomic) BOOL monitorInputStock;	/* 监听输入的数字或拼音是否为股票(默认为NO) */
@property (assign, nonatomic) CGFloat showStockMaxRow;	/* 显示股票的最大行(默认为2) */


@property (assign, nonatomic) id <SendMsgAndFaceViewDelegate> delegate;

@property (assign, nonatomic) CGFloat stockViewIsolationHeight;	/* 股票离键盘的高度(默认为0) */
@property (assign, nonatomic) NSString *userId;	/* 用户Id,语音的时候要用来生成文件名 */

@property (retain, nonatomic) NSArray *specialObserverKeyArray;/* 特殊的监听字符,比如@#之类 */

/**
 *   将当前语音保存到缓存
 *   @param url  语音url
 */
- (void)saveVoiceToCacheWithUrl:(NSString *)url;

/**
 *    隐藏表情和键盘
 */
- (void)hideFaceViewAndKeyboard;

/**
 *    显示或隐藏表情界面
 *    @param isShowFace 显示或隐藏
 */
- (void)showOrHideFaceView:(BOOL)isShowFace;

/**
 *  显示键盘
 */
- (void)showKeyboard;
/**
 *    隐藏键盘调整页面
 */
//- (void)hideKeyboardView;

/**
 *    设置显示按钮,背景等,有需求自己加
 *    @param type 类型(有需求自己加)
 */
- (void)setShowType:(SendMsgAndFaceViewShowType)type;

/**
 *   清除所有的语音文件和文字
 */
- (void)cleanRecordVoiceFileAndText;

/**
 *    表情和键盘是否都隐藏
 *    @returns
 */
- (BOOL)isFaceAndKeyboardAllHide;

/**
 *    隐藏语音按钮
 *    @param isHide
 */
- (void)hideRecordButton:(BOOL)isHide;

/**
 *    隐藏发送按钮
 *    @param isHide
 */
- (void)hideSendButton:(BOOL)isHide;

/**
 *    添加键盘的监听(在viewDidAppear里加上)
 */
- (void)addKeyboardObserver;

/**
 *    移除键盘监听(在viewDidDisappear里加上)
 */
- (void)removeKeyboardObserver;
@end

