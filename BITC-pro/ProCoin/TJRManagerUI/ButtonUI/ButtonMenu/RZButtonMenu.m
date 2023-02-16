//
//  RZButtonMenu.m
//  Tjrv
//
//  Created by Hay on 2019/3/14.
//  Copyright © 2019年 淘金路. All rights reserved.
//

#import "RZButtonMenu.h"

@interface RZButtonMenu()
{
    
}

@end;
@implementation RZButtonMenu

/** 初始化*/
- (instancetype)initRZButtonMenu:(id)delegate showView:(UIView *)showView menuTitles:(NSArray<NSString *> *)menuTitles menuIcon:(NSArray<NSString *> *)menuIcon menuFont:(UIFont *)menuFont menuFontColor:(UIColor *)color menuBackgroundColor:(UIColor *)menuBackgroundColor menuSegmentingLineColor:(UIColor *)menuSegmentingLineColor menuPlacement:(MenuPlacements)position
{
    if(self = [super init]){

        ArrowheadMenu *VC = [[[ArrowheadMenu alloc] initCustomArrowheadMenuWithTitle:menuTitles icon:menuIcon menuUnitSize:CGSizeMake([UIScreen mainScreen].bounds.size.width/3, 38) menuFont:menuFont menuFontColor:color menuBackColor:menuBackgroundColor menuSegmentingLineColor:menuSegmentingLineColor distanceFromTriggerSwitch:0 menuArrowStyle:MenuArrowStyleTriangle menuPlacements:position showAnimationEffects:ShowAnimationDefault] autorelease];

        VC.delegate = delegate;
        [VC presentMenuView:showView];
    }
    return self;
    
}


@end
