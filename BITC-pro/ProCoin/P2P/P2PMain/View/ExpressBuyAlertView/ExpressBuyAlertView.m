//
//  ExpressBuyAlertView.m
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "ExpressBuyAlertView.h"
#import "P2POrderEntity.h"
#import "CommonUtil.h"
#import "RZWebImageView.h"
#import "P2PPayWayEntity.h"
#import "TJRBaseParserJson.h"
#import "NetWorkManage+P2P.h"
#import "TJRBaseViewController.h"

@interface ExpressBuyAlertView()
{

    BOOL bReqFinished;
}
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIView *touchView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutContentViewBottom;
@property (retain, nonatomic) IBOutlet UILabel *lbPrice;
@property (retain, nonatomic) IBOutlet UILabel *lbAmount;
@property (retain, nonatomic) IBOutlet UILabel *lbTotal;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (copy, nonatomic) NSString* receiptType;
@property (copy, nonatomic) NSString* buySell;
@property (copy, nonatomic) NSString* amount;
@property (retain, nonatomic) P2POrderEntity *entity;
@end

@implementation ExpressBuyAlertView


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapEvent:)] autorelease];
    [_touchView addGestureRecognizer:recognizer];

    bReqFinished = YES;
}


- (void)dealloc
{
    [_buySell release];
    [_entity release];
    [_indicatorView release];
    [_receiptType release];
    [_lbPrice release];
    [_lbTotal release];
    [_lbAmount release];
    [_contentView release];
    [_touchView release];
    [_layoutContentViewBottom release];
    [_amount release];
    [super dealloc];
}

- (void)reloadUIData:(P2POrderEntity*)entity buySell:(NSString*)buySell amount:(NSString*)amount{
    for (int i = 0; i< 3; i++) {
        UIButton* btn = (UIButton*)[self viewWithTag:50 + i];
        btn.selected = NO;
        UIView* view = (UIView*)[self viewWithTag:200 + i];
        view.hidden = YES;
    }
    
    for (int i = 0; i<entity.payWayArray.count; i++) {
        P2PPayWayEntity *item = [entity.payWayArray objectAtIndex:i];
        
        UIView* view = (UIView*)[self viewWithTag:200 + i];
        view.hidden = NO;
        RZWebImageView* logo = (RZWebImageView*)[self viewWithTag:300 + i];
        [logo showImageWithUrl:item.receiptLogo];
        UILabel* lbName = (UILabel*)[self viewWithTag:100 + i];
        lbName.text = item.receiptTypeValue;
    }
    _lbPrice.text = [NSString stringWithFormat:@"%@ %@/USDT", entity.price, entity.currencyType];
    _lbAmount.text = [NSString stringWithFormat:@"%@ USDT",amount];
    _lbTotal.text = [NSString stringWithFormat:@"%@%.2f", entity.currencySign, [entity.price floatValue]*[amount floatValue]];
    
    self.entity = entity;
    
    UIButton* btn = (UIButton*)[self viewWithTag:50];
    [self payWayBtnClicked:btn];
    
    self.amount = amount;
    self.buySell = buySell;
}

- (IBAction)payWayBtnClicked:(id)sender {
    for (int i = 0; i< 3; i++) {
        UIButton* btn = (UIButton*)[self viewWithTag:50 + i];
        btn.selected = NO;
        [CommonUtil viewMasksToBounds:btn cornerRadius:3 borderColor:[UIColor whiteColor] borderWidth:0.5];
    }
    
    UIButton* btn = (UIButton*)sender;
    btn.selected = YES;
    
    [CommonUtil viewMasksToBounds:btn cornerRadius:3 borderColor:RGBA(97, 117, 174, 1) borderWidth:0.5];
    
    P2PPayWayEntity *item = [_entity.payWayArray objectAtIndex:btn.tag - 50];
    self.receiptType = item.receiptType;
}

- (IBAction)confirmBtnClicked:(id)sender {
    [self reqP2PCreateOrder:_buySell adId:_entity.adId price:_entity.price amount:_amount showReceiptType:_receiptType];
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

#pragma mark - 请求数据接口
- (void)reqP2PCreateOrder:(NSString*)buySell adId:(NSString*)adId price:(NSString*)price amount:(NSString*)amount showReceiptType:(NSString*)showReceiptType
{
    if (bReqFinished) {
        bReqFinished = NO;
        [_indicatorView startAnimating];
        [[NetWorkManage shareSingleNetWork] reqP2PCreateOrder:self buySell:buySell adId:adId amount:amount price:price showReceiptType:showReceiptType finishedCallback:@selector(reqCreateOrderFinished:) failedCallback:@selector(reqCreateOrderFailed:)];
    }
    
}

- (void)reqCreateOrderFinished:(id)result
{
    [_indicatorView stopAnimating];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    
    if([parser parseBaseIsOk:result]){

        NSDictionary *dataDic = [result objectForKey:@"data"];
        NSString* orderId = [parser stringParser:dataDic name:@"orderId"];
        
        [[CommonUtil getControllerWithContainView:self] showToast:str inView:ROOTCONTROLLER.view];
        
        [[CommonUtil getControllerWithContainView:self] putValueToParamDictionary:P2PDict value:orderId forKey:@"orderId"];
        [[CommonUtil getControllerWithContainView:self] pageToOrBackWithName:@"P2PConfirmController"];
        
        [self dismissView];
        
        
    }else{
        NSString* code = [NSString stringWithFormat:@"%@",[result objectForKey:@"code"]];
        if ([code isEqualToString:@"40090"]) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:str preferredStyle:UIAlertControllerStyleAlert];
            __block typeof(UIViewController*) weakSelf = [CommonUtil getControllerWithContainView:self];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"去设置") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf pageToOrBackWithName:@"MyOauthController"];
            }];
            [alertController addAction:alertAction];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf dismissViewControllerAnimated:alertController completion:nil];
            }]];
            [self dismissView];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }else{
            [[CommonUtil getControllerWithContainView:self] showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
        
    }
    

}

- (void)reqCreateOrderFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [_indicatorView stopAnimating];
    [[CommonUtil getControllerWithContainView:self] showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}


@end

