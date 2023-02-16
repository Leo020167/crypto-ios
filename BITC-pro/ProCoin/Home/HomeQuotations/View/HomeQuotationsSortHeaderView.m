//
//  HomeQuotationsSortHeaderView.m
//  BYY
//
//  Created by Hay on 2019/10/22.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "HomeQuotationsSortHeaderView.h"
@interface HomeQuotationsSortHeaderView()
{
    NSInteger preSelectButtonTag;       //上一次点击的按钮tag. -1为默认初始化，表示未点击过任何排序按钮
    NSString *sortField;  //按钮类型
    SortButtonState buttonState;        //按钮状态
}
@end

@implementation HomeQuotationsSortHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initHomeQuotationsSortHeaderView];
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initHomeQuotationsSortHeaderView];
}

- (void)initHomeQuotationsSortHeaderView
{
    preSelectButtonTag = -1;
}

/** 排序按钮点击事件*/
- (IBAction)sortButtonPressed:(id)sender
{
    MHSortButton *sortButton = sender;
    [sortButton nextButtonState];           //下一个状态
    
    if(preSelectButtonTag == -1){           //之前没任何操作
        preSelectButtonTag = sortButton.tag;
    }
    if(preSelectButtonTag > 0 && preSelectButtonTag != sortButton.tag){         //当之前操作过且不是与现在的同不是同一个按钮
        MHSortButton *preButton = (MHSortButton *)[self viewWithTag:preSelectButtonTag];
        [preButton resetNormalButtonState];             //重置上一个按钮的状态
        preSelectButtonTag = sortButton.tag;
    }
    
    switch (sortButton.tag) {
        case 100:               //名称
            sortField = HomeQuotationsSortFieldName;
            break;
        case 101:               //最新价
            sortField = HomeQuotationsSortFieldPrice;
            break;
        case 102:               //涨跌幅
            sortField = HomeQuotationsSortFieldRate;
            break;
        default:
            break;
    }
    buttonState = [sortButton currentButtonState];
    
    if([_delegate respondsToSelector:@selector(sortHeaderView:sortField:sortState:)]){
        [_delegate sortHeaderView:self sortField:sortField sortState:buttonState];
    }

}

- (SortButtonState)currentSortState
{
    return buttonState;
}

- (NSString *)currentSortField
{
    return sortField;
}

@end
