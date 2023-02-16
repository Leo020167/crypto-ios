//
//  TJRTabBarItem.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/1/20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJRTabBarItem : UIControl

/**
 * itemHeight is an optional property. When set it is used instead of tabBar's height.
 */
@property CGFloat itemHeight;

#pragma mark - Title configuration

/**
 * The title displayed by the tab bar item.
 */
@property (nonatomic, copy) NSString *title;

/**
 * The offset for the rectangle around the tab bar item's title.
 */
@property (nonatomic) UIOffset titlePositionAdjustment;

/**
 * For title's text attributes see
 * https://developer.apple.com/library/ios/documentation/uikit/reference/NSString_UIKit_Additions/Reference/Reference.html
 */

/**
 * The title attributes dictionary used for tab bar item's unselected state.
 */
@property (nonatomic,copy) NSDictionary *unselectedTitleAttributes;

/**
 * The title attributes dictionary used for tab bar item's selected state.
 */
@property (nonatomic,copy) NSDictionary *selectedTitleAttributes;

#pragma mark - Image configuration

/**
 * The offset for the rectangle around the tab bar item's image.
 */
@property (nonatomic) UIOffset imagePositionAdjustment;

/**
 * The image used for tab bar item's selected state.
 */
- (UIImage *)finishedSelectedImage;

/**
 * The image used for tab bar item's unselected state.
 */
- (UIImage *)finishedUnselectedImage;

/**
 * Sets the tab bar item's selected and unselected images.
 */
- (void)setFinishedSelectedImage:(UIImage *)selectedImage withFinishedUnselectedImage:(UIImage *)unselectedImage;

#pragma mark - Background configuration

/**
 * The background image used for tab bar item's selected state.
 */
- (UIImage *)backgroundSelectedImage;

/**
 * The background image used for tab bar item's unselected state.
 */
- (UIImage *)backgroundUnselectedImage;

/**
 * Sets the tab bar item's selected and unselected background images.
 */
- (void)setBackgroundSelectedImage:(UIImage *)selectedImage withUnselectedImage:(UIImage *)unselectedImage;

#pragma mark - Badge configuration

/**
 * Text that is displayed in the upper-right corner of the item with a surrounding background.
 */
@property (nonatomic, copy) NSString *badgeValue;

/**
 * Image used for background of badge.
 */
@property (nonatomic,retain) UIImage *badgeBackgroundImage;

/**
 * Color used for badge's background.
 */
@property (nonatomic,retain) UIColor *badgeBackgroundColor;

/**
 * Color used for badge's text.
 */
@property (nonatomic,assign) UIColor *badgeTextColor;

/**
 * The offset for the rectangle around the tab bar item's badge.
 */
@property (nonatomic) UIOffset badgePositionAdjustment;

/**
 * Font used for badge's text.
 */
@property (nonatomic,assign) UIFont *badgeTextFont;

@end
