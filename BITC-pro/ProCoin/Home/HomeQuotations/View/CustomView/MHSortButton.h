//
//  MHSortButton.h
//  Cropyme
//
//  Created by Hay on 2019/8/26.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SortButtonState_Normal = 0,
    SortButtonState_Descend,             //降序
    SortButtonState_Ascend,              //顺序
    SortButtonState_Error,               //错误边界
}SortButtonState;


NS_ASSUME_NONNULL_BEGIN

@interface MHSortButton : UIButton
{
    SortButtonState sortState;
}

/** 重置初始状态*/
- (void)resetNormalButtonState;

/** 下一个状态*/
- (void)nextButtonState;

/** 当前状态*/
- (SortButtonState)currentButtonState;


@end

NS_ASSUME_NONNULL_END
