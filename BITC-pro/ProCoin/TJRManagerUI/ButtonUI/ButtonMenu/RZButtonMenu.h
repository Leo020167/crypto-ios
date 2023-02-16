//
//  RZButtonMenu.h
//  Tjrv
//
//  Created by Hay on 2019/3/14.
//  Copyright © 2019年 淘金路. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArrowheadMenu.h"// 箭头菜单

@interface RZButtonMenu : NSObject

/** 初始化*/
- (instancetype)initRZButtonMenu:(id)delegate showView:(UIView *)showView menuTitles:(NSArray<NSString *> *)menuTitles menuIcon:(NSArray<NSString *> *)menuIcon menuFont:(UIFont *)menuFont menuFontColor:(UIColor *)color menuBackgroundColor:(UIColor *)menuBackgroundColor menuSegmentingLineColor:(UIColor *)menuSegmentingLineColor menuPlacement:(MenuPlacements)position;

@end


