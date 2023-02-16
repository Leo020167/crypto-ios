//
//  RZRefreshTableView.h
//  Redz
//
//  Created by Hay on 2018/9/29.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJRefresh.h>

@protocol RZRefreshTableViewDelegate <NSObject>

@optional

- (void)refreshTableViewHeaderRefreshingDidTrigger;             //头部正在刷新
- (void)refreshTableViewFooterRefreshingDidTrigger;             //底部正在刷新

@end

/** table view类型，分别有头部尾部刷新，只有头部，只有尾部*/
typedef enum {
    RZTableViewType_Both = 0,           //存在头部刷新与底部刷新
    RZTableViewType_Head,               //只存在头部刷新
    RZTableViewType_Foot                //只存在底部刷新
}RZTableViewType;


@interface RZRefreshTableView : UITableView

@property (assign, nonatomic) RZTableViewType tvType;                  //refresh table view类型,默认为RZTableViewType_Both

/**
 * @brief 页数，上拉或下拉刷新数据时提供的页面，但该类并不会对其进行任何逻辑处理，请自行处理
 */
@property (assign, nonatomic) NSInteger pageNo;

/** 刷新方向,YES为下拉头部刷新，NO为上拉底部刷新,如果都不在刷新，则默认为YES*/
@property (assign, nonatomic) BOOL dragOrientation;

/** 设置刷新delegate和table view的delegate*/
- (void)setTableViewDelegate:(id)delegate;

/** refresh table view刷新完毕(会自动判断头部或者底部) 调用该语句前要根据逻辑先调用 tableView reloadData,而且不能在调用tableViewFooterEndRefreshingWithNoData之后再调用，这样会让底部重新出来*/
- (void)tableViewEndRefreshing;
/** refresh table view 隐藏头部刷新*/
- (void)tableViewHeaderRefreshViewHidden;
/** refresh table view 显示头部刷新*/
- (void)tableViewHeaderRefreshViewShow;
/** refresh table view 隐藏尾部加载*/
- (void)tableViewFooterRefreshViewHidden;
/** refresh table view 显示尾部加载*/
- (void)tableViewFooterRefreshViewShow;
/** refresh table view顶部刷新完成*/
- (void)tableViewHeaderEndRefreshing;
/** refresh table view底部刷新完毕且已经没有更多数据了(hidden)*/
- (void)tableViewFooterEndRefreshingWithNoData;

@end

