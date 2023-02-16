//
//  PCMultiNumSettingView.m
//  ProCoin
//
//  Created by Hay on 2020/2/28.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCMultiNumSettingView.h"
#import "TextFieldToolBar.h"
#import "CommonUtil.h"

@interface PCMultiNumSettingView ()<TextFieldToolBarDelegate>
{
    TextFieldToolBar *toolBar;
    BOOL isDimissView;      //页面是否要消失
}

@property (retain, nonatomic) IBOutlet UITextField *multiNumTF;
@property (retain, nonatomic) IBOutlet UIView *coreView;    //核心view
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *coreViewLayoutConstraintBottom;      //coreView底部约束

@end

@implementation PCMultiNumSettingView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isDimissView = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    toolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _multiNumTF.inputAccessoryView = toolBar;

}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [toolBar release];
    [_multiNumTF release];
    [_coreView release];
    [_coreViewLayoutConstraintBottom release];
    [super dealloc];
}

#pragma mark - 显示与消失
- (void)showMultiNumViewInController:(UIViewController *)controller
{
    [CommonUtil viewHeightForAutoLayout:_coreView height:_coreView.frame.size.height + IPHONEX_BOTTOM_HEIGHT];
    _coreViewLayoutConstraintBottom.constant = -self.coreView.frame.size.height;
    [self.view layoutIfNeeded];
    
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        _coreViewLayoutConstraintBottom.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)dismissMultiNumView
{
    if([_multiNumTF isFirstResponder]){
        isDimissView = YES;
        [_multiNumTF resignFirstResponder];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            _coreViewLayoutConstraintBottom.constant = -_coreView.frame.size.height;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    }
}

#pragma mark - 按钮点击事件
- (IBAction)confirmButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(multiNumSettingViewCommitData:multiNum:)]){
        [_delegate multiNumSettingViewCommitData:self multiNum:_multiNumTF.text];
    }
}

- (IBAction)backgroundViewTouchDown:(id)sender
{
    [self dismissMultiNumView];
}

#pragma mark - 键盘弹出缩下
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _coreViewLayoutConstraintBottom.constant = keyboardRect.size.height;
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
        _coreViewLayoutConstraintBottom.constant = 0.0;
    } completion:^(BOOL finished) {
        if(isDimissView){
            isDimissView = NO;
            [self dismissMultiNumView];
        }
    }];
    [self.view layoutIfNeeded];
}

#pragma mark - TFDonePressed delegate
- (void)TFDonePressed
{
    [_multiNumTF resignFirstResponder];
}

@end
