//
//  OrderPayWayAlertView.m
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "OrderPayWayAlertView.h"
#import "P2PPayWayEntity.h"
#import "RZWebImageView.h"

@interface OrderPayWayAlertView()
{

    
}
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIView *touchView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutContentViewBottom;

@property (assign, nonatomic) NSInteger selectedIndex;
@property (retain, nonatomic) NSMutableArray* tableData;

@end

@implementation OrderPayWayAlertView


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapEvent:)] autorelease];
    [_touchView addGestureRecognizer:recognizer];

}


- (void)dealloc
{
    [_tableData release];
    [_contentView release];
    [_touchView release];
    [_layoutContentViewBottom release];
    [super dealloc];
}

- (void)reloadUIData:(NSMutableArray*)array selectedPaymentId:(NSString*)selectedPaymentId {
    
    for (int i = 0; i< 3; i++) {
        UIView* baseView = (UIView*)[self viewWithTag:300 + i];
        baseView.hidden = YES;
    }
    
    for (int i = 0; i< array.count; i++) {
        P2PPayWayEntity* item = [array objectAtIndex:i];
        UIView* baseView = (UIView*)[self viewWithTag:300 + i];
        baseView.hidden = NO;
        
        RZWebImageView* logo = (RZWebImageView*)[self viewWithTag:50 + i];
        [logo showImageWithUrl:item.receiptLogo];
        
        UILabel* lbName = (UILabel*)[self viewWithTag:100 + i];
        lbName.text = item.receiptTypeValue;
        
        UIButton* btn = (UIButton*)[self viewWithTag:200 + i];
        if ([selectedPaymentId isEqualToString:item.paymentId]) {
            self.selectedIndex = btn.tag - 200;
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
    }
    self.tableData = array;
}

- (IBAction)selectBtnClicked:(id)sender {
    
    for (int i = 0; i< 3; i++) {
        UIButton* btn = (UIButton*)[self viewWithTag:200 + i];
        btn.selected = NO;
    }
    
    UIButton* btn = (UIButton*)sender;
    btn.selected = YES;
    
    self.selectedIndex = btn.tag - 200;
    
    P2PPayWayEntity* item = [_tableData objectAtIndex:_selectedIndex];
    
    if (_delegate && [_delegate respondsToSelector:@selector(p2pView:selectedPaymentId:)]) {
        [_delegate p2pView:self selectedPaymentId:item.paymentId];
    }
}

#pragma mark - 按钮点击事件
- (void)backgroundTapEvent:(UIGestureRecognizer *)recognizer
{
    [self dismissView];
}


#pragma mark - 显示与消失
/** 显示动画*/
- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    _layoutContentViewBottom.constant = -64 + IPHONEX_BOTTOM_HEIGHT;
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        _layoutContentViewBottom.constant = 0;
        [self layoutIfNeeded];
    }];
    
}

/** 隐藏页面*/
- (void)dismissView
{
    [UIView animateWithDuration:0.3 animations:^{
        _layoutContentViewBottom.constant = -_contentView.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end

