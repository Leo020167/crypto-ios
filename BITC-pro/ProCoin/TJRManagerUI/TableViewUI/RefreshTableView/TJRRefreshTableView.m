//
//  TJRRefreshTableView.m
//  taojinroad
//
//  Created by road taojin on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TJRRefreshTableView.h"
#import "UIScrollView+AllowPanGestureEventPass.h"

@implementation TJRRefreshTableView

@synthesize tableView, bDragDir, bNDLoading, bRDLoading ,bBGTouch,isNoMoreData,bReqFailed;
@synthesize footerView, headerView;
@synthesize tvDelegate;

- (id)initWithFrame:(CGRect)frame andMode:(NSInteger)mode {
    [self initWithFrame:frame andMode:mode style:UITableViewStylePlain];
	return self;
}

- (id)initWithFrame:(CGRect)frame andMode:(NSInteger)mode style:(UITableViewStyle)style{
    self = [super initWithFrame:frame];
    
    if (self) {
        CGSize size = self.frame.size;
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:style];
        [self addSubview:tableView];
        
        if (CURRENT_DEVICE_VERSION >= 7.0) {
            tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        
        if (@available(iOS 11.0, *)) {
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        
        tableView.userInteractionEnabled = YES;
        tableView.multipleTouchEnabled = YES;
        tableView.bounces = YES;
        
        _mode = mode;
        
        if ((mode == kHeadMode) || (mode == kHeadAndFootMode)) {
            headerView = [[TJRRefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, size.width, self.tableView.bounds.size.height)];
            headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            headerView._activityView.style = EVCircularProgressBlackTint;
            [tableView addSubview:headerView];
        }
        
        if ((mode == kFootMode) || (mode == kHeadAndFootMode)) {
            footerView = [[TJRRefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, self.tableView.frame.size.height)];
            footerView.hidden = YES;
            footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [tableView addSubview:footerView];
        }
        //[self setTableViewStyle:RefreshTableViewDefaultTint];
        
        footerView.statusLabel.textColor = RGBA(128, 128, 128, 1);
        
        if (CURRENT_DEVICE_VERSION >= 7.0) {
            tableView.separatorInset = UIEdgeInsetsZero;
        }
        
        if (CURRENT_DEVICE_VERSION >= 8.0) {
            tableView.separatorInset = UIEdgeInsetsZero;
            if ([tableView respondsToSelector:@selector(layoutMargins)]) {
                tableView.layoutMargins = UIEdgeInsetsZero;
            }
        }
        
        [self setExtraCellLineHidden:tableView];
      
        /**  设置UINavigationController的左边缘滑动返回手势优先级高于scrollercView的滑动手势 */
        [self.tableView setScreenEdgePanGestureRecognizerPriority];

        // 底部视图，当调用[self footerViewNoData]方法时显示
        UIView *tableFootView = [[[NSBundle mainBundle] loadNibNamed:@"NotMoreDataFooterView" owner:self options:nil] lastObject];
        self.tableView.tableFooterView = tableFootView;
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];

	if (self) {
		CGSize size = self.frame.size;
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStylePlain];
		[self addSubview:tableView];

		if (CURRENT_DEVICE_VERSION >= 7.0) {
			tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
		}
        
        if (@available(iOS 11.0, *)) {
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }

		[tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];

		tableView.userInteractionEnabled = YES;
		tableView.multipleTouchEnabled = YES;
		tableView.bounces = YES;

		headerView = [[TJRRefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, tableView.bounds.size.width, self.tableView.bounds.size.height)];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        headerView._activityView.style = EVCircularProgressBlackTint;
		[tableView addSubview:headerView];

		footerView = [[TJRRefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, self.tableView.frame.size.height)];
		footerView.hidden = YES;
        footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[tableView addSubview:footerView];

		_mode = kHeadAndFootMode;

		[self setTableViewStyle:RefreshTableViewDefaultTint];

		if (CURRENT_DEVICE_VERSION >= 7.0) {
			tableView.separatorInset = UIEdgeInsetsZero;
		}
        
        if (CURRENT_DEVICE_VERSION >= 8.0) {
            tableView.separatorInset = UIEdgeInsetsZero;
            if ([tableView respondsToSelector:@selector(layoutMargins)]) {
                tableView.layoutMargins = UIEdgeInsetsZero;
            }
        }
        [self setExtraCellLineHidden:tableView];
        /**  设置UINavigationController的左边缘滑动返回手势优先级高于scrollercView的滑动手势 */
        [self.tableView setScreenEdgePanGestureRecognizerPriority];
        
        // 底部视图，当调用[self footerViewNoData]方法时显示
        UIView *tableFootView = [[[NSBundle mainBundle] loadNibNamed:@"NotMoreDataFooterView" owner:self options:nil] lastObject];
        self.tableView.tableFooterView = tableFootView;
	}
	return self;
}

