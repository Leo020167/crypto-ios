//
//  PCFollowOrderRecordScreenView.m
//  ProCoin
//
//  Created by Hay on 2020/3/3.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCFollowOrderRecordScreenView.h"

@interface PCFollowOrderRecordScreenView ()<UITextFieldDelegate>

/** 变量*/
@property (copy, nonatomic) NSString *orderType;
@property (copy, nonatomic) NSString *accountType;


/**UI*/
@property (retain, nonatomic) IBOutlet UITextField *inputSymbolTF;
@property (retain, nonatomic) IBOutlet UIButton *orderCancelButton;     //已撤销按钮
@property (retain, nonatomic) IBOutlet UIButton *orderDoneButton;       //已成交按钮
@property (retain, nonatomic) IBOutlet UIView *coreView;        //核心view
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *coreViewLayoutConstraintTop;  //核心view顶部约束
@property (retain, nonatomic) IBOutlet UIButton *digitalTypeButton;     //数字货币按钮
@property (retain, nonatomic) IBOutlet UIButton *stockTypeButton;       //股指期货按钮

@end

@implementation PCFollowOrderRecordScreenView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _inputSymbolTF.delegate = self;
    _coreViewLayoutConstraintTop.constant = -_coreView.frame.size.height;
    [self.view layoutIfNeeded];
}

- (void)dealloc
{
    [_orderType release];
    [_accountType release];
    [_inputSymbolTF release];
    [_orderCancelButton release];
    [_orderDoneButton release];
    [_coreView release];
    [_coreViewLayoutConstraintTop release];
    [_digitalTypeButton release];
    [_stockTypeButton release];
    [super dealloc];
}


#pragma mark -  显示与消失
- (void)addSelfToParentViewController:(UIViewController *)controller inputSymbol:(NSString *)inputSymbol orderType:(NSString *)orderType accounType:(NSString *)accountType
{
    _inputSymbolTF.text = inputSymbol;
    self.orderType = orderType;
    self.accountType = accountType;
    
    [self reloadOrderTypeUI];
    [self reloadAccounTypeUI];
    
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

#pragma mark - 更新UI
- (void)reloadOrderTypeUI
{
    if([_orderType isEqualToString:PCTransactionHistoryOrderFilledState]){          //已成交
        _orderDoneButton.backgroundColor = RGBA(97, 117, 174, 1.0);
        [_orderDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _orderCancelButton.backgroundColor = RGBA(249, 250, 253, 1.0);
        [_orderCancelButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    }else if([_orderType isEqualToString:PCTransactionHistoryOrderCanceledState]){  //已撤销
        _orderDoneButton.backgroundColor = RGBA(249, 250, 253, 1.0);
        [_orderDoneButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        _orderCancelButton.backgroundColor = RGBA(97, 117, 174, 1.0);
        [_orderCancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        _orderDoneButton.backgroundColor = RGBA(249, 250, 253, 1.0);
        [_orderDoneButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        _orderCancelButton.backgroundColor = RGBA(249, 250, 253, 1.0);
        [_orderCancelButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    }
}

- (void)reloadAccounTypeUI
{
    if([_accountType isEqualToString:PCAccountFollowDigitalType]){          //跟单数字货币
        _digitalTypeButton.backgroundColor = RGBA(97, 117, 174, 1.0);
        [_digitalTypeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _stockTypeButton.backgroundColor = RGBA(249, 250, 253, 1.0);
        [_stockTypeButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    }else if([_accountType isEqualToString:PCAccountFollowStockType]){  //跟单股指期货
        _digitalTypeButton.backgroundColor = RGBA(249, 250, 253, 1.0);
        [_digitalTypeButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        _stockTypeButton.backgroundColor = RGBA(97, 117, 174, 1.0);
        [_stockTypeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        _digitalTypeButton.backgroundColor = RGBA(249, 250, 253, 1.0);
        [_digitalTypeButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        _stockTypeButton.backgroundColor = RGBA(249, 250, 253, 1.0);
        [_stockTypeButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    }
}

#pragma mark - 按钮点击事件
/** 订单状态按钮点击事件*/
- (IBAction)orderStateButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton == _orderDoneButton){
        if([self.orderType isEqualToString:PCTransactionHistoryOrderFilledState]){      //如果已经是成交了，再点击则取消
            self.orderType = @"";
        }else{
            self.orderType = PCTransactionHistoryOrderFilledState;
        }
    }else{
        if([self.orderType isEqualToString:PCTransactionHistoryOrderCanceledState]){        //如果已经是撤销，再点击则取消
            self.orderType = @"";
        }else{
            self.orderType = PCTransactionHistoryOrderCanceledState;
        }
    }
    //更新按钮
    [self reloadOrderTypeUI];
}

- (IBAction)accounTypeButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton == _digitalTypeButton){     //跟单数字货币
        if([self.accountType isEqualToString:PCAccountFollowDigitalType]){      //如果已经是数字货币，再点击则取消
            self.accountType = @"";
        }else{
            self.accountType = PCAccountFollowDigitalType;
        }
    }else{
        if([self.accountType isEqualToString:PCAccountFollowStockType]){        //如果已经是股指期货，再点击则取消
            self.accountType = @"";
        }else{
            self.accountType = PCAccountFollowStockType;
        }
    }
    //更新按钮
    [self reloadAccounTypeUI];
}

/** 取消页面*/
- (IBAction)dimissViewButtonPressed:(id)sender
{
    [self dismissViewController];
}

/** 提交数据*/
- (IBAction)commitDataButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(followOrderRecordScreenCommitDataWithSymbol:orderType:accountType:)]){
        NSString *symbol = @"";
        if(checkIsStringWithAnyText(_inputSymbolTF.text)){
            symbol = _inputSymbolTF.text;
        }
        [_delegate followOrderRecordScreenCommitDataWithSymbol:symbol orderType:self.orderType accountType:self.accountType];
    }
    [self dismissViewController];
}

/** 重置数据*/
- (IBAction)resetSettingButtonPressed:(id)sender
{
    _inputSymbolTF.text = @"";
    self.orderType = @"";
    self.accountType = @"";
    
    [self reloadOrderTypeUI];
    [self reloadAccounTypeUI];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_inputSymbolTF resignFirstResponder];
    return YES;
}




@end
