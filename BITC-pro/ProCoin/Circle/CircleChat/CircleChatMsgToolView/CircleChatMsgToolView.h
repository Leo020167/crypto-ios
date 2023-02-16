//
//  CircleChatMsgToolView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 11/13/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleChatMsgToolView;
@class HPGrowingTextView;

@protocol CircleChatMsgToolViewDelegate <NSObject>

@optional
- (void)msgToolView:(CircleChatMsgToolView *)toolView sendClicked:(HPGrowingTextView*)textView msgOrFileName:(NSString *)msgOrFileName type:(NSString*)type length:(NSUInteger)length;
- (void)msgToolView:(CircleChatMsgToolView *)toolView keyboardReset:(CGRect)keyboardRect;
- (void)msgToolView:(CircleChatMsgToolView *)toolView willBecomeFirstResponder:(HPGrowingTextView*)textView;
- (void)msgToolView:(CircleChatMsgToolView *)toolView keyboardClicked:(NSString *)key;

@end

@interface CircleChatMsgToolView : UIView{
}

@property (assign, nonatomic) id<CircleChatMsgToolViewDelegate> delegate;
@property (retain, nonatomic) IBOutlet HPGrowingTextView *textView;	/* 文字输入框 */
@property (assign, nonatomic) BOOL bDragBack;

- (void)resetRole:(BOOL)bAdmin;
- (void)setPrivateChat:(BOOL)bPrivate;
- (void)resignKeyboard;
- (void)cleanRecordData;
- (BOOL)checkKeyboardUp;
@end
