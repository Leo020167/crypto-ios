//
//  YLTableRefreshHeader.m
//  Redz
//
//  Created by Taojin on 2018/6/29.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "YLTableRefreshHeader.h"

@implementation YLTableRefreshHeader

#pragma mark - 重写方法
#pragma mark 基本设置
- (void)prepare
{
    [super prepare];
    
    // 隐藏时间
    self.lastUpdatedTimeLabel.hidden = YES;
    // 隐藏状态
    self.stateLabel.hidden = YES;
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    UIImage *image = [UIImage imageNamed:@"progress_icon"];
    [idleImages addObject:image];
    [self setImages:idleImages forState:MJRefreshStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    [self setImages:idleImages forState:MJRefreshStatePulling];
    
    // 设置正在刷新状态的动画图片
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 0; i<30; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"progress_icon_%ld", i]];
        [refreshingImages addObject:image];
    }
    [self setImages:refreshingImages duration:refreshingImages.count * 0.05 forState:MJRefreshStateRefreshing];
}

@end
