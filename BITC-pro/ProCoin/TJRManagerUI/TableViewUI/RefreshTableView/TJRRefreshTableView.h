//
//  TJRRefreshTableView.h
//  taojinroad
//
//  Created by road taojin on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRRefreshTableFooterView.h"
#import "TJRRefreshTableHeaderView.h"
#import "TJRBaseView.h"

#define kHeadMode               1                   
#define kFootMode               2
#define kHeadAndFootMode        3

typedef enum {
    RefreshTableViewWhiteTint = 1UL << 0, // default
    RefreshTableViewLightWhiteTint = 1UL << 1,
    RefreshTableViewBlackTint = 1UL << 2,
    RefreshTableViewGrayTint = 1UL << 3,
    RefreshTableViewCleanTint = 1UL << 4,
    RefreshTableViewDefaultTint = RefreshTableViewWhiteTint
} RefreshTableViewStyle;

@protocol TJRRefreshTableDelegate <NSObject>
- (void)tableViewbackgroundEndTouch;        //控制tableview滚动，滑动，点击的事件，如收起键盘
@end

@interface TJRRefreshTableView : TJRBaseView <UIScrollViewDelegate>
{
    BOOL bRDLoading;                //yes代表头部刷新时正在数据加载中，no代表头部刷新时数据加载完成
    BOOL bNDLoading;                //yes代表尾部刷新时正在数据加载中，no代表尾部刷新时数据加载完成
    BOOL bDragDir;                  //区分头部或尾部，yes表示头部， no表示尾部
    BOOL isNoMoreData;              // 是否有更多数据加载
    BOOL bReqFailed;                // 请求失败
    UITableView *tableView;
    TJRRefreshTableFooterView *footerView;
    TJRRefreshTableHeaderView *headerView;
    id <TJRRefreshTableDelegate>tvDelegate;
    NSInteger _mode;                //样式模式
    BOOL bBGTouch;                  //设置是否需要背景点击
}

@property (nonatomic, assign) id tvDelegate;
@property (nonatomic) BOOL bRDLoading;
@property (nonatomic) BOOL bNDLoading;                
@property (nonatomic) BOOL bDragDir;
@property (nonatomic) BOOL isNoMoreData; // 是否有更多数据加载
@property (nonatomic) BOOL bReqFailed;   // 请求失败
@property (nonatomic, assign) BOOL bBGTouch;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) TJRRefreshTableFooterView *footerView;
@property (nonatomic, retain) TJRRefreshTableHeaderView *headerView;
@property (nonatomic, assign) BOOL isTemporaryHideHeaderView;//是否临时隐藏HeaderView
@property (nonatomic, assign) BOOL isTemporaryHideFooterView;//是否临时隐藏FooterView
@property (nonatomic, assign) NSInteger pageCount;


- (id)initWithFrame:(CGRect)frame andMode:(NSInteger)mode;
- (id)initWithFrame:(CGRect)frame andMode:(NSInteger)mode style:(UITableViewStyle)style;
- (void)setRefreshTableViewDelegate:(id)aDelegate;
- (void)setTableViewStyle:(RefreshTableViewStyle)style;
- (void)reloadData;
// 手动调用隐藏底部已显示全部内容的视图
- (void)hideFooterView:(BOOL)isHide;
- (void)headerViewFinish;
- (void)footerViewFinish;
- (void)footerViewNoData;
- (void)didNoDragForLoading;
- (void)didNoDragForLoadingNoPull;

@end
