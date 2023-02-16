//
//  TJRPullToLoadTableView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12/11/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "TJRPullToLoadTableView.h"
#import "TJRPullToLoadFooterView.h"

@interface TJRPullToLoadTableView ()<UIScrollViewDelegate>
{
    TJRPullToLoadFooterView* footerView;
}
@end

@implementation TJRPullToLoadTableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialization];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialization];
    }
    
    return self;
}

- (void)initialization {
 
    
    footerView = [[TJRPullToLoadFooterView alloc] initInScrollView:self];
    [footerView addTarget:self action:@selector(footerViewRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    self.tableHeaderView = footerView;
}

- (void)setContentSize:(CGSize)contentSize
{
    if (!CGSizeEqualToSize(self.contentSize, CGSizeZero))
    {
        if (contentSize.height > self.contentSize.height)
        {
            CGPoint offset = self.contentOffset;
            offset.y += (contentSize.height - self.contentSize.height);
            self.contentOffset = offset;
        }
    }
    [super setContentSize:contentSize];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!(scrollView.dragging || scrollView.tracking)) return;
    [footerView refreshScrollViewDidScroll:scrollView];

}


- (void)dealloc{
    [footerView removeTarget:self action:@selector(footerViewRefreshing:) forControlEvents:UIControlEventValueChanged];
    [footerView release];
    [super dealloc];
}


#pragma mark - footerView
- (void)footerViewRefreshing:(TJRPullToLoadFooterView *)control{

}

- (void)footerViewEndDidRefresh{
    [footerView endRefresh:YES];
}

- (void)footerViewEndRefreshNoData{
    [footerView endRefresh:YES];

    [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
        footerView.hidden = YES;
    }completion:^(BOOL finished){
        self.tableHeaderView = nil;
    }];
}

- (void)footerViewEndRefreshWithError{
    [footerView endRefreshWithError];
}


@end
