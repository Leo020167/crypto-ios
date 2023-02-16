//
//  P2PPayMoneyView.m
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "P2PPayMoneyView.h"
#import "CommonUtil.h"
#import "TextFieldToolBar.h"

@interface P2PPayMoneyView()<TextFieldToolBarDelegate, UITextFieldDelegate> {

    TextFieldToolBar* toolBar;
}
@property (retain, nonatomic) IBOutlet UIView *contentView;         //内容view
@property (retain, nonatomic) IBOutlet UIView *touchView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutConstraintTop; //内容view约束
@property (retain, nonatomic) IBOutlet UIButton *btnConfirm;
@property (retain, nonatomic) IBOutlet UITextField *tfMoney;

/// 币种类型
//@property (retain, nonatomic) IBOutlet UILabel *coinTypeLabel;

@end

@implementation P2PPayMoneyView


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapEvent:)] autorelease];
    [_touchView addGestureRecognizer:recognizer];

    //添加toolbar
    toolBar = [[TextFieldToolBar alloc]initWithDelegate:self numOfTextField:1];
    _tfMoney.inputAccessoryView = toolBar;
    
//    self.coinTypeLabel.text = [NSString stringWithFormat: @"%@ ▽", NSLocalizedStringForKey(@"全部")];
//    self.coinTypeLabel.layer.cornerRadius = 2;
//    self.coinTypeLabel.backgroundColor = UIColorMakeWithHex(@"f2f5ff");
//    self.coinTypeLabel.userInteractionEnabled = YES;
//    [self.coinTypeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getCoinTypeAction:)]];
}


- (void)dealloc
{
    [toolBar release];
    [_btnConfirm release];
    [_contentView release];
    [_touchView release];
    [_contentViewLayoutConstraintTop release];
    [_tfMoney release];
//    [_coinTypeLabel release];
    [super dealloc];
}

//- (void)setCoinTypeArray:(NSMutableArray *)coinTypeArray{
//    _coinTypeArray = coinTypeArray;
//}
//
//- (void)getCoinTypeAction:(UITapGestureRecognizer *)tap{
//    if (self.coinTypeArray.count > 0) {
//        [self popShowAction];
//    }else{
//        [YYRequestUtility Post:@"/otc/mainad/config.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
//            if ([responseDict[@"code"] intValue] == 200) {
//                self.coinTypeArray = [NSMutableArray arrayWithArray:responseDict[@"data"][@"currencies"]];
//                [self popShowAction];
//            }else{
//                [QMUITips showError:responseDict[@"msg"]];
//            }
//        } failure:^(NSError *error) {
//        }];
//    }
//}

//- (void)popShowAction{
//    QMUIPopupMenuView *pop = [[QMUIPopupMenuView alloc] init];
//    pop.preferLayoutDirection = QMUIPopupContainerViewLayoutDirectionBelow;
//    pop.automaticallyHidesWhenUserTap = YES;
//    pop.maximumWidth = 100;
//    pop.shouldShowItemSeparator = YES;
//    pop.itemSeparatorColor = UIColorMakeWithHex(@"696969");
//    pop.itemTitleColor = UIColor.whiteColor;
//    pop.backgroundColor = UIColorMakeWithHex(@"4D4CE6");
//    pop.highlightedBackgroundColor = UIColor.clearColor;
//    NSMutableArray *items = [NSMutableArray array];
//    QMUIPopupMenuButtonItem *item = [QMUIPopupMenuButtonItem itemWithImage:nil title:NSLocalizedStringForKey(@"全部") handler:^(__kindof QMUIPopupMenuButtonItem * _Nonnull aItem) {
//        self.coinType = @"";
//        self.coinTypeLabel.text = [NSString stringWithFormat:@"%@ ▽", NSLocalizedStringForKey(@"全部")];
//        [pop hideWithAnimated:YES];
//    }];
//    [items addObject:item];
//    for (NSString *currencyItem in self.coinTypeArray) {
//        QMUIPopupMenuButtonItem *item = [QMUIPopupMenuButtonItem itemWithImage:nil title:currencyItem handler:^(__kindof QMUIPopupMenuButtonItem * _Nonnull aItem) {
//            self.coinType = currencyItem;
//            self.coinTypeLabel.text = [NSString stringWithFormat:@"%@ ▽", currencyItem];
//            [pop hideWithAnimated:YES];
//        }];
//        [items addObject:item];
//    }
//    pop.items = items;
//    pop.sourceView = self.coinTypeLabel;
//    [pop showWithAnimated:YES];
//}

