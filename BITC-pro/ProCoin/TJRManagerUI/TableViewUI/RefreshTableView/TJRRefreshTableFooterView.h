//
//  TJRRefreshTableFooterView.h
//  TableViewPull
//
//  Created by hh hh on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EVCircularProgressView.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f

typedef enum
{
	FPullRefreshPulling = 0,
	FPullRefreshNormal,
	FPullRefreshLoading,	
} FPullRefreshState;

@protocol TJRRefreshTableFooterDelegate;
@interface TJRRefreshTableFooterView : UIView 
{
    NSInteger pageNum;
	id _delegate;
	FPullRefreshState _state;
	UILabel *statusLabel;
    EVCircularProgressView *_evcProgressView;
}

@property (retain, nonatomic)   UILabel *statusLabel;
@property(nonatomic,assign) id <TJRRefreshTableFooterDelegate> delegate;
@property (nonatomic, assign) NSInteger pageNum;

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)refreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)refreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
- (void)refreshScrollViewDataSourceDidFinishedLoadingWithNoData:(UIScrollView *)scrollView;

-(UILabel*)getStatusLabel;
-(EVCircularProgressView*)getEvcProgressView;

@end

@protocol TJRRefreshTableFooterDelegate
- (void)refreshTableFooterDidTriggerRefresh:(TJRRefreshTableFooterView*)view;
- (BOOL)refreshTableFooterDataSourceIsLoading:(TJRRefreshTableFooterView*)view;
@end
