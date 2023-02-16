//
//  RZRefreshHeader.m
//  Redz
//
//  Created by Hay on 2018/9/29.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import "RZRefreshHeader.h"

@implementation RZRefreshHeader

- (void)prepare
{
    [super prepare];
//    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
//    NSMutableArray *refreshingImages = [NSMutableArray array];
//    for (NSUInteger i = 0; i < 30; i++) {
//        NSString* num = (i<10 && i>=0)?[NSString stringWithFormat:@"0%@",@(i)]:[NSString stringWithFormat:@"%@",@(i)];
//        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"loading_icon_%@", num]];
//        [refreshingImages addObject:image];
//    }
//    [self setImages:refreshingImages forState:MJRefreshStateIdle];
//
//    [self setImages:refreshingImages forState:MJRefreshStatePulling];
//    // 设置正在刷新状态的动画图片
//    [self setImages:refreshingImages duration:2 forState:MJRefreshStateRefreshing];
    
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=33; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_anim__00%zd", i]];
        [idleImages addObject:image];
    }
    [self setImages:idleImages forState:MJRefreshStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=33; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"dropdown_loading_%zd", i]];
        [refreshingImages addObject:image];
    }
    [self setImages:refreshingImages forState:MJRefreshStatePulling];
    
    // 设置正在刷新状态的动画图片
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
}

@end
