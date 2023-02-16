//
//  RecordScreeningController.m
//  Cropyme
//
//  Created by Hay on 2019/9/4.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "RecordScreeningController.h"

@interface RecordScreeningController ()<UITextFieldDelegate>
{
    RecordScreeningType screeningType;
    RecordScreeningButtonType buttonType;
}

@property (retain, nonatomic) IBOutlet UITextField *symbolTF;
@property (retain, nonatomic) IBOutlet UIView *buySellOperationView;    //买卖操作view
@property (retain, nonatomic) IBOutlet UIView *orderStateView;  //状态view
@property (retain, nonatomic) IBOutlet UIButton *buyStateButton;
@property (retain, nonatomic) IBOutlet UIButton *sellStateButton;
@property (retain, nonatomic) IBOutlet UIButton *allDoneButton;
@property (retain, nonatomic) IBOutlet UIButton *partDoneButton;
@property (retain, nonatomic) IBOutlet UIButton *orderCancelButton;

@property (retain, nonatomic) IBOutlet UIView *coreView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *coreViewLayoutConstraintTop;

@end

@implementation RecordScreeningController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _symbolTF.delegate = self;
    buttonType = RecordScreeningButtonType_WithoutChoose;        //默认值
    _coreViewLayoutConstraintTop.constant = -_coreView.frame.size.height;
    [self.view layoutIfNeeded];
    
}

- (void)addSelfToParentViewController:(UIViewController *)controller viewType:(RecordScreeningType)type inputSymbol:(NSString *)inputSymbol buttonType:(RecordScreeningButtonType)buttonType
{
    screeningType = type;
    _symbolTF.text = inputSymbol;
    if(screeningType == RecordScreeningBuySellStateType){
        _buySellOperationView.hidden = NO;
        _orderStateView.hidden = YES;
    }else{
        _buySellOperationView.hidden = YES;
        _orderStateView.hidden = NO;
    }
    
    if(buttonType == RecordScreeningButtonType_Buy){
        _buyStateButton.backgroundColor = RGBA(255, 143, 1, 1.0);
        [_buyStateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else if(buttonType == RecordScreeningButtonType_Sell){
        _sellStateButton.backgroundColor = RGBA(255, 143, 1, 1.0);
        [_sellStateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else if(buttonType == RecordScreeningButtonType_AllDone){
        _allDoneButton.backgroundColor = RGBA(255, 143, 1, 1.0);
        [_allDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else if(buttonType == RecordScreeningButtonType_PartDone){
        _partDoneButton.backgroundColor = RGBA(255, 143, 1, 1.0);
        [_partDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else if(buttonType == RecordScreeningButtonType_Cancel){
        _orderCancelButton.backgroundColor = RGBA(255, 143, 1, 1.0);
        [_orderCancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    
    
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

- (void)dealloc
{
    [_buySellOperationView release];
    [_orderStateView release];
    [_symbolTF release];
    [_buyStateButton release];
    [_sellStateButton release];
    [_allDoneButton release];
    [_partDoneButton release];
    [_orderCancelButton release];
    [_coreViewLayoutConstraintTop release];
    [_coreView release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)cancelButtonPresssed:(id)sender
{
    [self dismissViewController];
}

/** 重置按钮*/
- (IBAction)resetButtonPressed:(id)sender
{
    _symbolTF.text = @"";
    buttonType = RecordScreeningButtonType_WithoutChoose;
    
    _buyStateButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    [_buyStateButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    _sellStateButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    [_sellStateButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    _allDoneButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    [_allDoneButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    _partDoneButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    [_partDoneButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    _orderCancelButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    [_orderCancelButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
  
}

- (IBAction)submitButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(recordScreeningDidSubmitWithType:screeningSymbol:buttonType:)]){
        NSString *symbol = @"";
        if(checkIsStringWithAnyText(_symbolTF.text)){
            symbol = _symbolTF.text;
        }
        [_delegate recordScreeningDidSubmitWithType:screeningType screeningSymbol:symbol buttonType:buttonType];
    }
    [self dismissViewController];
}

- (IBAction)buyStateButtonPressed:(id)sender
{
    buttonType = RecordScreeningButtonType_Buy;
    _buyStateButton.backgroundColor = RGBA(255, 143, 1, 1.0);
    [_buyStateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _sellStateButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    [_sellStateButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
}

- (IBAction)sellStateButtonPressed:(id)sender
{
    buttonType = RecordScreeningButtonType_Sell;
    _buyStateButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    [_buyStateButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    _sellStateButton.backgroundColor = RGBA(255, 143, 1, 1.0);
    [_sellStateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)allDoneButtonPressed:(id)sender
{
    buttonType = RecordScreeningButtonType_AllDone;
    _allDoneButton.backgroundColor = RGBA(255, 143, 1, 1.0);
    _partDoneButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    _orderCancelButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    [_allDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_partDoneButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    [_orderCancelButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
}
- (IBAction)partDoneButtonPressed:(id)sender
{
    buttonType = RecordScreeningButtonType_PartDone;
    _allDoneButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    _partDoneButton.backgroundColor = RGBA(255, 143, 1, 1.0);
    _orderCancelButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    [_allDoneButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    [_partDoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_orderCancelButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
}

- (IBAction)orderCancelButtonPressed:(id)sender
{
    buttonType = RecordScreeningButtonType_Cancel;
    _allDoneButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    _partDoneButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    _orderCancelButton.backgroundColor = RGBA(255, 143, 1, 1.0);
    [_allDoneButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    [_partDoneButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    [_orderCancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_symbolTF resignFirstResponder];
    return YES;
}


#pragma mark -

@end
