//
//  PersonalMainFollowAlertController.h
//  ProCoin
//
//  Created by 李祥翔 on 2021/12/27.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersonalMainFollowAlertController : UIViewController

@property (nonatomic, copy) void(^sureBtnActionBlock)(void);

@end

NS_ASSUME_NONNULL_END
