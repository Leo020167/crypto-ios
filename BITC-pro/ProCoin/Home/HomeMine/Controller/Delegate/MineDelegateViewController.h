//
//  MineDelegateViewController.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/10/24.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MineDelegateViewController : TJRBaseViewController

/// 返回status,前端判断status为0，为未申请代理;status为1，为申请中状态;status为2，取返回值里的agent作为代理展示数据
@property (nonatomic, assign) NSInteger status;

@end

NS_ASSUME_NONNULL_END
