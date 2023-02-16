//
//  FPDMarkPaidAlertView.m
//  Cropyme
//
//  Created by Hay on 2019/7/27.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "FPDMarkPaidAlertView.h"

@interface FPDMarkPaidAlertView()
@property (retain, nonatomic) IBOutlet UIButton *certainButton;             //确定按钮

@end

@implementation FPDMarkPaidAlertView


- (void)dealloc
{

    [_certainButton release];
    [super dealloc];
}
#pragma mark - 按钮点击事件
/** 取消按钮点击事件*/
- (IBAction)cancelButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(markPaidAlertViewDidCancel)]){
        [_delegate markPaidAlertViewDidCancel];
    }
}
/** 确定按钮点击事件*/
- (IBAction)certainButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(markPaidAlertViewDidCertain)]){
        [_delegate markPaidAlertViewDidCertain];
    }
}

/** 同意细则按钮点击事件*/
- (IBAction)optionButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    targetButton.selected = !targetButton.isSelected;
    if(targetButton.isSelected){
        [_certainButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        _certainButton.enabled = YES;
    }else{
        [_certainButton setTitleColor:RGBA(61, 58, 80, 0.2) forState:UIControlStateNormal];
        _certainButton.enabled = NO;
    }
    
}

@end
