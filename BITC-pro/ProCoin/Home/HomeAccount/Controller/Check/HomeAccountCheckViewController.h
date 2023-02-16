//
//  HomeAccountCheckViewController.h
//  ProCoin
//
//  Created by 祥翔李 on 2021/10/31.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeAccountCheckViewController : TJRBaseViewController

@property (nonatomic, copy) void(^checkDataBlock)(void);

@end

NS_ASSUME_NONNULL_END
