//
//  CountrySelectController.h
//  BYY
//
//  Created by Hay on 2019/9/26.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"
#import "CountryCodeInfoEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface CountrySelectController : TJRBaseViewController

@property (nonatomic, copy) void(^chooseDataBlock)(CountryCodeInfoEntity *model);

@end

NS_ASSUME_NONNULL_END
