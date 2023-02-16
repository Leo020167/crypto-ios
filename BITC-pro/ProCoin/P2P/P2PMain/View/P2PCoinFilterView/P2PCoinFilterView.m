//
//  P2PCoinFilterView.m
//  ProCoin
//
//  Created by Luo Chun on 2023/2/13.
//  Copyright © 2023 Toka. All rights reserved.
//

#import "P2PCoinFilterView.h"

#import "CommonUtil.h"

@interface P2PCoinFilterView(){

}
@property (retain, nonatomic) IBOutlet UIView *contentView;         //内容view
@property (retain, nonatomic) IBOutlet UIView *touchView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutConstraintHeight; //内容view约束

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutConstraintTop; //内容view约束
@property (retain, nonatomic) NSMutableArray<UIButton *> *btns;
@end

@implementation P2PCoinFilterView


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapEvent:)] autorelease];
    [_touchView addGestureRecognizer:recognizer];

    //[CommonUtil viewMasksToBounds:_btnAll cornerRadius:3 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
}


- (void)dealloc
{
    [_contentView release];
    [_touchView release];
    [_contentViewLayoutConstraintTop release];
    [_btns release];
    
    [super dealloc];
}

- (void)setCoinTypeArray:(NSMutableArray *)coinTypeArray {
    _coinTypeArray = coinTypeArray;
    [_contentView qmui_removeAllSubviews];
    if (!_btns) {
        _btns = [[NSMutableArray alloc] init];
    }
    [_btns removeAllObjects];
    
    CGFloat width = (SCREEN_WIDTH - 80) / 3;
    CGFloat height = 30;
    CGFloat top = 15;
    NSMutableArray *allCoin = [[NSMutableArray alloc] initWithArray:coinTypeArray];
    [allCoin insertObject:NSLocalizedStringForKey(@"全部") atIndex:0];
    
    
    for(int i = 0; i < allCoin.count; i++){
        NSString *string = [NSString stringWithFormat:@"%@", allCoin[i]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(20 + (20 + width) * (i % 3) , top + (top + 30) * (i / 3), width, height)];
        [button setTitle:string forState:UIControlStateNormal];
        [button setTitleColor: [UIColor darkGrayColor] forState: UIControlStateNormal];
        [button setTitleColor:UIColorMakeWithHex(@"#6175AE") forState: UIControlStateSelected];
        [button setBackgroundImage:[UIImage qmui_imageWithColor:UIColorMakeWithHex(@"#F4F4F4")] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage qmui_imageWithColor:UIColorMakeWithHex(@"#F4F4F4")] forState:UIControlStateSelected];
        [CommonUtil viewMasksToBounds:button cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
        button.titleLabel.font = UIFontMake(15);
        if ([self.coinType isEqualToString: string]) {
            [CommonUtil viewMasksToBounds:button cornerRadius:3 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
            button.selected = YES;
        }
        [_btns addObject:button];
        [_contentView addSubview:button];
    }
    _contentViewLayoutConstraintHeight.constant = top + (top + 30) * (allCoin.count / 3) + 40;
    if (!self.coinType) {
        [CommonUtil viewMasksToBounds:_btns.firstObject cornerRadius:3 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
        _btns.firstObject.selected = YES;
    }
}

#pragma mark - 按钮点击事件
- (void)backgroundTapEvent:(UIGestureRecognizer *)recognizer
{
    [self dismissView];
}
- (IBAction)buttonClicked:(UIButton *)sender {
    [_btns enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = NO;
        [CommonUtil viewMasksToBounds:obj cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    }];
    sender.selected = YES;
    [CommonUtil viewMasksToBounds:sender cornerRadius:3 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
    //_btnAll.selected = ! _btnAll.selected;
    //_btnBank.selected = _btnAlipay.selected = _btnWechatPay.selected = ! _btnAll.selected;
    
//    [CommonUtil viewMasksToBounds:_btnAll cornerRadius:3 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
//    [CommonUtil viewMasksToBounds:_btnBank cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
//    [CommonUtil viewMasksToBounds:_btnAlipay cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
//    [CommonUtil viewMasksToBounds:_btnWechatPay cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    
    
    NSString *title = [sender titleForState: UIControlStateNormal];
    self.coinType = [title isEqualToString:NSLocalizedStringForKey(@"全部")] ? @"": title;
    if (_delegate && [_delegate respondsToSelector:@selector(p2pSymbolView:selected:)]) {
        [_delegate p2pSymbolView:self selected: _coinType];
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
    /// 再次检测
    if (self.coinTypeArray.count <= 0) {
        [YYRequestUtility Post:@"/otc/mainad/config.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
            if ([responseDict[@"code"] intValue] == 200) {
                self.coinTypeArray = [NSMutableArray arrayWithArray:responseDict[@"data"][@"currencies"]];
            }else{
                [QMUITips showError:responseDict[@"msg"]];
            }
        } failure:^(NSError *error) {
        }];
    }
}

/** 隐藏页面*/
- (void)dismissView
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintTop.constant = -_contentView.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (_delegate && [_delegate respondsToSelector:@selector(p2pSymbolView:dismissView:)]) {
            [_delegate p2pSymbolView:self dismissView:self];
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


@end
