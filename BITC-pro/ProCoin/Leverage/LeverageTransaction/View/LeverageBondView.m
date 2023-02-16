//
//  LeverageBondView.m
//  BYY
//
//  Created by Hay on 2019/12/24.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "LeverageBondView.h"
@interface LeverageBondView()

@property (nonatomic, copy) NSArray *bondData;                      //保证金数组
@property (nonatomic, retain) UIButton *preSelectedButton;          //上一次选择的按钮
@end


@implementation LeverageBondView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialLeverageBondView];
}

- (void)initialLeverageBondView
{
    self.preSelectedButton = nil;
    
}

- (void)dealloc
{
    [_bondData release];
    [_preSelectedButton release];
    [super dealloc];
}

#pragma mark - 更新数据
- (void)reloadLeverageBondData:(NSArray *)bondData
{
    self.bondData = bondData;
    for(int i = 0; i < bondData.count; i ++){
        UIButton *button = (UIButton *)[self viewWithTag:i + 100];
        if(i == 0){
            button.selected = YES;
            self.preSelectedButton = button;
        }else{
            button.selected = NO;
            
        }
        [self buttonPatternWithSelected:button.isSelected button:button];
        
        NSString *title = [self.bondData objectAtIndex:i];
        [button setTitle:title forState:UIControlStateNormal];
    }
    
}


#pragma mark - 按钮点击事件
- (IBAction)optionsButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton.selected)
        return;
    
    if(self.preSelectedButton != nil){
        self.preSelectedButton.selected = NO;
        [self buttonPatternWithSelected:_preSelectedButton.isSelected button:_preSelectedButton];
    }
    
    targetButton.selected = YES;
    self.preSelectedButton = targetButton;
    [self buttonPatternWithSelected:targetButton.isSelected button:targetButton];
    
    if([_delegate respondsToSelector:@selector(leverageBondBalanceDidChanged:)]){
        if(_preSelectedButton == nil || _bondData.count == 0 || _preSelectedButton.tag - 100 >= _bondData.count){
            [_delegate leverageBondBalanceDidChanged:@""];
        }else{
            NSString *bondBalance = [self.bondData objectAtIndex:_preSelectedButton.tag - 100];
            [_delegate leverageBondBalanceDidChanged:bondBalance];
        }
        
    }
    
}


#pragma mark - 设置按钮状态
/**
 * @param selected 是否被选中
 */
- (void)buttonPatternWithSelected:(BOOL)selected button:(UIButton *)button
{
    if(selected){           //选中状态
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor clearColor].CGColor;
        [button setBackgroundColor:RGBA(97, 117, 174, 1.0)];
    }else{                  //未选中状态
        [button setTitleColor:RGBA(190, 190, 190, 1.0) forState:UIControlStateNormal];
        button.layer.borderColor = RGBA(190, 190, 190, 1.0).CGColor;
        [button setBackgroundColor:[UIColor clearColor]];
        
    }
}

@end
