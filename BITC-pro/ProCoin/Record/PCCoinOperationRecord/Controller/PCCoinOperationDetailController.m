//
//  PCCoinOperationDetailController.m
//  ProCoin
//
//  Created by Hay on 2020/3/10.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCCoinOperationDetailController.h"
#import "VeDateUtil.h"
#import "NetWorkManage+ExtractCoin.h"

@interface PCCoinOperationDetailController ()

@property (retain, nonatomic) PCCoinOperationRecordModel *recordEntity;

@property (retain, nonatomic) IBOutlet UILabel *amountLabel;
@property (retain, nonatomic) IBOutlet UILabel *feeLabel;
@property (retain, nonatomic) IBOutlet UILabel *addressLabel;
@property (retain, nonatomic) IBOutlet UILabel *stateLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UILabel *amountTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *addressTitleLabel;

@end

@implementation PCCoinOperationDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([self getValueFromModelDictionary:ProCoinBaseDict forKey:@"PCCoinOperationDetailEntity"]){
        self.recordEntity = [self getValueFromModelDictionary:ProCoinBaseDict forKey:@"PCCoinOperationDetailEntity"];
        [self removeParamFromModelDictionary:ProCoinBaseDict forKey:@"PCCoinOperationDetailEntity"];
        [self reloadDetailData];
    }
}

- (void)dealloc
{
    [_recordEntity release];
    [_amountLabel release];
    [_feeLabel release];
    [_addressLabel release];
    [_stateLabel release];
    [_timeLabel release];
    [_cancelButton release];
    [_amountTitleLabel release];
    [_addressTitleLabel release];
    [super dealloc];
}


#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)cancelOrderButtonPressed:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"确定要取消提币吗?") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showProgressDefaultText];
        [self reqCancelCoinOperation];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - 请求数据
- (void)reqCancelCoinOperation
{
    [[NetWorkManage shareSingleNetWork] reqCancelExtractCoin:self withdrawId:_recordEntity.dwId finishedCallback:@selector(reqCancelCoinOperationFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCancelCoinOperationFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"操作成功");
        }
        [self showToastCenter:msg];
        _recordEntity.state = PCCoinOperationStateCancel;
        [self reloadDetailData];
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

#pragma mark - 更新数据
- (void)reloadDetailData
{
    _amountLabel.text = [NSString stringWithFormat:@"%@%@",_recordEntity.amount, _recordEntity.symbol];
    _feeLabel.text = [NSString stringWithFormat:@"%@%@",_recordEntity.fee, _recordEntity.symbol];
    _addressLabel.text = _recordEntity.address;
    _stateLabel.text = _recordEntity.stateDesc;
    _timeLabel.text = [VeDateUtil formatterDate:_recordEntity.createTime inStytle:nil outStytle:@"yyyy-MM-dd HH:mm:ss" isTimestamp:YES];
    if(_recordEntity.inOut == PCCoinOperationTypeIn){       //充币
        _amountTitleLabel.text = NSLocalizedStringForKey(@"充币数量");
        _addressTitleLabel.text = NSLocalizedStringForKey(@"充币地址");
    }else{
        _amountTitleLabel.text = NSLocalizedStringForKey(@"提币数量");
        _addressTitleLabel.text = NSLocalizedStringForKey(@"提币地址");
    }
    if(_recordEntity.state == PCCoinOperationStateCommit && _recordEntity.inOut == PCCoinOperationTypeOut){      //提币时并且提交状态才有撤销按钮，其他状态没有
        _cancelButton.hidden = NO;
    }else{
        _cancelButton.hidden = YES;
    }
}

@end
