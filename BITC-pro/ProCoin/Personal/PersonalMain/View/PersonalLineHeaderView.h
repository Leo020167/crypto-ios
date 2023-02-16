//
//  PersonalLineHeaderView.h
//  Cropyme
//
//  Created by Hay on 2019/6/10.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineDataEntity.h"

typedef enum {
    KindButtonType_Trend,
    KindButtonType_Follow,
    KindButtonType_Trade,
    KindButtonType_Profit
}KindButtonType;

typedef enum {
    TimeButtonType_OneMonth,
    TimeButtonType_ThreeMonth,
    TimeButtonType_SixMonth,
    TimeButtonType_OneYear
}TimeButtonType;


@protocol PersonalLineHeaderViewDelegate <NSObject>

@optional
- (void)lineHeaderViewOptionDidChangedWithKindType:(KindButtonType)kindType timeType:(TimeButtonType)timeType;

@end

NS_ASSUME_NONNULL_BEGIN

@interface PersonalLineHeaderView : UIView

@property (assign, nonatomic) id<PersonalLineHeaderViewDelegate> delegate;

/** 更新数据*/
- (void)reloadLineHeaderViewData:(NSMutableArray *)dataArr;

@end

NS_ASSUME_NONNULL_END
