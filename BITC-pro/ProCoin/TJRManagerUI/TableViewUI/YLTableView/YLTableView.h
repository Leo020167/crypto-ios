//
//  YLTableView.h
//  Redz
//
//  Created by Taojin on 2018/6/29.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLTableRefreshHeader.h"
#import "YLTableRefreshFooter.h"

#define kHeadMode               1
#define kFootMode               2
#define kHeadAndFootMode        3
@class YLTableView,YLTableRefreshHeader,YLTableRefreshFooter;
// 刷新必须实现的代理方法
@protocol YLTableRefreshDelegate <NSObject>
@optional
// 头部刷新响应方法
- (void)YLTableViewHeaderDidRefresh:(YLTableView *)tableView;
//  尾部刷新响应方法
- (void)YLTableViewFooterDidRefresh:(YLTableView *)tableView;

@end

@interface YLTableView : UITableView <UIScrollViewDelegate>
{
    NSInteger refreshMode; // 决定是否添加头尾刷新
}

@property (nonatomic, assign) id<YLTableRefreshDelegate> refreshDelegate;

@property (nonatomic) BOOL bHDLoading;   // 头部正在刷新
@property (nonatomic) BOOL bFDLoading;   // 尾部正在刷新
@property (nonatomic) BOOL bDragDir;     // Yes表示头部刷新，NO表示尾部刷新
@property (nonatomic) BOOL bReqFailed;   // Yes表示请求失败，NO表示请求成功

@property (nonatomic,retain)YLTableRefreshHeader *headerRefresh;
@property (nonatomic, retain) YLTableRefreshFooter *footerRefresh;

@property (nonatomic, assign) BOOL isTemporaryHideHeaderView;//是否临时隐藏HeaderView
@property (nonatomic, assign) BOOL isTemporaryHideFooterView;//是否临时隐藏FooterView

@property (nonatomic, assign) NSInteger pageCount;

- (id)initWithFrame:(CGRect)frame andMode:(NSInteger)mode style:(UITableViewStyle)style;


- (void)headerViewFinish; // 结束头部刷新
- (void)footerViewFinish; // 结束尾部刷新
- (void)footerViewNoData; // 结束尾部刷新,显示"已全部加载完毕"

- (void)setYLTableViewDelegate:(id)aDelegate;


@end
