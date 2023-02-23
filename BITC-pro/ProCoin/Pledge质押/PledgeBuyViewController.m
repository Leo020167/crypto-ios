//
//  PledgeBuyViewController.m
//  ProCoin
//
//  Created by Luo Chun on 2022/11/24.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "PledgeBuyViewController.h"
#import "YYRequestUtility.h"

@interface PledgeBuyViewController ()<UITextFieldDelegate> {
    
}
@property (retain, nonatomic) NSDictionary *pledgeInfo;
/**UI*/
@property (retain, nonatomic) IBOutlet UIView *coreView;
@property (retain, nonatomic) IBOutlet UITextField *inputSymbolTF;
@property (retain, nonatomic) IBOutlet UIButton *doneButton;
@property (retain, nonatomic) IBOutlet UILabel *daysLabel;        //
@property (retain, nonatomic) IBOutlet UILabel *gainLabel;        //预期收益
@property (retain, nonatomic) IBOutlet UILabel *minPledgeLabel;        //最小质押
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *coreViewLayoutConstraintBottom;  //核心view顶部约束


@end

@implementation PledgeBuyViewController

- (void)viewDidLayoutSubviews {
    _coreView.layer.mask = nil;
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: _coreView.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){10.0, 10.0}].CGPath;
    maskLayer.frame = _coreView.bounds;
    _coreView.layer.mask = maskLayer;
}

- (void)bindPledgeInfo:(NSDictionary *)pledgeInfo {
    self.pledgeInfo = pledgeInfo;
    _daysLabel.text = [NSString stringWithFormat: @"%@%@", pledgeInfo[@"duration"], NSLocalizedStringForKey(@"天")];
    _gainLabel.text = [NSString stringWithFormat: @"%@%%", pledgeInfo[@"profitRate"]];
    _minPledgeLabel.text =  [NSString stringWithFormat: @"%@%@%@",
                             NSLocalizedStringForKey(@"最小质押数量"), pledgeInfo[@"minCount"], pledgeInfo[@"symbol"] ];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _inputSymbolTF.delegate = self;
    _coreViewLayoutConstraintBottom.constant = -_coreView.frame.size.height;
    [self.view layoutIfNeeded];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [_coreView release];
    [_inputSymbolTF release];
    [_doneButton release];
    [_daysLabel release];
    [_gainLabel release];
    [_minPledgeLabel release];
    [super dealloc];
}


#pragma mark -  显示与消失
- (void)addSelfToParentViewController:(UIViewController *)controller pledge:(NSDictionary *)pledge
{
    //_inputSymbolTF.text = inputSymbol;
    [self bindPledgeInfo: pledge];
    //[self reloadOrderTypeUI];
    
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        _coreViewLayoutConstraintBottom.constant = 0;
        [self.view layoutIfNeeded];
    }];
    
}

- (void)dismissViewController {
    [UIView animateWithDuration:0.3 animations:^{
        _coreViewLayoutConstraintBottom.constant = -_coreView.frame.size.height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _coreViewLayoutConstraintBottom.constant = keyboardRect.size.height;

//    [self.bgView layoutIfNeeded];
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
    } completion:^(BOOL finished) {
        self.coreViewLayoutConstraintBottom.constant = 0;
    }];
    
}

#pragma mark - 按钮点击事件


/** 取消页面*/
- (IBAction)dimissView
{
    [self dismissViewController];
}

/** 提交数据*/
- (IBAction)commit:(id)sender
{
    if(checkIsStringWithAnyText(_inputSymbolTF.text)){
        NSNumber *number = [NSNumber numberWithInt:[_inputSymbolTF.text floatValue]] ;
//        if (number < [NSNumber numberWithInt:[self.pledgeInfo[@"minCount"] floatValue]]) {
//            //[QMUITips showInfo:_minPledgeLabel.text];
//            [QMUITips showInfo: NSLocalizedStringForKey(@"账户可用余额不足")];
//            return;
//        }
        if (number > 0) {
            [YYRequestUtility Post:@"pledge/commit.do" addParameters:@{@"pledgeId": self.pledgeInfo[@"id"], @"count": number} progress:nil success:^(NSDictionary *responseDict) {
                if ([responseDict[@"code"] intValue] == 200) {
                    [QMUITips showSucceed:responseDict[@"msg"]];
                    [self dismissViewController];
                } else {
                    [QMUITips showError:responseDict[@"msg"]];
                }
                
            } failure:^(NSError *error) {
                
            }];
        }
    }
}



#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_inputSymbolTF resignFirstResponder];
    return YES;
}

@end
