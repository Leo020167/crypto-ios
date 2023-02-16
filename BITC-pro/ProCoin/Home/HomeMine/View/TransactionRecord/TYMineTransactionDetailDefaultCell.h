//
//  TYMineTransactionDetailDefaultCell.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/4/8.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYMineTransactionDetailDefaultCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UIButton *settingBtn;

@property (nonatomic, strong) UIImageView *imgImageView;

@property (nonatomic, strong) QMUIButton *descBtn;

@property (nonatomic, copy) void(^settingBtnActionBlock)(void);

@end

NS_ASSUME_NONNULL_END
