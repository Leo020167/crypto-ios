//
//  PayWayAlertView.m
//  ProCoin
//
//  Created by UnWood on 2021/4/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "PayWayAlertView.h"
#import "P2POrderEntity.h"
#import "CommonUtil.h"
#import "RZWebImageView.h"
#import "P2PPayWayEntity.h"
#import "TJRBaseParserJson.h"
#import "NetWorkManage+P2P.h"
#import "TJRBaseViewController.h"

@interface PayWayAlertView()
{
    BOOL bReqFinished;
    NSMutableArray* tableData;
    
}
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UIView *touchView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutContentViewBottom;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutWay1Height;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutWay2Height;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutWay3Height;

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@end

@implementation PayWayAlertView


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapEvent:)] autorelease];
    [_touchView addGestureRecognizer:recognizer];

    bReqFinished = YES;
    tableData = [[NSMutableArray alloc]init];
    
    [self reqFindMyPaymentList];
}


- (void)dealloc
{
    [tableData release];
    [_indicatorView release];
    [_contentView release];
    [_touchView release];
    [_layoutContentViewBottom release];
    [_layoutWay1Height release];
    [_layoutWay2Height release];
    [_layoutWay3Height release];
    [super dealloc];
}

- (IBAction)payWayBtnClicked:(id)sender {
    for (int i = 0; i< 3; i++) {
        UIButton* btn = (UIButton*)[self viewWithTag:50 + i];
        btn.selected = NO;
    }
    
    UIButton* btn = (UIButton*)sender;
    btn.selected = YES;
    

    P2PPayWayEntity *item = [tableData objectAtIndex:btn.tag - 50];
    
    if (_delegate && [_delegate respondsToSelector:@selector(p2pView:entity:)]) {
        [_delegate p2pView:self entity:item];
    }
    
    [self dismissView];
}
- (IBAction)addBtnClicked:(id)sender {
    
    [self dismissView];
    [[CommonUtil getControllerWithContainView:self] pageToOrBackWithName:@"P2PBankWayController"];
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

#pragma mark - 【收款方式】获取我的收款方式列表
- (void)reqFindMyPaymentList
{
    if (bReqFinished) {
        bReqFinished = NO;
        [_indicatorView startAnimating];
        [[NetWorkManage shareSingleNetWork] reqP2PFindMyPaymentList:self finishedCallback:@selector(reqPaymentListFinished:) failedCallback:@selector(reqPaymentListFailed:)];
    }
    
}

- (void)reqPaymentListFinished:(id)result
{
    [_indicatorView stopAnimating];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        [tableData removeAllObjects];
        NSDictionary *dataDic = [result objectForKey:@"data"];
        NSArray *list = [dataDic objectForKey:@"myPaymentList"];
        NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
        for(NSDictionary *dic in list){
            P2PPayWayEntity *entity = [[[P2PPayWayEntity alloc] initWithJson:dic]autorelease];
            [array addObject:entity];
        }
        [tableData addObjectsFromArray:array];
        _layoutWay1Height.constant = 0;
        _layoutWay2Height.constant = 0;
        _layoutWay3Height.constant = 0;
        
        for (int i = 0; i < tableData.count; i++) {
            P2PPayWayEntity *item = [tableData objectAtIndex:i];
            UILabel* lb = (UILabel*)[self viewWithTag:100 +i];
            lb.text = item.receiptNo;
            RZWebImageView* logo = (RZWebImageView*)[self viewWithTag:400 + i];
            [logo showImageWithUrl:item.receiptLogo];
            UIView* view = (UIView*)[self viewWithTag:300 + i];
            view.hidden = NO;
            UIButton* btn = (UIButton*)[self viewWithTag:i + 50];
            btn.selected = NO;
            if (i == 0) _layoutWay1Height.constant = 50;
            if (i == 1) _layoutWay2Height.constant = 50;
            if (i == 2) _layoutWay3Height.constant = 50;
        }
        
        
        
    }else{
        [[CommonUtil getControllerWithContainView:self] showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

- (void)reqPaymentListFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [_indicatorView stopAnimating];
    [[CommonUtil getControllerWithContainView:self] showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

@end

