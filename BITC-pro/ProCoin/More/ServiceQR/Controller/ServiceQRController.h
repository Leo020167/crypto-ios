//
//  ServiceQRController.h
//  BYY
//
//  Created by Hay on 2019/9/25.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServiceQRController : TJRBaseViewController

- (void)showServiceQRControllerInController:(UIViewController *)controller title:(NSString *)title content:(NSString *)content qrUrl:(NSString *)qrUrl;

@end

NS_ASSUME_NONNULL_END
