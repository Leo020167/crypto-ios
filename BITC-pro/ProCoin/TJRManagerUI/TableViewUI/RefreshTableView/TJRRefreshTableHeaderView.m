//
//  TJRRefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "TJRRefreshTableHeaderView.h"

@interface TJRRefreshTableHeaderView (Private)

- (void)setState:(HPullRefreshState)aState;
@end

@implementation TJRRefreshTableHeaderView

@synthesize _activityView;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {

		_activityView = [[EVCircularProgressView alloc] init];
		[_activityView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
		_activityView.frame = CGRectMake((frame.size.width - 100) / 2.0, frame.size.height - 55.0f, 100.0f, 55.0f);
		[self addSubview:_activityView];
	}

	return self;
}

- (void)layoutSubviews{

    self._activityView.frame = CGRectMake((self.frame.size.width - 100) / 2.0, self.frame.size.height - 55.0f, 100.0f, 55.0f);
}

- (void)setState:(HPullRefreshState)aState {
	switch (aState) {
		case HPullRefreshPulling:
			_activityView.hidden = NO;
			break;

		case HPullRefreshNormal:
			_activityView.hidden = NO;
			break;

		case HPullRefreshLoading:
            _activityView.hidden = NO;
			break;

		default:
			break;
	}

	_state = aState;
}


- (EVCircularProgressView *)getActivityView {
	return _activityView;
}

#pragma mark -
#pragma mark ScrollView Methods

- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView {
	if (_state == HPullRefreshLoading) {
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);

		[UIView animateWithDuration:0.6 animations:^{
			scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, offset, 0.0f);
		}];
		[_activityView setProgress:-1  animated:YES];
	} else if (scrollView.isDragging) {
		BOOL _loading = NO;
        
        CGFloat y = scrollView.contentOffset.y;
		if ([_delegate respondsToSelector:@selector(refreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate refreshTableHeaderDataSourceIsLoading:self];
		}

		if ((_state == HPullRefreshPulling) && (y > -60.0f) && (y < 0.0f) && !_loading) {
			[self setState:HPullRefreshNormal];
		} else if ((_state == HPullRefreshNormal) && (y < -60.0f) && !_loading) {
			[self setState:HPullRefreshPulling];
		}

		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
        if (y <= -40) {//拖动40(40-60)才显示进度动画,原来为0-60
            [_activityView setProgress:MIN(fabs(y+40), 20.0f) / 20  animated:YES];
        } else {
            [_activityView setProgress:0  animated:YES];
        }
	}
}

- (void)refreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	BOOL _loading = NO;

	if ([_delegate respondsToSelector:@selector(refreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate refreshTableHeaderDataSourceIsLoading:self];
	}

	if ((scrollView.contentOffset.y <= -60.0f) && !_loading) {
		[_activityView setProgress:-1  animated:YES];
		[self setState:HPullRefreshLoading];
		[UIView animateWithDuration:0.6 animations:^{
			scrollView.contentInset = UIEdgeInsetsMake(MAX(60.0f, scrollView.contentInset.top), 0.0f, 0.0f, 0.0f);
		} completion:^(BOOL finish) {
			if ([_delegate respondsToSelector:@selector(refreshTableHeaderDidTriggerRefresh:)]) {
				[_delegate refreshTableHeaderDidTriggerRefresh:self];
			}
		}];
	}
}

//不用拖动，直接弹出刷新头部
- (void)refreshScrollViewDidEndDraggingForLoading:(UITableView *)tableView {
	[tableView setContentOffset:CGPointMake(0, 0) animated:NO];
	[self setState:HPullRefreshLoading];
	[UIView animateWithDuration:0.3 animations:^{
		tableView.contentOffset = CGPointMake(0, -66.0f);
	} completion:^(BOOL finish) {
		[self refreshScrollViewDidEndDragging:tableView];
	}];
}

//不用拖动，直接弹出刷新头部
- (void)refreshScrollViewDidEndDraggingForLoadingNoPull:(UITableView *)tableView {
	BOOL _loading = NO;

	if ([_delegate respondsToSelector:@selector(refreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate refreshTableHeaderDataSourceIsLoading:self];
	}

	if (!_loading) {
		[UIView animateWithDuration:0.3 animations:^{
			tableView.contentInset = UIEdgeInsetsMake(MAX(60.0f, tableView.contentInset.top), 0.0f, 0.0f, 0.0f);
		} completion:^(BOOL finish) {
			if ([_delegate respondsToSelector:@selector(refreshTableHeaderDidTriggerRefresh:)]) {
				[_delegate refreshTableHeaderDidTriggerRefresh:self];
			}
			[self setState:HPullRefreshLoading];
		}];
	}
}

- (void)refreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	[UIView animateWithDuration:0.6 animations:^{
		[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	} completion:^(BOOL finish) {
		[self setState:HPullRefreshNormal];
	}];
}

- (void)dealloc {
	[_activityView release];
	[super dealloc];
}

@end
