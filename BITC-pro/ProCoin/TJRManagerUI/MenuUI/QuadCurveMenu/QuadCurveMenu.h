//
//  QuadCurveMenu.h
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuadCurveMenuItem.h"

@protocol QuadCurveMenuDelegate;

@interface QuadCurveMenu : UIView <QuadCurveMenuItemDelegate> {
	NSArray *_menusArray;
	NSInteger _flag;
	NSTimer *_timer;
	QuadCurveMenuItem *_addButton;

	id <QuadCurveMenuDelegate> _delegate;
    CGPoint movePoint;
}
@property (nonatomic, copy) NSArray *menusArray;
@property (nonatomic, getter = isExpanding) BOOL expanding;
@property (nonatomic, assign) id<QuadCurveMenuDelegate> delegate;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *highlightedImage;
@property (nonatomic, retain) UIImage *contentImage;
@property (nonatomic, retain) UIImage *highlightedContentImage;

@property (nonatomic, assign) CGFloat nearRadius;
@property (nonatomic, assign) CGFloat endRadius;
@property (nonatomic, assign) CGFloat farRadius;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGFloat timeOffset;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGFloat menuWholeAngle;

- (instancetype)initWithStartPoint:(CGPoint)_startPoint startSize:(CGSize)startSize
                          itemSize:(CGSize)size startImage:(UIImage *)startImage
                      submenuItems:(NSArray *)submenuItems;
- (void)moveSpherMenuWithY:(CGFloat)y;
- (void)setItemImage:(UIImage *)image index:(int)index;
@end

@protocol QuadCurveMenuDelegate <NSObject>
- (void)quadCurveMenu:(QuadCurveMenu *)menu didSelectIndex:(NSInteger)idx;
@end