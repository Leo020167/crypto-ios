//
//  CostSymbolHeaderView.h
//  Cropyme
//
//  Created by Hay on 2019/8/12.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CostSymbolHeaderViewDelegate <NSObject>

@optional

- (void)headerViewDidPressedSymbolButtonWithIndex:(NSInteger)index;

@end


@interface CostSymbolHeaderView : UIView

@property (assign, nonatomic) id<CostSymbolHeaderViewDelegate> delegate;
@property (assign, nonatomic, readonly) BOOL isHasOptionsButton;             //是否已经存在symbol按钮

- (void)reloadSymbolHeaderViewWithSymbolArr:(NSArray *)symbolArr;

@end


