//
//  TYAccountTokenInfoCell.h
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/4.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCAccountModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TYAccountTokenInfoCell : UITableViewCell

@property (nonatomic, strong) UIButton *getBtn;

@property (nonatomic, strong) PCAccountModel *tokenModel;

@end

NS_ASSUME_NONNULL_END
