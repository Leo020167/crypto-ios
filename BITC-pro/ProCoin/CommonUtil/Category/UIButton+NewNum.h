//
//  UIButton+NewNum.h
//  TJRtaojinroad
//
//  Created by taojinroad on 16/2/1.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (NewNum)

/**
 *  显示数字,或者红点
 *
 *  @param newNum 数字
 *  @param isShowDot 是否是显示红点
 */
- (void)showNewNum:(NSUInteger)newNum isShowDot:(BOOL)isShowDot;
- (void)showNewNum:(NSUInteger)newNum;
@end
