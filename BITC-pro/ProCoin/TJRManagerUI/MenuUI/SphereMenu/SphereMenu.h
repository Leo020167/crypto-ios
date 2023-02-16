//
//  SphereMenu.h
//  SphereMenu
//
//  Created by Tu You on 14-8-24.
//  Copyright (c) 2014年 TU YOU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SphereMenuDelegate <NSObject>

- (void)sphereDidSelected:(int)index;

@end

@interface SphereMenu : UIView<UICollisionBehaviorDelegate> {
    NSUInteger count ;
    UIImageView *start;
    NSArray *images;
    NSMutableArray *items;
    NSMutableArray *positions;
    // animator and behaviors
    UIDynamicAnimator *animator;
    UICollisionBehavior *collision;
    UIDynamicItemBehavior *itemBehavior;
    NSMutableArray *snaps;
    UITapGestureRecognizer *tapOnStart;
    id<UIDynamicItem> bumper;
    BOOL expanded;
    CGSize itemSize;
    CGFloat sphereLength;
    CGPoint movePoint;
    CGPoint startPoint;
    BOOL isAutoMove;
}

@property (assign, nonatomic) id<SphereMenuDelegate> delegate;
@property (assign, nonatomic) BOOL startCanRotation;/* 展开时,开始按钮是否旋转45度(默认为NO) */
@property (assign, nonatomic, getter=isReduction) BOOL reduction;/* 拖动里面的item后,是否自动恢复到原来位置,默认YES */
@property (assign, nonatomic, getter=isEnabled) BOOL enabled;/* 默认YES */

- (instancetype)initWithStartPoint:(CGPoint)startPoint startImage:(UIImage *)startImage
                     submenuImages:(NSArray *)submenuImages;

- (instancetype)initWithStartPoint:(CGPoint)startPoint
                         startSize:(CGSize)startSize
                      sphereLength:(CGFloat)length
                          itemSize:(CGSize)size
                   startImage:(UIImage *)startImage
                submenuImages:(NSArray *)submenuImages;

- (NSArray *)sphereMenuItems;
- (void)shrink;
- (void)expandOrShrinkSubmenu:(BOOL)isExpand;
- (void)hideSphereMenu:(BOOL)isHide;

#pragma mark - 移动menu
- (void)moveSpherMenuWithY:(CGFloat)y;

- (void)setItemImage:(UIImage *)image index:(int)index;
@end