- (void)layoutSubviews{
    CGSize size = self.frame.size;
    tableView.frame = CGRectMake(0, 0, size.width, size.height);
    headerView.frame = CGRectMake(0.0f, 0.0f - size.height, size.width, size.height);
    footerView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    tableView.tableFooterView.frame = CGRectMake(0.0f, 0.0f, size.width, 0.0f);
}

- (void)setBBGTouch:(BOOL)_bBGTouch{
    bBGTouch = _bBGTouch;
    if (bBGTouch) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapGestureRecognizer:) name:DragBackChange object:nil];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
        tapGestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        
    }
}

- (void)tapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer{
    if ([tvDelegate respondsToSelector:@selector(tableViewbackgroundEndTouch)]) {
        [tvDelegate tableViewbackgroundEndTouch];
    }
}

- (void)setTableViewStyle:(RefreshTableViewStyle)style {
	switch (style) {
		case RefreshTableViewWhiteTint:
			{
				self.headerView.backgroundColor = [UIColor whiteColor];
				self.footerView.backgroundColor = [UIColor whiteColor];

                self.headerView._activityView.style = EVCircularProgressBlackTint;
                
				UILabel *label_foot = [self.footerView getStatusLabel];
				label_foot.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
				label_foot.shadowOffset = CGSizeMake(0.0f, 1.0f);

				break;
			}

		case RefreshTableViewLightWhiteTint:
			{
				self.headerView.backgroundColor = [UIColor colorWithRed:238.0 / 255.0 green:238.0 / 255.0 blue:238.0 / 255.0 alpha:1.0];
				self.footerView.backgroundColor = [UIColor colorWithRed:238.0 / 255.0 green:238.0 / 255.0 blue:238.0 / 255.0 alpha:1.0];
                
                self.headerView._activityView.style = EVCircularProgressBlackTint;

				UILabel *label_foot = [self.footerView getStatusLabel];
				label_foot.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
				label_foot.shadowOffset = CGSizeMake(0.0f, 1.0f);
				break;
			}

		case RefreshTableViewBlackTint:
			{
				self.headerView.backgroundColor = [UIColor blackColor];
				self.footerView.backgroundColor = [UIColor blackColor];
                
                self.headerView._activityView.style = EVCircularProgressWhiteTint;

				UILabel *label_foot = [self.footerView getStatusLabel];
				label_foot.textColor = [UIColor whiteColor];
				break;
			}

		case RefreshTableViewGrayTint:
			{
				self.headerView.backgroundColor = [UIColor colorWithRed:39.0 / 255.0 green:39.0 / 255.0 blue:39.0 / 255.0 alpha:1.0];
				self.footerView.backgroundColor = [UIColor colorWithRed:39.0 / 255.0 green:39.0 / 255.0 blue:39.0 / 255.0 alpha:1.0];
                
                self.headerView._activityView.style = EVCircularProgressWhiteTint;

				UILabel *label_foot = [self.footerView getStatusLabel];
				label_foot.textColor = [UIColor whiteColor];
				break;
			}
        case RefreshTableViewCleanTint:
            {
                self.headerView.backgroundColor = [UIColor clearColor];
				self.footerView.backgroundColor = [UIColor clearColor];
                
                self.headerView._activityView.style = EVCircularProgressBlackTint;

                
				UILabel *label_foot = [self.footerView getStatusLabel];
				label_foot.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
				label_foot.shadowOffset = CGSizeMake(0.0f, 1.0f);
                
				break;
            }
		default:
                break;
            
	}
}

- (void)setRefreshTableViewDelegate:(id)aDelegate {
	if ((_mode == kHeadMode) || (_mode == kHeadAndFootMode)) {
		headerView.delegate = aDelegate;
	}

	if ((_mode == kFootMode) || (_mode == kHeadAndFootMode)) {
		footerView.delegate = aDelegate;
	}
    tvDelegate = aDelegate;
	tableView.delegate = aDelegate;
	tableView.dataSource = aDelegate;
}

- (void)setTvDelegate:(id)aDelegate {
	if ((_mode == kHeadMode) || (_mode == kHeadAndFootMode)) {
		headerView.delegate = aDelegate;
	}

	if ((_mode == kFootMode) || (_mode == kHeadAndFootMode)) {
		footerView.delegate = aDelegate;
	}
    tvDelegate = aDelegate;
	tableView.delegate = aDelegate;
	tableView.dataSource = aDelegate;
}

- (void)reloadData {
//    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

	[self.tableView reloadData];
}

// 手动调用隐藏底部已显示全部内容的视图
- (void)hideFooterView:(BOOL)isHide{
    // 已显示全部内容
    if (self.tableView.tableFooterView) {
        CGRect rect = self.tableView.tableFooterView.frame;
        rect.size.height =  isHide ? 0 : 60;
        self.tableView.tableFooterView.frame = rect;
    }
}


