//
//  RZRefreshTableView.m
//  Redz
//
//  Created by Hay on 2018/9/29.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import "RZRefreshTableView.h"
#import "RZRefreshHeader.h"

@interface RZRefreshTableView()
{
}

@property (assign, nonatomic) id<RZRefreshTableViewDelegate> rzTVDelegate;

@end

@implementation RZRefreshTableView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        _tvType = RZTableViewType_Both;
        [self initRZRefreshTableView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        _tvType = RZTableViewType_Both;
        [self initRZRefreshTableView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if(self){
        _tvType = RZTableViewType_Both;
        [self initRZRefreshTableView];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setTableViewDelegate:(id)delegate
{
    _rzTVDelegate = delegate;
    self.delegate = delegate;
    self.dataSource = delegate;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

}

#pragma mark - 变量
- (BOOL)dragOrientation
{
    if(self.mj_header.refreshing){
        return YES;
    }else if(self.mj_footer.refreshing){
        return NO;
    }else{
        return YES;
    }
}

- (void)setTvType:(RZTableViewType)tvType
{
    _tvType = tvType;
    [self initRZRefreshTableView];
}

#pragma mark - 初始化refresh tableview
- (void)initRZRefreshTableView
{
    /** 因为ios 11后tableview会默认开启self-sizing,导致刷新某一行cell时会发生抖动，所以设置下面变量保证不会抖动*/
    self.estimatedRowHeight = 0;
//    self.estimatedSectionHeaderHeight = 0;
//    self.estimatedSectionFooterHeight = 0;
    
    if(_tvType == RZTableViewType_Both){
        __block typeof(self) weakself = self;
        MJRefreshStateHeader *header = [RZRefreshHeader headerWithRefreshingBlock:^{
            [weakself refreshTableViewHeaderRefreshing];
        }];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = NO;
        
        self.mj_header = header;
        
        /** 使用可以回弹的footerView */
        MJRefreshBackStateFooter *footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:^{
            [weakself refreshTableViewFooterRefreshing];
        }];
        self.mj_footer = footer;
    }else if(_tvType == RZTableViewType_Head){      /** 只存在头部刷新*/
        
        __block typeof(self) weakself = self;
        MJRefreshStateHeader *header = [RZRefreshHeader headerWithRefreshingBlock:^{
            [weakself refreshTableViewHeaderRefreshing];
        }];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        
        self.mj_header = header;
        
        self.mj_footer = nil;
    }else{                                  /** 只存在尾部刷新 */
        __block typeof(self) weakself = self;
        
        self.mj_header = nil;
        
        /** 使用可以回弹的footerView */
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakself refreshTableViewFooterRefreshing];
        }];
        footer.automaticallyRefresh = NO;
        self.mj_footer = footer;
    }
    
    

}

#pragma mark -
//下拉刷新时候调用的方法
- (void)refreshTableViewHeaderRefreshing
{
    _dragOrientation = YES;
    //如果是RZTableViewType_Both状态，并且之前曾经关闭过底部刷新,则在刷新头部时候必须要重新显示出来
    if(_tvType == RZTableViewType_Both){
        if(self.mj_footer.hidden){
           [self tableViewFooterRefreshViewShow];
        }
        [self.mj_footer resetNoMoreData];
    }
    if([_rzTVDelegate respondsToSelector:@selector(refreshTableViewHeaderRefreshingDidTrigger)]){
        [_rzTVDelegate refreshTableViewHeaderRefreshingDidTrigger];
    }
}

//上拉加载更多时候调用的方法
- (void)refreshTableViewFooterRefreshing
{
    _dragOrientation = NO;
    if([_rzTVDelegate respondsToSelector:@selector(refreshTableViewFooterRefreshingDidTrigger)]){
        [_rzTVDelegate refreshTableViewFooterRefreshingDidTrigger];
    }
}

#pragma mark - 停止刷新
/** refresh table view刷新完毕(会自动判断头部或者底部)*/
- (void)tableViewEndRefreshing
{
    
    if(self.dragOrientation){
        [self.mj_header endRefreshing];
    }
    
    if(!self.dragOrientation){
        [self.mj_footer endRefreshing];
    }
}

/** refresh table view顶部刷新完成*/
- (void)tableViewHeaderEndRefreshing
{
    [self.mj_header endRefreshing];
}

/** refresh table view底部刷新完毕且已经没有更多数据了*/
- (void)tableViewFooterEndRefreshingWithNoData
{
    [self.mj_footer endRefreshingWithNoMoreData];
    
}


/** refresh table view 隐藏头部刷新*/
- (void)tableViewHeaderRefreshViewHidden
{
    if(self.mj_header){
        self.mj_header.hidden = YES;
    }
}
/** refresh table view 显示头部刷新*/
- (void)tableViewHeaderRefreshViewShow
{
    if(self.mj_header){
        self.mj_header.hidden = NO;
    }
}
/** refresh table view 隐藏尾部加载*/
- (void)tableViewFooterRefreshViewHidden
{
    if(self.mj_footer){
        self.mj_footer.hidden = YES;
    }
}

/** refresh table view 显示尾部加载*/
- (void)tableViewFooterRefreshViewShow
{
    if(self.mj_footer){
        self.mj_footer.hidden = NO;
    }
}




@end
