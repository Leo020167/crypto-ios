//
//  CircleJoinReasonController.m
//  Tjrv
//
//  Created by taojinroad on 2019/2/26.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CircleJoinReasonController.h"
#import "TJRBaseParserJson.h"
#import "NetWorkManage+Circle.h"

@interface CircleJoinReasonController (){
    
    BOOL bReqFinished;
}
@property (copy, nonatomic) NSString *circleId;

@property (retain, nonatomic) IBOutlet UIButton *btnSend;
@property (retain, nonatomic) IBOutlet UITextView *tvReason;
@property (retain, nonatomic) IBOutlet UIButton *btnLeft;
@end

@implementation CircleJoinReasonController

- (void)viewDidLoad {
    [super viewDidLoad];
    bReqFinished = YES;
    
    if([self getValueFromModelDictionary:CircleDict  forKey:@"circleId"]){
        self.circleId = [self getValueFromModelDictionary:CircleDict  forKey:@"circleId"];
        [self removeParamFromModelDictionary:CircleDict forKey:@"circleId"];
    }
    
    _tvReason.text = @"";
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_tvReason becomeFirstResponder];
}

- (IBAction)leftButtonClicked:(id)sender {
    [self goBack];
}

- (IBAction)sendButtonClicked:(id)sender {
    
    if (!TTIsStringWithAnyText(_tvReason.text)) {
        [self showToastCenter:@"请输入申请原因"];
        return;
    }
    if (_tvReason.text.length>300) {
        [self showToastCenter:@"请输入不多于300字符"];
        return;
    }
    
    [self requestData:_tvReason.text];
}

#pragma mark - 请求我的列表
- (void)requestData:(NSString*)str
{
    if(bReqFinished)
    {
        bReqFinished = NO;
        self.btnSend.enabled = NO;
        [self showProgressDefaultText];

        [[NetWorkManage shareSingleNetWork] reqCircleApplyJoin:self circleId:_circleId reason:str finishedCallback:@selector(reqDataFinished:) failedCallback:@selector(reqDataFailed:) ];
    }
}

- (void)reqDataFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    self.btnSend.enabled = YES;
    
    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init]autorelease];
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    if ([jsonParser parseBaseIsOk:result]) {
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:str imageName:HUD_SUCCEED];
        [self performSelector:@selector(goBack) withObject:Nil afterDelay:1.0];
        self.btnSend.enabled = NO;
        self.btnLeft.enabled = NO;
        self.canDragBack = NO;
    }else{
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"温馨提示") detailsMessage:str imageName:HUD_ERROR];
    }
}

- (void)reqDataFailed:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    self.btnSend.enabled = YES;
    [self showProgressHUDCompleteMessage:@"提交失败" detailsMessage:@"" imageName:HUD_ERROR];
}

- (void)dealloc {
    [_circleId release];
    [_btnSend release];
    [_tvReason release];
    [_btnLeft release];
    [super dealloc];
}
@end
