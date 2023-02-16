//
//  MTDashLine.h
//  ProCoin
//
//  Created by Luo Chun on 2022/11/27.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Simple UIView for a dotted line
 */
@interface MTDashLine : UIView

/**
 *  Set the line's thickness
 */
@property (nonatomic, assign) IBInspectable CGFloat thickness;

/**
 *  Set the line's color
 */
@property (nonatomic, copy) IBInspectable UIColor *color;

/**
 *  Set the length of the dash
 */
@property (nonatomic, assign) IBInspectable CGFloat dashedLength;

/**
 *  Set the gap between dashes
 */
@property (nonatomic, assign) IBInspectable CGFloat dashedGap;

@end

NS_ASSUME_NONNULL_END


