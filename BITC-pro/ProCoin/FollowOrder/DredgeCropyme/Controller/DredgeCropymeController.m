//
//  DredgeCropymeController.m
//  Cropyme
//
//  Created by Hay on 2019/6/12.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "DredgeCropymeController.h"
#import "NetWorkManage+FollowOrder.h"
#import "LoginSQLModel.h"
#import "TJRBaseEntity.h"

@interface DredgeCropymeController ()
{
    BOOL bReqFinished;          //是否请求完数据
}

@property (retain, nonatomic) IBOutlet UILabel *rulesLabel;     //规则Label
@property (retain, nonatomic) IBOutlet UILabel *balanceConditionLabel;  //资金条件

@property (copy, nonatomic) NSString *openFollowBalanceString;        //开通需要的资金
@property (copy, nonatomic) NSString *openFollowRulesString;          //开通规则

@end

@implementation DredgeCropymeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    bReqFinished = NO;
    [self showProgressDefaultText];
    [self reqOpenCropymeRules];
}

- (void)dealloc
{
    [_openFollowBalanceString release];
    [_openFollowRulesString release];
    [_rulesLabel release];
    [_balanceConditionLabel release];
    [super dealloc];
}

#pragma mark - 获取开通cropyme规则
- (void)reqOpenCropymeRules
{
    [[NetWorkManage shareSingleNetWork] reqOpenCropymeRules:self finishedCallback:@selector(reqOpenCropymeRulesFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqOpenCropymeRulesFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        bReqFinished = YES;
        NSDictionary *dataDic = [json objectForKey:@"data"];
        TJRBaseEntity *jsonParser = [[[TJRBaseEntity alloc] init] autorelease];
        self.openFollowRulesString = [jsonParser stringParser:@"openCopyRules" json:dataDic];
        self.openFollowBalanceString = [jsonParser stringParser:@"openCopyBalance" json:dataDic];
        
        
        _balanceConditionLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"开通条件:总资产不低于%@USDT"),_openFollowBalanceString];
        _rulesLabel.text = self.openFollowRulesString;
//        NSData *data = [_openFollowRulesString dataUsingEncoding:NSUnicodeStringEncoding];
//        NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
//        NSAttributedString *attributeString = [[[NSAttributedString alloc] initWithData:data options:options documentAttributes:nil error:nil] autorelease];
//        _rulesLabel.attributedText = attributeString;
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)applyCropymeButtonPressed:(id)sender
{
    if(!bReqFinished){
        [self showToastCenter:NSLocalizedStringForKey(@"数据不完整，请返回重试")];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"是否确定开通带单功能？") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqOpenCropyme];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 申请开通cropyme
- (void)reqOpenCropyme
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqOpenCropyme:self userId:ROOTCONTROLLER_USER.userId finishedCallback:@selector(reqOpenCropymeFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqOpenCropymeFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"恭喜你开通带单功能成功");
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self putValueToParamDictionary:ProCoinBaseDict value:ROOTCONTROLLER_USER.userId forKey:@"PersonalMainTargetUid"];
            [self pageToViewControllerForNameAndPopCurrentController:@"PersonalMainController"];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        ROOTCONTROLLER.user.openFollow = 1;
        [LoginSQLModel updateLoginInfo:ROOTCONTROLLER.user];
        
    }else{
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"申请开通带单功能发生错误");
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)serviceProtocolButtonPressed:(id)sender
{
    
    TYWebViewController *web = [[TYWebViewController alloc] init];
    web.url = CropymeServiceProtocol;
    [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
}

@end
