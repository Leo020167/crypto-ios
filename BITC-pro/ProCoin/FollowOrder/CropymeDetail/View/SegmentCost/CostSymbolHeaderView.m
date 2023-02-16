//
//  CostSymbolHeaderView.m
//  Cropyme
//
//  Created by Hay on 2019/8/12.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CostSymbolHeaderView.h"
#import "CommonUtil.h"

@interface CostSymbolHeaderView()
{
    NSInteger preSelectedTag;               //上次选择按钮的索引
    NSInteger rowCount;                     //一行有多少个按钮
    CGFloat topMargin;                      //顶部间距
    CGFloat leftMargin;                     //左边间距
    CGFloat itemSpacing;                    //按钮间的间距
    CGFloat buttonHeight;                   //按钮高度
    CGFloat buttonWidth;                    //按钮宽度
}

@property (copy, nonatomic) NSArray *symbolArr;


@end

@implementation CostSymbolHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    _isHasOptionsButton = NO;
    rowCount = 4;
    topMargin = 16;
    leftMargin = 15;
    buttonHeight = 36;
    itemSpacing = 10;
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, self.frame.size.height);
    buttonWidth = (SCREEN_WIDTH - 2 * leftMargin - (rowCount - 1) * itemSpacing) / rowCount;
}

//- (CGFloat)symbolHeaderViewCurrentHeight
//{
//    return self.frame.size.height;
//    CGFloat currentHeight = 0;
//    NSInteger totalRow = 0;
//    if([_symbolArr count] > 0){
//        totalRow = [_symbolArr count] % rowCount + 1;
//        currentHeight = (totalRow + 1) * topMargin + totalRow * buttonHeight;
//    }
//
//
//    return currentHeight;
//}


- (void)dealloc
{
    [_symbolArr release];
    [super dealloc];
}


- (void)reloadSymbolHeaderViewWithSymbolArr:(NSArray *)symbolArr
{
    if([symbolArr count] == 0){
        return;
    }
    _isHasOptionsButton = YES;
    self.symbolArr = symbolArr;
    CGFloat currentHeight = 0;
    NSInteger totalRow = 0;
    if([_symbolArr count] > 0){
        totalRow = ([_symbolArr count] - 1) / rowCount + 1;
        currentHeight = topMargin * 2 + (totalRow - 1) * itemSpacing + totalRow * buttonHeight;
    }
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, currentHeight);
    
    /** 创造按钮*/
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for(int i = 0; i <  [symbolArr count] ; i++){
        NSString *title = [symbolArr objectAtIndex:i];
        UIButton *symbolButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSInteger row = i / rowCount;
        NSInteger col = i % rowCount;
        CGFloat x = leftMargin + col * (itemSpacing + buttonWidth);
        CGFloat y = topMargin + row * (itemSpacing + buttonHeight);
        [symbolButton setFrame:CGRectMake(x, y, buttonWidth, buttonHeight)];
        [symbolButton setTitle:title forState:UIControlStateNormal];
        [symbolButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(240, 240, 241, 1.0)] forState:UIControlStateNormal];
        [symbolButton setTitleColor:RGBA(61, 58, 80, 0.4) forState:UIControlStateNormal];
        [symbolButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(255, 143, 1, 1.0)] forState:UIControlStateSelected];
        [symbolButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        symbolButton.layer.masksToBounds = YES;
        symbolButton.layer.cornerRadius = 5;
        [symbolButton  addTarget:self action:@selector(symbolButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        symbolButton.tag = 300 + i;
        if(i == 0){
            symbolButton.selected = YES;
            preSelectedTag = symbolButton.tag;
        }else{
            symbolButton.selected = NO;
        }
        [self addSubview:symbolButton];
    }
}

- (void)symbolButtonPressed:(UIButton *)sender
{
    if(sender.tag == preSelectedTag){
        return;
    }
    sender.selected = YES;
    UIButton *preButton = (UIButton *)[self viewWithTag:preSelectedTag];
    preButton.selected = NO;
    preSelectedTag = sender.tag;
    NSInteger index  = sender.tag - 300;
    if([_delegate respondsToSelector:@selector(headerViewDidPressedSymbolButtonWithIndex:)]){
        [_delegate headerViewDidPressedSymbolButtonWithIndex:index];  
    }
}


@end
