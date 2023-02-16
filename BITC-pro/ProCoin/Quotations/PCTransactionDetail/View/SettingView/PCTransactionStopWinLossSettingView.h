//
//  PCTransactionStopWinLossSettingView.h
//  ProCoin
//
//  Created by Hay on 2020/3/1.
//  Copyright © 2020 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCTransactionStopWinLossSettingView;

typedef NS_ENUM(NSInteger, PCTDStopWinLossType){
    PCTDStopLossType = 0,
    PCTDStopWinType,
};

@protocol PCTransactionStopWinLossSettingViewDelegate <NSObject>

@required
- (void)stopWinLossSettingView:(PCTransactionStopWinLossSettingView *)settingView commitDataButtonPressedWithSettingType:(PCTDStopWinLossType)type limitPrice:(NSString *)limitPrice;

@end



@interface PCTransactionStopWinLossSettingView : UIView

@property (assign, nonatomic) id<PCTransactionStopWinLossSettingViewDelegate> delegate;

@property (assign, nonatomic) NSInteger priceDecimals;            //输入价格的小数位数

#pragma mark - 显示与消失
- (void)showViewInView:(UIView *)view settingType:(PCTDStopWinLossType)type;

- (void)dimissViewWithAnimation;

@end


