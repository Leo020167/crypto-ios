//
//  TJRLoadedStateHintView.h
//  TJRtaojinroad
//
//  Created by Hay on 15/7/15.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum TJRLoadedStateType{
    TJRLoadNoDataState,
    TJRLoadFailState,
}TJRLoadedStateType;

@interface TJRLoadedStateHintView : UIView

#pragma mark - 显示loaded不同状态时页面
+ (TJRLoadedStateHintView *)loadedStateHintView:(UIView *)superView loadedState:(TJRLoadedStateType)type declareText:(NSString *)text;

- (void)dismissFromSuperView;

@end
