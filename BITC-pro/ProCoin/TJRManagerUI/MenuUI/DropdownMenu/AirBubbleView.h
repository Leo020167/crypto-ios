//
//  AirBubbleView.h
//  taojinroad
//
//  Created by hh hh on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kHandleMargin       16
#define kHandleWidth        10
#define kHandleHeight       14

enum handleStyle
{
    leftSideTopAlign,
    leftSideMiddleAlign,
    leftSideBottomAlign,
    topSideLeftAlign,
    topSideMiddleAlign,
    topSideRightAlign,
    rightSideTopAlign,
    rightSideMiddleAlign,
    rightSideBottomAlign,
    bottomSideLeftAlign,
    bottomSideMiddleAlign,
    bottomSideRightAlign,
    noHandle
};

@interface AirBubbleView : UIView
{
    enum handleStyle airBubbleStyle;
    CGSize handleSize;
    UIImageView *handleImgView;
    UIImageView *roundRectImgView;
    CGRect roundRectImgVwRect;
}

@property (nonatomic, assign) CGSize handleSize;
@property (nonatomic, retain) UIImageView *handleImgView;
@property (nonatomic, retain) UIImageView *roundRectImgView;
@property (nonatomic, assign) enum handleStyle airBubbleStyle;

- (void)setHandleSize:(CGSize)size;
- (id)initWithFrame:(CGRect)frame style:(enum handleStyle)style;
- (void)rotateHandleImgView:(float)degree;
- (void)setCrlFrame:(CGRect)frame;
- (CGRect)getRoundRectImgVwRect;
@end
