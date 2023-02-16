//
//  TJRPullToLoadFooterView.m
//  BProject
//
//  Created by taojinroad on 14-6-20.
//  Copyright (c) 2014年 UnWood. All rights reserved.
//

#define kTotalViewHeight    40

#import "TJRPullToLoadFooterView.h"

@interface TJRPullToLoadFooterView ()
{
    BOOL bDone;
}
@property (nonatomic, readwrite) BOOL refreshing;
@property (nonatomic, assign) UIScrollView *scrollView;

@end

@implementation TJRPullToLoadFooterView

- (id)initInScrollView:(UIScrollView *)scrollView {
    
    self = [super initWithFrame:CGRectMake(0, -(kTotalViewHeight + scrollView.contentInset.top), scrollView.frame.size.width, kTotalViewHeight)];
    
    if (self) {
        self.scrollView = scrollView;
        [[[NSBundle mainBundle] loadNibNamed:@"TJRPullToLoadFooterView" owner:self options:nil] lastObject];
        [self addSubview:self.view];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        bDone = YES;
    }
    return self;
}

- (void)layoutSubviews{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, _scrollView.frame.size.width, self.view.frame.size.height);
}

- (void)setState:(FPullRefreshState)aState {
	switch (aState) {
		case FPullRefreshNormal:
			[_indicatorView stopAnimating];
			break;
            
		case FPullRefreshLoading:
			[_indicatorView startAnimating];
            break;
            
		default:
			break;
	}
    
	_state = aState;
}


- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView
{

    BOOL _loading = NO;
    
    if(_state == FPullRefreshLoading)
    {
        _loading = YES;
    }
    else if (self.scrollView.isDragging)
    {
        
        if(_state == FPullRefreshLoading && self.scrollView.contentOffset.y >= 40.0f && self.scrollView.contentOffset.y < 0.0f && !_loading)
        {
            [self setState:FPullRefreshNormal];
        }
        else if(_state == FPullRefreshNormal && self.scrollView.contentOffset.y <= 40.0f && !_loading)
        {
            [self setState:FPullRefreshLoading];
            [self loadMore];
        }
        
        if(self.scrollView.contentInset.bottom != 0)
        {
            self.scrollView.contentInset = UIEdgeInsetsZero;
        }
    } else {
        [self setState:FPullRefreshNormal];
    }
}


- (void)loadMore{
    if (bDone) {
        bDone = NO;
        [_indicatorView startAnimating];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)endRefresh:(BOOL)hasData{
    [_indicatorView stopAnimating];
    [self setState:FPullRefreshNormal];
    bDone = YES;
}

- (void)endRefreshWithError{
    [_indicatorView stopAnimating];
    bDone = YES;
}


- (void)dealloc {
    
    [_view release];
    [_indicatorView release];
    [super dealloc];
}
@end
