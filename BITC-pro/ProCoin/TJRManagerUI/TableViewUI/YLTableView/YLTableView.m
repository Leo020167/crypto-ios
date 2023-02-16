//
//  YLTableView.m
//  Redz
//
//  Created by Taojin on 2018/6/29.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "YLTableView.h"
@interface YLTableView ()


@end

@implementation YLTableView


- (id)initWithFrame:(CGRect)frame andMode:(NSInteger)mode style:(UITableViewStyle)style{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        if (CURRENT_DEVICE_VERSION >= 7.0) {
            self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        if (@available(iOS 11.0, *)) {
            self.estimatedRowHeight = 0;
            self.estimatedSectionHeaderHeight = 0;
            self.estimatedSectionFooterHeight = 0;
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES; // 开启多点触摸
        self.bounces = YES;
        
        refreshMode = mode;
        _bDragDir = YES;
        __block typeof(self) weakSelf = self;
        if ((mode == kHeadMode) || (mode == kHeadAndFootMode)) {
            
            _headerRefresh = [YLTableRefreshHeader headerWithRefreshingBlock:^{
                if (weakSelf.refreshDelegate && [weakSelf.refreshDelegate respondsToSelector:@selector(YLTableViewHeaderDidRefresh:)]) {
                    self.bDragDir = YES;
                    [weakSelf.refreshDelegate YLTableViewHeaderDidRefresh:weakSelf];
                }else{
                    // 没有实现代理方法，直接结束刷新
                    [self.mj_header endRefreshing];
                }
            }];
            self.mj_header = _headerRefresh;

        }
        
        if ((mode == kFootMode) || (mode == kHeadAndFootMode)) {
            _footerRefresh = [YLTableRefreshFooter footerWithRefreshingBlock:^{
                if (weakSelf.refreshDelegate && [weakSelf.refreshDelegate respondsToSelector:@selector(YLTableViewFooterDidRefresh:)]) {
                    self.bDragDir = NO;
                    [weakSelf.refreshDelegate YLTableViewFooterDidRefresh:weakSelf];
                }else{
                    // 没有实现代理方法，直接结束刷新
                    [self.mj_footer endRefreshing];
                }
            }];
            
            self.mj_footer = _footerRefresh;
        }
        
        if (CURRENT_DEVICE_VERSION >= 7.0) {
            self.separatorInset = UIEdgeInsetsZero;
        }
        
        if (CURRENT_DEVICE_VERSION >= 8.0) {
            self.separatorInset = UIEdgeInsetsZero;
            if ([self respondsToSelector:@selector(layoutMargins)]) {
                self.layoutMargins = UIEdgeInsetsZero;
            }
        }
        if (mode == 1) {
            [self setExtraCellLineHidden];
        }
    }
    return self;
}



- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    if (self) {
        // 当使用XIB加载时，要取消tableView XIB面板中的estimate属性，不然有些cell的layout方法不会调用
        if (CURRENT_DEVICE_VERSION >= 7.0) {
            self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }

        if (@available(iOS 11.0, *)) {
            self.estimatedRowHeight = 0;
            self.estimatedSectionHeaderHeight = 0;
            self.estimatedSectionFooterHeight = 0;
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.bounces = YES;
        
        _bDragDir = YES;
        refreshMode = kHeadAndFootMode;
        
        
        __block typeof(self) weakSelf = self;
        // 头部刷新
        _headerRefresh = [YLTableRefreshHeader headerWithRefreshingBlock:^{
            if (weakSelf.refreshDelegate && [weakSelf.refreshDelegate respondsToSelector:@selector(YLTableViewHeaderDidRefresh:)]) {
                weakSelf.bDragDir = YES;
                [weakSelf.refreshDelegate YLTableViewHeaderDidRefresh:weakSelf];
            }else{
                // 没有实现代理方法，直接结束刷新
                [weakSelf.mj_header endRefreshing];
            }
        }];
        self.mj_header = _headerRefresh;
            
        // 尾部刷新
        _footerRefresh = [YLTableRefreshFooter footerWithRefreshingBlock:^{
            if (weakSelf.refreshDelegate && [weakSelf.refreshDelegate respondsToSelector:@selector(YLTableViewFooterDidRefresh:)]) {
                weakSelf.bDragDir = NO;
                [weakSelf.refreshDelegate YLTableViewFooterDidRefresh:weakSelf];
            }else{
                // 没有实现代理方法，直接结束刷新
                [weakSelf.mj_footer endRefreshing];
            }
        }];
        
        self.mj_footer = _footerRefresh;
        
        if (CURRENT_DEVICE_VERSION >= 7.0) {
            self.separatorInset = UIEdgeInsetsZero;
        }
        
        if (CURRENT_DEVICE_VERSION >= 8.0) {
            self.separatorInset = UIEdgeInsetsZero;
            if ([self respondsToSelector:@selector(layoutMargins)]) {
                self.layoutMargins = UIEdgeInsetsZero;
            }
        }

    }
    return self;
}


#pragma mark - 下拉完成调用
- (void)headerViewFinish { // 结束头部刷新
    if (self.mj_header) {
        [self.mj_header endRefreshing];
    }
    self.hidden = NO;
}

#pragma mark - 上拉完成调用
- (void)footerViewFinish { // 结束尾部刷新
    if (self.mj_footer) {
        [self.mj_footer endRefreshing];
    }
    self.hidden = NO;
}

#pragma mark - 上拉已加载全部
- (void)footerViewNoData { // 结束尾部刷新,显示"已全部加载完毕"
    if (self.mj_footer) {
        [self.mj_footer endRefreshingWithNoMoreData];
    }
}

- (void)setIsTemporaryHideHeaderView:(BOOL)isTemporaryHideHeaderView {
    _isTemporaryHideHeaderView = isTemporaryHideHeaderView;
    if (isTemporaryHideHeaderView) {
        self.mj_header.hidden = YES;
        
    }else {
        self.mj_header.hidden = NO;
    }
}

- (void)setIsTemporaryHideFooterView:(BOOL)isTemporaryHideFooterView {
    _isTemporaryHideFooterView = isTemporaryHideFooterView;
    if (isTemporaryHideFooterView) {
        self.mj_footer.hidden = YES;
    }else if (_footerRefresh != nil){
        self.mj_footer.hidden = NO;
    }
}

- (void)setExtraCellLineHidden
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:view];
    [view release];
}

- (void)setYLTableViewDelegate:(id)aDelegate {
    
    self.dataSource = aDelegate;
    self.delegate = aDelegate;
    self.refreshDelegate = aDelegate;
    
}


- (void)dealloc {
    self.refreshDelegate = nil;
    [_footerRefresh release];
    [_headerRefresh release];
    [super dealloc];
}


@end
