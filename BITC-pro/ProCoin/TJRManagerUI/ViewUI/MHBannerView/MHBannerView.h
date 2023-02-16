//
//  MHBannerView.h
//  Cropyme
//
//  Created by Hay on 2019/7/9.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MHBannerViewDelegate <NSObject>

@optional
- (void)bannerViewDidTapImage:(NSInteger)index;

@end


@interface MHBannerView : UIView

@property (assign, nonatomic) id<MHBannerViewDelegate> delegate;

/** 数据源*/
@property (copy, nonatomic) NSArray<NSString *> *dataArray;

/** 设置是否自动滚动*/
- (void)setAutoScroll:(BOOL)autoScroll;

@end


