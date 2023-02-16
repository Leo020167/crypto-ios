//
//  TYAccountFinancialRecordeHeaderView.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/8/14.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYAccountFinancialRecordeHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) QMUIButton *financialBtn;

@property (nonatomic, strong) QMUIButton *positionBtn;

@property (nonatomic, strong) QMUIButton *allBtn;

@property (nonatomic, copy) void(^btnClickActionBlock)(NSInteger tag);

@end

NS_ASSUME_NONNULL_END
