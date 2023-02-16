//
//  FDLabelView.h
//  FDLabelView
//
//  Created by magic on 8/8/13.
//  Copyright (c) 2013 Fourdesire. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FDAutoFitModeNone = 0,
    FDAutoFitModeContrainedFrame = 1,
    FDAutoFitModeAutoHeight = 2
} FDAutoFitMode;

typedef enum {
    FDLabelFitAlignmentTop = 0,
    FDLabelFitAlignmentCenter = 1,
    FDLabelFitAlignmentBottom = 2
} FDLabelFitAlignment;

typedef enum {
    FDTextAlignmentLeft = 0,
    FDTextAlignmentCenter = 1,
    FDTextAlignmentRight = 2,
    FDTextAlignmentJustify = 3,
    FDTextAlignmentFill = 4
} FDTextAlignment;

typedef enum {
    FDLineHeightScaleBaseLineTop = 0,
    FDLineHeightScaleBaseLineCenter = 1,
    FDLineHeightScaleBaseLineBottom = 2
} FDLineHeightScaleBaseLine;

@interface FDLabelView : UILabel {
    CGFloat _fixedLineHeight;
    CGFloat _lineHeightScale;
    CGRect _contentBounds;
    NSArray* _textLines;
    NSInteger _enumerateIndex;
}


// Methods for fast adjustment
-(void)alignParentHorizontalCenter:(CGFloat)offset;
-(void)alignParentLeft:(CGFloat)offset;
-(void)alignParentRight:(CGFloat)offset;
-(void)alignParentVerticalCenter:(CGFloat)offset;
-(void)alignParentTop:(CGFloat)offset;
-(void)alignParentBottom:(CGFloat)offset;
-(void)contrainedToFrame:(CGRect)frame;

@property(nonatomic, assign) BOOL showLog;
@property(nonatomic, assign) FDTextAlignment fdTextAlignment;
@property(nonatomic, assign) FDLineHeightScaleBaseLine fdLineScaleBaseLine;
@property(nonatomic, assign) FDLabelFitAlignment fdLabelFitAlignment;
@property(nonatomic, assign) FDAutoFitMode fdAutoFitMode;
@property(nonatomic, assign) CGFloat lineHeightScale;
@property(nonatomic, assign) CGFloat fixedLineHeight;
@property(nonatomic, assign) CGFloat actualTextHeight;
@property(nonatomic, assign) CGFloat visualTextHeight;
@property(nonatomic, assign) NSUInteger actualLineNumber;
@property(nonatomic, assign) NSUInteger visualLineNumber;
@property(nonatomic, assign) UIEdgeInsets contentInset;
@property(nonatomic, copy) UIFont* adjustedFont;

@end

