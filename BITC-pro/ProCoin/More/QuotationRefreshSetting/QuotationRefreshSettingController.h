//
//  QuotationRefreshSettingController.h
//  ProCoin
//
//  Created by Hay on 2020/3/4.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QuotationRefreshTimeModel : NSObject

- (instancetype)initWithTitle:(NSString *)title time:(NSString *)time isSelected:(BOOL)isSelected;
+ (QuotationRefreshTimeModel *)refreshTimeModelWithTitle:(NSString *)title time:(NSString *)time isSelected:(BOOL)isSelected;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *time;
@property (assign, nonatomic) BOOL isSelected;

@end


@interface QuotationRefreshSettingController : TJRBaseViewController

@end

NS_ASSUME_NONNULL_END
