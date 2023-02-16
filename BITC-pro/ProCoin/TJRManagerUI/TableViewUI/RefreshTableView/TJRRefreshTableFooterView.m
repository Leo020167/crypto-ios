//
//  TJRRefreshTableFooterView.m
//  TableViewPull
//
//  Created by hh hh on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TJRRefreshTableFooterView.h"

@interface TJRRefreshTableFooterView (Private)
- (void)setState:(FPullRefreshState)aState;
@end

@implementation TJRRefreshTableFooterView
@synthesize delegate = _delegate;
@synthesize pageNum;
@synthesize statusLabel;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		pageNum = 1;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.frame.size.width, 20.0f)];
		[label setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
		label.font = [UIFont systemFontOfSize:13.0f];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		statusLabel = label;
        
        _evcProgressView = [[EVCircularProgressView alloc] initWithFrame:CGRectMake(100, 10, 40, 40)];
        [_evcProgressView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
        _evcProgressView.isFooter = YES;
        [self addSubview:_evcProgressView];
        
	}

	return self;
}

- (void)layoutSubviews{
    [statusLabel sizeToFit];
    CGRect rect = statusLabel.frame;
    rect.origin.y = (60 - CGRectGetHeight(rect))/2.0;
    rect.origin.x = self.center.x - CGRectGetWidth(rect)/2.0;
    statusLabel.frame = rect;
    CGRect rect1 = _evcProgressView.frame;
    rect1.origin.x = rect.origin.x - 5 - CGRectGetWidth(rect1);
    _evcProgressView.frame = rect1;
}


- (UILabel *)getStatusLabel {
	return statusLabel;
}

- (EVCircularProgressView*)getEvcProgressView {
    return _evcProgressView;
}

- (void)setState:(FPullRefreshState)aState {
    statusLabel.hidden = false;
	switch (aState) {
		case FPullRefreshPulling:

			statusLabel.text = NSLocalizedString(@"松开可读取...", @"Release to refresh status");
            _evcProgressView.hidden = YES;
			break;

		case FPullRefreshNormal:

			statusLabel.text = NSLocalizedString(@"读取更多...", @"Pull down to refresh status");
            _evcProgressView.hidden = YES;
			UITableView *tableView = (UITableView *)[self nextResponder];

			if (tableView) {
				self.hidden = YES;
				[tableView sendSubviewToBack:self];
			}

			break;

		case FPullRefreshLoading:
			statusLabel.text = NSLocalizedString(@"加载中...", @"Loading Status");
            _evcProgressView.hidden = NO;
            [_evcProgressView setProgress:-1 animated:YES];

			break;

		default:
			break;
	}
    [self layoutSubviews];
	_state = aState;
}

#pragma mark -
#pragma mark ScrollView Methods
- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView 
{	
    if(_state == FPullRefreshLoading) 
    {
        CGFloat offset = MAX(scrollView.contentOffset.y, 0);
        offset = MIN(offset, 60);
        [UIView animateWithDuration:0.3 animations:^{
            UIEdgeInsets edgeInsets = scrollView.contentInset;
            edgeInsets.bottom = offset;
            scrollView.contentInset = edgeInsets;
//            scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, offset, 0.0f);
        }];
    }
    else if (scrollView.isDragging) 
    {
        
//        BOOL _loading = NO;
//        
//        if ([_delegate respondsToSelector:@selector(refreshTableFooterDataSourceIsLoading:)]) {
//            _loading = [_delegate refreshTableFooterDataSourceIsLoading:self];
//        }
//        
//        if ((int)scrollView.contentSize.height != 0) {
//            int height = MAX(scrollView.contentSize.height, scrollView.frame.size.height);
//            
//            if ((scrollView.contentOffset.y + scrollView.frame.size.height > height + 60.0f) && !_loading) {
//                if ([_delegate respondsToSelector:@selector(refreshTableFooterDidTriggerRefresh:)]) {
//                    [_delegate refreshTableFooterDidTriggerRefresh:self];
//                }
//                [self setState:FPullRefreshLoading];
//                if (scrollView.contentSize.height > scrollView.frame.size.height) {
//                    [UIView beginAnimations:nil context:NULL];
//                    [UIView setAnimationDuration:0.2];
//                    scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
//                    [UIView commitAnimations];
//                }
//            }
//        }
        
        BOOL _loading = NO;
        
        if ([_delegate respondsToSelector:@selector(refreshTableFooterDataSourceIsLoading:)]) 
        {
            _loading = [_delegate refreshTableFooterDataSourceIsLoading:self];
        }
        if (scrollView.contentSize.height > scrollView.frame.size.height) {
            if(_state == FPullRefreshPulling && scrollView.contentOffset.y + (scrollView.frame.size.height) < scrollView.contentSize.height + 60.0f)
                //&& scrollView.contentOffset.y > scrollView.frame.size.height 当item项太少时,这个条件不成立,item项多时.是绝对成立的
            {
                [self setState:FPullRefreshNormal];
            }
            else if(_state == FPullRefreshNormal && scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + 60.0f  && !_loading)
            {
                [self setState:FPullRefreshPulling];
            }
        }else{
            if(_state == FPullRefreshPulling && scrollView.contentOffset.y < 60.0f)
            {
                [self setState:FPullRefreshNormal];
            }
            else if(_state == FPullRefreshNormal && scrollView.contentOffset.y > 60.0f  && !_loading)
            {
                [self setState:FPullRefreshPulling];
            }
            
        }
        
        if(scrollView.contentInset.bottom != 0) 
        {
            UIEdgeInsets edgeInsets = scrollView.contentInset;
            edgeInsets.bottom = 0;
            scrollView.contentInset = edgeInsets;
//            scrollView.contentInset = UIEdgeInsetsZero;
		}
	} else {
		[self setState:FPullRefreshNormal];
	}
}

- (void)refreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	BOOL _loading = NO;

	if ([_delegate respondsToSelector:@selector(refreshTableFooterDataSourceIsLoading:)]) {
		_loading = [_delegate refreshTableFooterDataSourceIsLoading:self];
	}

	if ((int)scrollView.contentSize.height != 0) {
		int height = MAX(scrollView.contentSize.height, scrollView.frame.size.height);

		if ((scrollView.contentOffset.y + scrollView.frame.size.height > height + 60.0f) && !_loading) {
			if ([_delegate respondsToSelector:@selector(refreshTableFooterDidTriggerRefresh:)]) {
				[_delegate refreshTableFooterDidTriggerRefresh:self];
			}
			[self setState:FPullRefreshLoading];

            if (scrollView.contentSize.height > scrollView.frame.size.height) {
                [UIView animateWithDuration:0.4 animations:^{
                    UIEdgeInsets edgeInsets = scrollView.contentInset;
                    edgeInsets.bottom = 60.0f;
                    scrollView.contentInset = edgeInsets;
//                    scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
                }];
            }
		}
	}
}

- (void)refreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	[self setState:FPullRefreshNormal];
}

- (void)refreshScrollViewDataSourceDidFinishedLoadingWithNoData:(UIScrollView *)scrollView {
    [UIView animateWithDuration:0.3 animations:^{
//        scrollView.contentInset = UIEdgeInsetsZero;
        UIEdgeInsets edgeInsets = scrollView.contentInset;
        edgeInsets.bottom = 0;
        scrollView.contentInset = edgeInsets;
    }];

	[self setState:FPullRefreshNormal];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[_evcProgressView release];
	[statusLabel release];
	[super dealloc];
}

@end

