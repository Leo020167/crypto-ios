//
//  MLEmojiLabelClickView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 14/10/29.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLEmojiLabelClickView;
@protocol MLEmojiLabelClickViewDelegate <NSObject>

@optional
- (void)MLEmojiLabelClickViewOnClick:(MLEmojiLabelClickView *)view;
@end

@interface MLEmojiLabelClickView : UIView {
    NSMutableDictionary *labelSaveData;	// 保存一些数据
}

@property (assign, nonatomic) IBOutlet id<MLEmojiLabelClickViewDelegate> delegate;
- (void)setSaveDataWithObject:(id)object forKey:(id)key;
- (id)getSaveDataWithKey:(id)key;
- (void)removeSaveDataObjectForKey:(id)key;
- (void)removeAllSaveData;
@end
