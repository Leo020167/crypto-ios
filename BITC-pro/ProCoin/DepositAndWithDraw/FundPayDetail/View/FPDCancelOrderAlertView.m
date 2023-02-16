//
//  FPDCancelOrderAlertView.m
//  Cropyme
//
//  Created by Hay on 2019/7/27.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "FPDCancelOrderAlertView.h"
#import "CommonUtil.h"

@interface FPDCancelOrderAlertView()

@property (retain, nonatomic) IBOutlet UIButton *certainButton;

@end

@implementation FPDCancelOrderAlertView

- (void)dealloc
{
    [_certainButton release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)cancelButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(cancelOrderAlertViewDidCancel)]){
        [_delegate cancelOrderAlertViewDidCancel];
    }
}

- (IBAction)certainButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(cancelOrderAlertViewDidCertain)]){
        [_delegate cancelOrderAlertViewDidCertain];
    }
}

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
