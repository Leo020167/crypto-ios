//
//  PersonalInfoHeaderView.h
//  Cropyme
//
//  Created by Hay on 2019/6/10.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCPersonalInfoModel.h"

@protocol PersonalInfoHeaderViewDelegate <NSObject>

@optional

/** 订阅按钮点击事件*/
- (void)infoHeaderViewSubscribeUserDidSelected;

/** 跟单按钮点击事件*/
- (void)infoHeaderViewFollowOrderDidSelected;

/** 综合评分说明详情按钮点击事件*/
- (void)infoHeaderViewRadarInfoDidSelected;

@end

NS_ASSUME_NONNULL_BEGIN

@interface PersonalInfoHeaderView : UIView

@property (assign, nonatomic) id<PersonalInfoHeaderViewDelegate> delegate;

#pragma mark - 获取headerView高度
- (CGFloat)infoHeaderViewCurrentHeight;

/** 更新数据*/
- (void)reloadInfoHeaderView:(PCPersonalInfoModel *)infoEntity;

@end

NS_ASSUME_NONNULL_END
