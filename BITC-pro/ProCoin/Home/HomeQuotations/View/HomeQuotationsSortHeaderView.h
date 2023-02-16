//
//  HomeQuotationsSortHeaderView.h
//  BYY
//
//  Created by Hay on 2019/10/22.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHSortButton.h"


static NSString *HomeQuotationsSortFieldName = @"symbol";    //名称
static NSString *HomeQuotationsSortFieldPrice = @"price";   //最新价
static NSString *HomeQuotationsSortFieldRate = @"rate";    //涨跌幅

@protocol HomeQuotationSortHeaderViewDelegate <NSObject>

@optional
/**
 *@brief 排序按钮点击回调
 */
- (void)sortHeaderView:(UIView *)sortView sortField:(NSString *)field sortState:(SortButtonState)state;

@end


@interface HomeQuotationsSortHeaderView : UIView

@property (assign, nonatomic) id<HomeQuotationSortHeaderViewDelegate> delegate;


- (SortButtonState)currentSortState;

- (NSString *)currentSortField;

@end


