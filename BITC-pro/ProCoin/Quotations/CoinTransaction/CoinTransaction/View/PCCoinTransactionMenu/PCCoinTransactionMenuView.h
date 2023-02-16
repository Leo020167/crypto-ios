//
//  PCCoinTransactionMenuView.h
//  ProCoin
//
//  Created by Hay on 2020/2/26.
//  Copyright © 2020 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PCCoinTransactionMenuViewDelegate <NSObject>

@optional

- (void)menuViewDidClick:(UIView *)menuView row:(NSInteger)row unitTitle:(NSString *)title;

@end



@interface PCCoinTransactionMenuView : UIViewController

- (instancetype _Nullable)initTransactionView:(id)delegate titleArray:(NSArray<NSString *>  *_Nonnull)titleArray menuUnitSize:(CGSize)size menuFont:(UIFont * _Nullable)font menuFontColor:(UIColor * _Nullable)fontColor;


- (void)presentInView:(UIView *)sender;
@end

NS_ASSUME_NONNULL_END
