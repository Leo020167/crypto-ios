//
//  BaseToolBar.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-8.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseToolBar : UIToolbar
/**
 文本框toolBar
 @param delegate 接收事件的delegate
 @param titleArray 按钮的标题
 @param selArr selector数组，以nil结束
 @returns 返回toolbar实例
 */
- (id)initWithDelegate:(id)delegate TitleArray:(NSArray*)titleArray selectorArray:(SEL)selArr,...;
@end
