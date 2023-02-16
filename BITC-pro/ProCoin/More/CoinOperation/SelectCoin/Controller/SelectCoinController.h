//
//  SelectCoinController.h
//  BYY
//
//  Created by Hay on 2019/9/23.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"

@protocol SelectCoinControllerDelegate <NSObject>

@optional

- (void)selectCoinDidSelctedWithSymol:(NSString *_Nonnull)symbol;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SelectCoinController : UIViewController

@property (assign, nonatomic) id<SelectCoinControllerDelegate> delegate;

- (void)reloadSelectCoinData:(NSArray *)data;

@end

NS_ASSUME_NONNULL_END
