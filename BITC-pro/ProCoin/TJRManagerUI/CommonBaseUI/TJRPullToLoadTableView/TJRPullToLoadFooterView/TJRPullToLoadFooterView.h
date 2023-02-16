//
//  TJRPullToLoadFooterView.h
//  BProject
//
//  Created by taojinroad on 14-6-20.
//  Copyright (c) 2014年 UnWood. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
	FPullRefreshNormal = 0,
	FPullRefreshLoading,
} FPullRefreshState;

@interface TJRPullToLoadFooterView : UIControl{
    FPullRefreshState _state;
}

@property (retain, nonatomic) IBOutlet UIView *view;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

- (id)initInScrollView:(UIScrollView *)scrollView;
- (void)endRefresh:(BOOL)hasData;
- (void)endRefreshWithError;

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView;

@end
