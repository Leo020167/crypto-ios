//
//  PCNormalCloseView.m
//  ProCoin
//
//  Created by Hay on 2020/3/27.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCNormalCloseView.h"
#import "CommonUtil.h"
#import "TextFieldToolBar.h"

@interface PCNormalCloseView ()
{
    BOOL isDimissView;
    TextFieldToolBar *toolBar;
}

@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutConstraintBottom;
@property (retain, nonatomic) IBOutlet UITextField *amountTF;
@property (retain, nonatomic) IBOutlet UIControl *backgroundView;
@property (retain, nonatomic) IBOutlet UILabel *holdAmountLabel;
@end

@implementation PCNormalCloseView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    toolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _amountTF.inputAccessoryView = toolBar;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    isDimissView =  NO;
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [toolBar release];
    [_contentView release];
    [_contentViewLayoutConstraintBottom release];
    [_amountTF release];
    [_backgroundView release];
    [_holdAmountLabel release];
    [super dealloc];
}

#pragma mark - 显示与消失
- (void)showInController:(UIViewController *)controller holdAmount:(NSString *)holdAmount
{
    self.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [CommonUtil viewHeightForAutoLayout:_contentView height:(_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT)];
    _contentViewLayoutConstraintBottom.constant = -_contentView.frame.size.height;
    [self.view layoutIfNeeded];
    
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
    _holdAmountLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedStringForKey(@"持仓手数"), holdAmount];
    
    [UIView animateWithDuration:0.35 animations:^{
        _contentViewLayoutConstraintBottom.constant = 0.0;
        [self.view layoutIfNeeded];
    }];
}



- (void)dismissViewWithAnimation
{
    if([_amountTF isFirstResponder]){
        isDimissView = YES;
        [_amountTF resignFirstResponder];
        return;
    }
    [UIView animateWithDuration:0.35 animations:^{
        _contentViewLayoutConstraintBottom.constant = -_contentView.frame.size.height;
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

#pragma mark - 按钮事件
- (IBAction)backgroundViewTouchDown:(id)sender
{
    [self dismissViewWithAnimation];
    _backgroundView.userInteractionEnabled = NO;
}

- (IBAction)commitButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(normalCloseViewDidCommit:handAmount:)]){
        [_delegate normalCloseViewDidCommit:self handAmount:_amountTF.text];
    }
}

#pragma mark - keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.35 animations:^{
        _contentViewLayoutConstraintBottom.constant = keyboardRect.size.height;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
        _contentViewLayoutConstraintBottom.constant = 0.0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if(isDimissView){
            [self dismissViewWithAnimation];
            isDimissView = NO;
        }
    }];
    
}

#pragma mark - TextFieldToolBar delegate
- (void)TFDonePressed
{
    [_amountTF resignFirstResponder];
}


@end
