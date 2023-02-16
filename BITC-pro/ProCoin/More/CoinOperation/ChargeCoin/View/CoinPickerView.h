//
//  CoinPickerView.h
//  Cropyme
//
//  Created by Hay on 2019/9/10.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoinPickerViewDelegate <NSObject>

@optional
- (void)coinPickerViewDidSelectedIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface CoinPickerView : UIView

@property (assign, nonatomic) id<CoinPickerViewDelegate> delegate;


- (void)showCoinPickerViewWithView:(UIView *)view;


- (void)reloadCoinPickerView:(NSArray *)dataArr;
- (void)reloadCoinPickerViewSelectRow:(NSInteger)selectRow;

@end

NS_ASSUME_NONNULL_END
