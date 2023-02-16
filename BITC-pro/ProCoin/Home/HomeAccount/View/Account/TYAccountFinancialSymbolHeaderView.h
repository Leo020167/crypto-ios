//
//  TYAccountFinancialSymbolHeaderView.h
//  ProCoin
//
//  Created by Luo Chun on 2022/12/4.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYAccountFinancialSymbolHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) UISwitch *filterSwitch;
@property (nonatomic, strong) UILabel *desLabel;
//@property (nonatomic, strong) UITextField *searchField;

@property (nonatomic, copy) void(^filterActionBlock)(BOOL isFilter);
@property (nonatomic, copy) void(^searchActionBlock)(NSString *text);


@end

NS_ASSUME_NONNULL_END
