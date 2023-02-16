//
//  TJRRefreshTableHeaderView.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EVCircularProgressView.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


typedef enum
{
	HPullRefreshPulling = 0,
	HPullRefreshNormal,
	HPullRefreshLoading,	
} HPullRefreshState;

@protocol TJRRefreshTableHeaderDelegate;
@interface TJRRefreshTableHeaderView : UIView 
{
	id _delegate;
	HPullRefreshState _state;
    
	EVCircularProgressView *_activityView;
}
@property (nonatomic, strong) NSTimer *updateTimer;
@property(nonatomic,assign) id <TJRRefreshTableHeaderDelegate> delegate;
@property(nonatomic,retain) EVCircularProgressView *_activityView;
- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)refreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)refreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
- (void)refreshScrollViewDidEndDraggingForLoading:(UITableView *)tableView;
- (void)refreshScrollViewDidEndDraggingForLoadingNoPull:(UITableView *)tableView;

-(UIActivityIndicatorView*)getActivityView;

@end
@protocol TJRRefreshTableHeaderDelegate
- (void)refreshTableHeaderDidTriggerRefresh:(TJRRefreshTableHeaderView*)view;
- (BOOL)refreshTableHeaderDataSourceIsLoading:(TJRRefreshTableHeaderView*)view;
@optional
- (NSDate*)refreshTableHeaderDataSourceLastUpdated:(TJRRefreshTableHeaderView*)view;
@end