#pragma mark - 按钮点击事件
- (void)backgroundTapEvent:(UIGestureRecognizer *)recognizer
{
    [self dismissView];
}

- (IBAction)resetBtnClicked:(id)sender {
//    self.coinType = @"";
//    self.coinTypeLabel.text = [NSString stringWithFormat: @"%@ ▽", NSLocalizedStringForKey(@"全部") ];
    //self.coinType = @"CNY";
    //self.coinTypeLabel.text = @"CNY ▽";
    
    for (int i = 100; i<105; i++) {
        UIButton* btn = (UIButton*)[self viewWithTag:i];
        btn.selected = NO;
        [CommonUtil viewMasksToBounds:btn cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    }
    _tfMoney.text = @"";
    if (_delegate && [_delegate respondsToSelector:@selector(p2pView:buttonClicked:filterCny:)]) {
        [_delegate p2pView:self buttonClicked:sender filterCny:@""];
    }
    [self close];
}

- (IBAction)confirmBtnClicked:(id)sender {
    for (int i = 100; i<105; i++) {
        UIButton* btn = (UIButton*)[self viewWithTag:i];
        btn.selected = NO;
        [CommonUtil viewMasksToBounds:btn cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(p2pView:buttonClicked:filterCny:)]) {
        [_delegate p2pView:self buttonClicked:sender filterCny:_tfMoney.text];
    }
    [self close];
}

- (IBAction)moneyBtnClicked:(id)sender {

    UIButton* button = (UIButton*)sender;
    
    for (int i = 100; i<106; i++) {
        UIButton* btn = (UIButton*)[self viewWithTag:i];
        btn.selected = NO;
        [CommonUtil viewMasksToBounds:btn cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    }
    button.selected = YES;
    [CommonUtil viewMasksToBounds:button cornerRadius:3 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
    
    if (_delegate && [_delegate respondsToSelector:@selector(p2pView:buttonClicked:filterCny:)]) {
        NSString *filterCny = [button.titleLabel.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        [_delegate p2pView:self buttonClicked:sender filterCny:filterCny];
    }
    [self close];
}


#pragma mark - 显示与消失
/** 显示动画*/
- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    _contentViewLayoutConstraintTop.constant = -_contentView.frame.size.height;
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintTop.constant = 0;
        [self layoutIfNeeded];
    }];
    self.displayed = YES;
    for (int i = 100; i<106; i++) {
        UIButton* btn = (UIButton*)[self viewWithTag:i];
        btn.selected = NO;
        [CommonUtil viewMasksToBounds:btn cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    }
}

/** 隐藏页面*/
- (void)dismissView
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintTop.constant = -_contentView.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (_delegate && [_delegate respondsToSelector:@selector(p2pView:dismissMoneyView:)]) {
            [_delegate p2pView:self dismissMoneyView:self];
        }
        [self removeFromSuperview];
    }];
    self.displayed = NO;
}

- (void)close
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintTop.constant = -_contentView.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    self.displayed = NO;
}

#pragma mark - Text Field Delegate

- (IBAction)textFieldChange:(UITextField *)textField {
    if (TTIsStringWithAnyText(_tfMoney.text)) {
        _btnConfirm.enabled = YES;
    }else{
        _btnConfirm.enabled = NO;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    switch (textField.tag) {
        case 1:
            [_tfMoney becomeFirstResponder];
            break;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSUInteger tag = [textField tag];
    [toolBar checkBarButton:tag];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [_tfMoney resignFirstResponder];
        return NO;
    }
    return YES;
}


#pragma mark - Text Field Tool Bar Delegate Methods
- (void)TFAnimateView:(NSUInteger)tag{
}
- (void)TFDonePressed{
    [_tfMoney resignFirstResponder];
}


@end
