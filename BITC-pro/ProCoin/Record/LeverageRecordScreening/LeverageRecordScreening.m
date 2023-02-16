//
//  LeverageRecordScreening.m
//  BYY
//
//  Created by Hay on 2019/12/28.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "LeverageRecordScreening.h"

@interface LeverageRecordScreening ()<UITextFieldDelegate>
{
    LeverageRecordScreeningType buttonType;
}

@property (retain, nonatomic) IBOutlet UITextField *symbolTF;
@property (retain, nonatomic) IBOutlet UIView *coreView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *coreViewLayoutConstraintTop;
@property (retain, nonatomic) IBOutlet UIButton *buyStateButton;
@property (retain, nonatomic) IBOutlet UIButton *sellStateButton;

@end

@implementation LeverageRecordScreening

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _symbolTF.delegate = self;
    buttonType = LeverageRecordScreeningTypeNothing;
    _coreViewLayoutConstraintTop.constant = -_coreView.frame.size.height;
    [self.view layoutIfNeeded];
}

- (void)dealloc
{
    [_coreView release];
    [_coreViewLayoutConstraintTop release];
    [_symbolTF release];
    [_buyStateButton release];
    [_sellStateButton release];
    [super dealloc];
}

- (void)addSelfToParentViewController:(UIViewController *)controller viewType:(LeverageRecordScreeningType)type inputSymbol:(NSString *)inputSymbol;
{
    buttonType = type;
    _symbolTF.text = inputSymbol;
    
    if(buttonType == LeverageRecordScreeningTypeBuy){
        _buyStateButton.backgroundColor = RGBA(255, 143, 1, 1.0);
        [_buyStateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else if(buttonType == LeverageRecordScreeningTypeSell){
        _sellStateButton.backgroundColor = RGBA(255, 143, 1, 1.0);
        [_sellStateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
    
    [UIView animateWithDuration:0.5 animations:^{
        _coreViewLayoutConstraintTop.constant = 0;
        [self.view layoutIfNeeded];
    }];
    
}

- (void)dismissViewController
{
    [UIView animateWithDuration:0.5 animations:^{
        _coreViewLayoutConstraintTop.constant = -_coreView.frame.size.height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
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
    buttonType = LeverageRecordScreeningTypeNothing;
    
    _buyStateButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    [_buyStateButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    _sellStateButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    [_sellStateButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
}

- (IBAction)submitButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(recordScreeningDidSubmitWithType:screeningSymbol:)]){
        NSString *symbol = @"";
        if(checkIsStringWithAnyText(_symbolTF.text)){
            symbol = _symbolTF.text;
        }
        [_delegate recordScreeningDidSubmitWithType:buttonType screeningSymbol:symbol];
    }
    [self dismissViewController];
}

- (IBAction)buyStateButtonPressed:(id)sender
{
    buttonType = LeverageRecordScreeningTypeBuy;
    _buyStateButton.backgroundColor = RGBA(255, 143, 1, 1.0);
    [_buyStateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _sellStateButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    [_sellStateButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
}

- (IBAction)sellStateButtonPressed:(id)sender
{
    buttonType = LeverageRecordScreeningTypeSell;
    _buyStateButton.backgroundColor = RGBA(249, 250, 253, 1.0);
    [_buyStateButton setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
    _sellStateButton.backgroundColor = RGBA(255, 143, 1, 1.0);
    [_sellStateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_symbolTF resignFirstResponder];
    return YES;
}

@end
