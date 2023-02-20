//
//  HomeMineHeaderView.m
//  Cropyme
//
//  Created by Hay on 2019/7/18.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "HomeMineHeaderView.h"
#import "RZWebImageView.h"
#import "HomeNewNumEntity.h"
#import "PCAccountModel.h"

@interface HomeMineHeaderView()
{

}

@property (retain, nonatomic) IBOutlet RZWebImageView *headLogo;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *usdtTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *userIdLabel;
@property (retain, nonatomic) IBOutlet UIView *OTCView;


@end

@implementation HomeMineHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.OTCView.qmui_badgeTextColor = UIColor.whiteColor;
    self.OTCView.qmui_badgeBackgroundColor = UIColor.redColor;
    self.OTCView.qmui_badgeOffset = CGPointMake(-25, 20);
    self.usdtTitleLabel.text = [NSString stringWithFormat: @"%@:", NSLocalizedStringForKey(@"可用(USDT)")];
}

- (void)dealloc
{
    [_headLogo release];
    [_nameLabel release];
    [_userIdLabel release];
    [_OTCView release];
    [_usdtTitleLabel release];
    [super dealloc];
}


#pragma mark - 更新数据
- (void)reloadHeaderViewBaseData
{
   NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"MessageCount"];
    if (count == 0) {
        self.OTCView.qmui_shouldShowUpdatesIndicator = NO;
        self.OTCView.qmui_badgeInteger = count;
    }else{
        self.OTCView.qmui_shouldShowUpdatesIndicator = YES;
        self.OTCView.qmui_badgeInteger = count;
    }
    [_headLogo showImageWithUrl:ROOTCONTROLLER_USER.headurl];
    _nameLabel.text = ROOTCONTROLLER_USER.name;
    //_userIdLabel.text = ROOTCONTROLLER_USER.userId;
}

- (void)reloadAccount: (NSString *)usdtAmount {
    self.userIdLabel.text = usdtAmount;
    
//    [YYRequestUtility Post:@"home/account.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
//        if ([responseDict[@"code"] intValue] == 200) {
//            //更新顶部总资产数据
//            NSDictionary *spotDic = [responseDict[@"data"] objectForKey:@"spotAccount"];
//            PCAccountModel *spotModel = [PCAccountModel yy_modelWithDictionary:spotDic];
//
//            self.userIdLabel.text = spotModel.holdAmount;
//        }else{
//            [QMUITips showError:responseDict[@"msg"]];
//        }
//    } failure:^(NSError *error) {
//    }];
}

#pragma mark - 按钮点击事件
/** 编辑资料*/

- (IBAction)editInfoButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(mineHeaderViewEventDidSeleted:)]){
        [_delegate mineHeaderViewEventDidSeleted:MineHeaderViewEditInfoEvent];
    }
}

/** 个人主页按钮点击事件*/
- (IBAction)personalMainButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(mineHeaderViewEventDidSeleted:)]){
        [_delegate mineHeaderViewEventDidSeleted:MineHeaderViewPersonalMainEvent];
    }
}

- (IBAction)chargeCoinButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(mineHeaderViewEventDidSeleted:)]){
        [_delegate mineHeaderViewEventDidSeleted:MineHeaderViewChargeCoinEvent];
    }
}

- (IBAction)extractCoinButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(mineHeaderViewEventDidSeleted:)]){
        [_delegate mineHeaderViewEventDidSeleted:MineHeaderViewExtractCoinEvent];
    }
}

- (IBAction)transferCoinButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(mineHeaderViewEventDidSeleted:)]){
        [_delegate mineHeaderViewEventDidSeleted:MineHeaderViewTransferCoinEvent];
    }
}

- (IBAction)p2pInOutBtnClicked:(id)sender {
    if([_delegate respondsToSelector:@selector(mineHeaderViewEventDidSeleted:)]){
        [_delegate mineHeaderViewEventDidSeleted:MineHeaderViewP2PInOutEvent];
    }
}


@end