#pragma mark - 上拉完成调用
- (void)headerViewFinish {
    self.headerView.hidden = self.isTemporaryHideHeaderView;
	self.bRDLoading = NO;
	self.bNDLoading = NO;
    self.isNoMoreData = NO;
	[self.headerView refreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    // 已显示全部内容
    [self hideFooterView:YES];
}

#pragma mark - 下拉完成调用
- (void)footerViewFinish {
	self.bNDLoading = NO;
	self.bRDLoading = NO;
    self.isNoMoreData = NO;
	[self.footerView refreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    // 已显示全部内容
    [self hideFooterView:YES];
}

- (void)footerViewNoData {
	self.bNDLoading = NO;
	self.bRDLoading = NO;
    self.isNoMoreData = YES; // 没有更多内容加载
	[self.footerView refreshScrollViewDataSourceDidFinishedLoadingWithNoData:self.tableView];
    
    // 已显示全部内容
    if (bReqFailed == YES) {
        [self hideFooterView:YES];
    }else {
        [self hideFooterView:NO];
    }
}

- (void)setIsTemporaryHideHeaderView:(BOOL)isTemporaryHideHeaderView {
	_isTemporaryHideHeaderView = isTemporaryHideHeaderView;
	self.headerView.hidden = isTemporaryHideHeaderView;
}

- (void)setIsTemporaryHideFooterView:(BOOL)isTemporaryHideFooterView {
	_isTemporaryHideFooterView = isTemporaryHideFooterView;
	self.footerView.hidden = isTemporaryHideFooterView;
}

- (void)setExtraCellLineHidden:(UITableView *)tView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tView setTableFooterView:view];
    [view release];
}

#pragma mark UIScrollViewDelegate Methods
// tableview正在拖动中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (!(scrollView.dragging || scrollView.tracking)) return;

	if (scrollView.contentOffset.y < 0) {
		if (self.isTemporaryHideHeaderView) return;

		[self.headerView refreshScrollViewDidScroll:scrollView];
	} else {
        
        if (self.isTemporaryHideFooterView && !self.bReqFailed ) return;

        self.isTemporaryHideFooterView = (self.bReqFailed && self.pageCount <= 0) || self.isNoMoreData;

		if (self.isTemporaryHideFooterView) return;
        if (self.bReqFailed && self.pageCount <= 0) return; // 无网络且无数据，不让尾部刷新
        if (self.isNoMoreData) return; // 没有更多数据，不让尾部刷新
		[self.footerView refreshScrollViewDidScroll:scrollView];
	}

	NSInteger height = MAX(self.tableView.contentSize.height, self.tableView.frame.size.height);
	self.footerView.frame = CGRectMake(0, height, self.frame.size.width, self.frame.size.height);
    
    if (self.isTemporaryHideFooterView) {
        self.footerView.hidden = YES;
    }else{
        self.footerView.hidden = NO;
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([tvDelegate respondsToSelector:@selector(tableViewbackgroundEndTouch)]) {
        [tvDelegate tableViewbackgroundEndTouch];
    }
}

// 松手
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (scrollView.contentOffset.y < 0) {
		if (self.isTemporaryHideHeaderView ) return;

		[self.headerView refreshScrollViewDidEndDragging:scrollView];
	} else {
        if (self.isTemporaryHideFooterView && !self.bReqFailed) return;

        self.isTemporaryHideFooterView = (self.bReqFailed && self.pageCount <= 0) || self.isNoMoreData;
		if (self.isTemporaryHideFooterView) {
			return;
		}
        if (self.bReqFailed && self.pageCount <= 0) return; // 无网络且无数据，不让尾部刷新
        if (self.isNoMoreData) return; // 没有更多数据，不让尾部刷新
		[self.footerView refreshScrollViewDidEndDragging:scrollView];
	}
}

//不用拖动，直接弹出刷新头部
- (void)didNoDragForLoading {
	if (tableView) {
        self.headerView.hidden = NO;
        [self.headerView refreshScrollViewDidEndDraggingForLoading:tableView];
    }
}

//不用拖动，不弹出刷新头部
- (void)didNoDragForLoadingNoPull {
	if (tableView) [self.headerView refreshScrollViewDidEndDraggingForLoadingNoPull:tableView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DragBackChange object:nil];

    headerView.delegate = nil;
    footerView.delegate = nil;
    tvDelegate = nil;
    RELEASE(tableView);
    
	if ((_mode == kHeadMode) || (_mode == kHeadAndFootMode)) {
		[headerView release];
	}

	if ((_mode == kFootMode) || (_mode == kHeadAndFootMode)) {
		[footerView release];
	}
	[super dealloc];
}

@end

