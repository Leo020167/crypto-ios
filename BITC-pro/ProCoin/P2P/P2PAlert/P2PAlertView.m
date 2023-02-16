//
//  P2PAlertView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 3/29/16.
//  Copyright © 2016 淘金路. All rights reserved.
//

#import "P2PAlertView.h"
#import "LewPopupViewAnimationSpring.h"
#import "TJRBaseViewController.h"

@interface P2PAlertView () <UIGestureRecognizerDelegate> {
    TJRBaseViewController* ctr;
}

@property (retain, nonatomic) IBOutlet UIView *bgView;
@property (retain, nonatomic) IBOutlet UIView *menuView;
@property (retain, nonatomic) IBOutlet UILabel *lbTitle;
@property (retain, nonatomic) IBOutlet UILabel *lbTips1;
@property (retain, nonatomic) IBOutlet UILabel *lbTips2;
@property (retain, nonatomic) IBOutlet UIButton *btnSelect;
@property (retain, nonatomic) IBOutlet UIButton *btnCancel;
@property (retain, nonatomic) IBOutlet UIButton *btnOk;
@property (retain, nonatomic) IBOutlet UILabel *lbBtnTips;

@end

@implementation P2PAlertView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initMenuView];

}

- (void)initMenuView{
    
    self.frame = CGRectMake(0, 0, phoneRectScreen.size.width, phoneRectScreen.size.height);
    
    _menuView.alpha = 0;
    
    CALayer *layer = [_menuView layer];
    layer.shadowOffset = CGSizeMake(0, 3);
    layer.shadowRadius = 5.0;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.8;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched:)];
    [tapGestureRecognizer setDelegate:self];
    [_bgView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
}

- (void)reloadUIData:(NSString*)title tips1:(NSString*)tips1 tips2:(NSString*)tips2 btnTips:(NSString*)btnTips  btnLeftTips:(NSString*)btnLeftTips  btnRightTips:(NSString*)btnRightTips{
    _lbTitle.text = title;
    _lbTips1.text = tips1;
    _lbTips2.text = tips2;
    _lbBtnTips.text = btnTips;
    [_btnCancel setTitle:btnLeftTips forState:UIControlStateNormal];
    [_btnOk setTitle:btnRightTips forState:UIControlStateNormal];
}

- (void)reloadUIData:(NSString*)time{
    _lbTips2.text = time;
}

- (void)backgroundTouched:(UIGestureRecognizer*) recognizer{
    [self hide];
}

- (void)show:(UIView*)superView
{
    [superView addSubview:self];
    _bgView.alpha = 0;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         _menuView.alpha = 1;
                         _bgView.alpha = 0.2;
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)hide
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         _menuView.alpha = 0;
                         _bgView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}




- (IBAction)confirmButtonClicked:(id)sender {
    _btnSelect.selected = !_btnSelect.selected;
    _btnOk.enabled = _btnSelect.selected;
}

- (IBAction)okButtonClicked:(id)sender {
    [self hide];
    if (_delegate && [_delegate respondsToSelector:@selector(p2pAlertView:okButtonClicked:)]) {
        [_delegate p2pAlertView:self okButtonClicked:sender];
    }
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self hide];
    if (_delegate && [_delegate respondsToSelector:@selector(p2pAlertView:cancelButtonClicked:)]) {
        [_delegate p2pAlertView:self cancelButtonClicked:sender];
    }
}

- (void)dealloc{
    [_bgView release];
    [_menuView release];
    [_lbTitle release];
    [_lbTips1 release];
    [_lbTips2 release];
    [_btnSelect release];
    [_btnCancel release];
    [_btnOk release];
    [_lbBtnTips release];
    [super dealloc];
}

@end
