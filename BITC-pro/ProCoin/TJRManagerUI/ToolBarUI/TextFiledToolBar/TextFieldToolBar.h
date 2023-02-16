//
//  TextFieldToolBar.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-8.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseToolBar.h"

@protocol TextFieldToolBarDelegate <NSObject>

@optional
- (void)TFAnimateView:(NSUInteger)tag;
@required
- (void)TFDonePressed;

@end

@interface TextFieldToolBar : BaseToolBar{
    NSUInteger fieldCount;
}

@property (assign, nonatomic) id<TextFieldToolBarDelegate> tfDelegate;

/**
 专门针对textField 的 toolbar
 @param delegate 委托对象
 @param num textField数量
 @returns 实例
 */
- (id)initWithDelegate:(id)delegate numOfTextField:(NSUInteger)num;

//检测按钮是否有效
- (void)checkBarButton:(NSUInteger)tag;

@end
