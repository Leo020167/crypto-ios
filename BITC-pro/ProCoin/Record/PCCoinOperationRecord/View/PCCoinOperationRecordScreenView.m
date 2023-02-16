//
//  PCCoinOperationRecordScreenView.m
//  ProCoin
//
//  Created by Hay on 2020/3/10.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCCoinOperationRecordScreenView.h"


@interface PCCoinOperationRecordScreenView ()

/** 变量*/
@property (copy, nonatomic) NSString *inOut;

/** UI*/
@property (retain, nonatomic) IBOutlet UIView *coreView;
@property (retain, nonatomic) IBOutlet UIButton *chargeButton;      //充币按钮
@property (retain, nonatomic) IBOutlet UIButton *extractButton;     //提币按钮
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *coreViewLayoutConstraintTop;
@end

@implementation PCCoinOperationRecordScreenView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _coreViewLayoutConstraintTop.constant = -_coreView.frame.size.height;
    [self.view layoutIfNeeded];
}


- (void)dealloc
{
    [_coreView release];
    [_chargeButton release];
    [_extractButton release];
    [_coreViewLayoutConstraintTop release];
    [super dealloc];
}

#pragma mark - 按钮点击事件

- (IBAction)optionsButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton == _chargeButton){          //充币按钮
        if(checkIsStringWithAnyText(self.inOut)){
            if([self.inOut integerValue] == PCCoinOperationTypeIn){
                self.inOut = @"";
                _chargeButton.backgroundColor = RGBA(249, 250, 253, 1.0);
                [_chargeButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
            }else{
                self.inOut = [NSString stringWithFormat:@"%@",@(PCCoinOperationTypeIn)];
                _chargeButton.backgroundColor = RGBA(97, 117, 174, 1.0);
                [_chargeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }else{
            self.inOut = [NSString stringWithFormat:@"%@",@(PCCoinOperationTypeIn)];
            _chargeButton.backgroundColor = RGBA(97, 117, 174, 1.0);
            [_chargeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }else{          //提币按钮
        if(checkIsStringWithAnyText(self.inOut)){
            if([self.inOut integerValue] == PCCoinOperationTypeOut){
                self.inOut = @"";
                _extractButton.backgroundColor = RGBA(249, 250, 253, 1.0);
                [_extractButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
            }else{
                self.inOut = [NSString stringWithFormat:@"%@",@(PCCoinOperationTypeOut)];
                _extractButton.backgroundColor = RGBA(97, 117, 174, 1.0);
                [_extractButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }else{
            self.inOut = [NSString stringWithFormat:@"%@",@(PCCoinOperationTypeOut)];
            _extractButton.backgroundColor = RGBA(97, 117, 174, 1.0);
            [_extractButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    [self reloadButtonUI];
}

- (IBAction)resetButtonPressed:(id)sender
{
    self.inOut = @"";
    [self reloadButtonUI];
}

- (IBAction)commitButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(coinOperationRecordScreenDidSelectedWithInOut:)]){
        [_delegate coinOperationRecordScreenDidSelectedWithInOut:self.inOut];
    }
    [self dismissViewController];
}

- (IBAction)closeButtonPressed:(id)sender
{
    [self dismissViewController];
}

#pragma mark -  显示与消失
- (void)addSelfToParentViewController:(UIViewController *)controller inOut:(NSString *)inOut
{
    self.inOut = inOut;
    [self reloadButtonUI];
    
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        _coreViewLayoutConstraintTop.constant = 0;
        [self.view layoutIfNeeded];
    }];
    
}

- (void)dismissViewController
{
    [UIView animateWithDuration:0.3 animations:^{
        _coreViewLayoutConstraintTop.constant = -_coreView.frame.size.height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

#pragma mark - 更新按钮UI
- (void)reloadButtonUI
{
    if(checkIsStringWithAnyText(self.inOut)){
        if([self.inOut integerValue] == PCCoinOperationTypeOut){        //提币
            _chargeButton.backgroundColor = RGBA(249, 250, 253, 1.0);
            [_chargeButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
            _extractButton.backgroundColor = RGBA(97, 117, 174, 1.0);
            [_extractButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{   //充币
            _chargeButton.backgroundColor = RGBA(97, 117, 174, 1.0);
            [_chargeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _extractButton.backgroundColor = RGBA(249, 250, 253, 1.0);
            [_extractButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        }
    }else{
        _chargeButton.backgroundColor = RGBA(249, 250, 253, 1.0);
        [_chargeButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        _extractButton.backgroundColor = RGBA(249, 250, 253, 1.0);
        [_extractButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    }
    
}

@end
