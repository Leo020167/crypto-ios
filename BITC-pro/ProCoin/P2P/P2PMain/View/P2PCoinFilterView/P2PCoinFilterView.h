//
//  P2PCoinFilterView.h
//  ProCoin
//
//  Created by Luo Chun on 2023/2/13.
//  Copyright © 2023 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class P2PCoinFilterView;

@protocol P2PCoinFilterViewDelegate <NSObject>

@optional
- (void)p2pSymbolView:(P2PCoinFilterView *)menuView dismissView:(id)sender;
- (void)p2pSymbolView:(P2PCoinFilterView *)menuView selected: (NSString *)symbol;
@end

@interface P2PCoinFilterView : UIView

- (void)showInView:(UIView *)view;

- (void)dismissView;

@property (assign, nonatomic) id<P2PCoinFilterViewDelegate> delegate;
@property (assign, nonatomic) BOOL displayed;


/// 币种类型
@property (nonatomic, copy) NSString *coinType;

@property (nonatomic, strong) NSMutableArray *coinTypeArray;


@end

NS_ASSUME_NONNULL_END
