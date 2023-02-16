//
//  UIViewBackgroundColor+XibConfiguration.h
//  TJRtaojinroad
//
//  Created by taojinroad on 16/1/12.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface UIView(XibConfiguration)
@property(nonatomic, assign) UIColor *backgroundUIColor;
@end

@interface UIButton(XibConfiguration)
@property(nonatomic, assign) UIColor *normalImageColor;
@property(nonatomic, assign) UIColor *highlightedImageColor;
@property(nonatomic, assign) UIColor *selectedImageColor;
@end
