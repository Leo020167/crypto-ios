//
//  MHSortButton.m
//  Cropyme
//
//  Created by Hay on 2019/8/26.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "MHSortButton.h"

@implementation MHSortButton

/** 重置初始状态*/
- (void)resetNormalButtonState
{
    sortState = SortButtonState_Normal;
    [self setImage:[UIImage imageNamed:@"home_quotations_button_sort_normal"] forState:UIControlStateNormal];
}

/** 下一个状态*/
- (void)nextButtonState
{
    NSInteger currentIndex = (NSInteger)sortState;
    currentIndex++;
    if(currentIndex >= (NSInteger)SortButtonState_Error){
        currentIndex = (NSInteger)SortButtonState_Normal;
    }
    sortState = (SortButtonState)currentIndex;
    
    
    switch (sortState) {
        case SortButtonState_Normal:
            [self setImage:[UIImage imageNamed:@"home_quotations_button_sort_normal"] forState:UIControlStateNormal];
            break;
        case SortButtonState_Ascend:
            [self setImage:[UIImage imageNamed:@"home_quotations_button_sort_up"] forState:UIControlStateNormal];
            break;
        case SortButtonState_Descend:
            [self setImage:[UIImage imageNamed:@"home_quotations_button_sort_down"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

/** 当前状态*/
- (SortButtonState)currentButtonState
{
    return sortState;
}

@end
