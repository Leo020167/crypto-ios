//
//  NewFeaturesView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 13-4-27.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewFeaturesDelegate <NSObject>

- (void)newFeaturesIKnowOnClick;

@end

@interface NewFeaturesView : UIView {
    UIScrollView *svScroll;
    NSArray *imageArray;
    NSArray *bottomColorArray;
    id<NewFeaturesDelegate> delegate;
}
//- (id)initWithFrame:(CGRect)frame delegate:(id<NewFeaturesDelegate>)_delegate;
#pragma mark - 检查是否显示软件新功能介绍
+ (BOOL)isShowNewFeaturesView;
#pragma mark - 显示软件新功能提示
- (void)showNewFeatures:(UIView *)view;
@end
