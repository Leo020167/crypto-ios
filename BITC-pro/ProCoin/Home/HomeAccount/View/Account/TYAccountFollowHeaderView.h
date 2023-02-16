//
//  TYAccountFollowHeaderView.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/4.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCHomeUserFollowOrderInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYAccountFollowHeaderView : UIView

@property (nonatomic, strong) UIButton *bindBtn;

@property (nonatomic, strong) PCHomeUserFollowOrderInfoModel *model;

@end

NS_ASSUME_NONNULL_END
