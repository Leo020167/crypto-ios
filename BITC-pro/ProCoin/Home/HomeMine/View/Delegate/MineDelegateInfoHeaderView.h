//
//  MineDelegateInfoHeaderView.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/10/28.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MineDelegateInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MineDelegateInfoHeaderView : UIView

@property (nonatomic, strong) MineDelegateInfoModel *model;

@property (nonatomic, copy) void(^upgradeBtnActionBlock)(void);

@end

NS_ASSUME_NONNULL_END
