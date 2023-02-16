//
//  PledgeBuyViewController.h
//  ProCoin
//
//  Created by Luo Chun on 2022/11/24.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PledgeBuyViewController : UIViewController
- (void)addSelfToParentViewController:(UIViewController *)controller pledge:(NSDictionary *)pledge;
@end

NS_ASSUME_NONNULL_END
