//
//  TJRPullToLoadTableView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12/11/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRPullToLoadFooterView.h"

@interface TJRPullToLoadTableView : UITableView{

}

- (void)footerViewEndDidRefresh;
- (void)footerViewEndRefreshNoData;
- (void)footerViewEndRefreshWithError;

- (void)initialization;
- (void)footerViewRefreshing:(TJRPullToLoadFooterView *)control;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
@end
