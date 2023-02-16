//
//  PICircularProgressView.h
//  PICircularProgressView
//
//  Created by Dominik Alexander on 11.06.13.
//  Copyright (c) 2013 Dominik Alexander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PICircularProgressView : UIView

@property (nonatomic) double progress;

// Should be BOOLs, but iOS doesn't allow BOOL as UI_APPEARANCE_SELECTOR
@property (nonatomic) NSInteger showText UI_APPEARANCE_SELECTOR;
@property (nonatomic) NSInteger roundedHead UI_APPEARANCE_SELECTOR;
@property (nonatomic) NSInteger showShadow UI_APPEARANCE_SELECTOR;

@property (nonatomic, copy) NSString *roundedHeadName UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGFloat thicknessRatio UI_APPEARANCE_SELECTOR;

@property (nonatomic, retain) UIColor *innerBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, retain) UIColor *outerBackgroundColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, retain) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, retain) UIFont *font UI_APPEARANCE_SELECTOR;

@property (nonatomic, retain) UIColor *progressFillColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, retain) UIColor *progressTopGradientColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, retain) UIColor *progressBottomGradientColor UI_APPEARANCE_SELECTOR;
@end
