//
//  SegmentFollowOrderVC.m
//  Cropyme
//
//  Created by Hay on 2019/7/20.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "PCSegmentFollowOrderVC.h"
#import "RZWebImageView.h"
#import "TradeUtil.h"
#import "CommonUtil.h"

@interface PCSegmentFollowOrderVC ()<UITableViewDelegate,UITableViewDataSource>
{

}

/** 属性变量*/
@property (copy, nonatomic) NSArray *digitalHoldDataArr;
@property (copy, nonatomic) NSArray *stockFuturesDataArr;
@property (retain, nonatomic) PCAccountModel *digitalAccountEntity;
@property (retain, nonatomic) PCAccountModel *stockFuturesAccountEntity;
@property (retain, nonatomic) PCHomeUserFollowOrderInfoModel *userFollowEntity;     //大v信息

/** UI变量*/
@property (retain, nonatomic) UIButton *digitalButton;          //数字货币按钮
@property (retain, nonatomic) UIButton *stockFuturesButton;     //股指期货按钮

/** 懒加载*/
@property (retain, nonatomic) UIView *settingHeaderView;
@property (assign, nonatomic) CGFloat accountInfoCellHeight;
@property (assign, nonatomic) CGFloat accountHoldCellHeight;

@end

@implementation PCSegmentFollowOrderVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    _followOrderTableView.delegate = self;
    _followOrderTableView.dataSource = self;
    //reloadData 视图漂移或者闪动解决方法
    _followOrderTableView.estimatedRowHeight = 0;
    _followOrderTableView.estimatedSectionHeaderHeight = 0;
    _followOrderTableView.estimatedSectionFooterHeight = 0;
    
}

- (void)dealloc
{
    [_followOrderTableView release];
    [_digitalHoldDataArr release];
    [_stockFuturesDataArr release];
    [_digitalAccountEntity release];
    [_stockFuturesAccountEntity release];
    [_userFollowEntity release];
    [_digitalButton release];
    [_stockFuturesButton release];
    [_settingHeaderView release];
    [super dealloc];
}

#pragma mark - 懒加载
- (UIView *)settingHeaderView
{
    if(_settingHeaderView == nil){
        _settingHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"PCHomeFollowOrderAccountSettingView" owner:nil options:nil] lastObject] retain];
        UIButton *bindOpeButton = (UIButton *)[_settingHeaderView viewWithTag:104];
        UISwitch *openSwitch = (UISwitch *)[_settingHeaderView viewWithTag:105];
        UIButton *mulitSettingButton = (UIButton *)[_settingHeaderView viewWithTag:107];
        self.digitalButton = (UIButton *)[_settingHeaderView viewWithTag:201];
        self.stockFuturesButton = (UIButton *)[_settingHeaderView viewWithTag:202];
        [openSwitch addTarget:self action:@selector(openFollowOrderOperation:) forControlEvents:UIControlEventValueChanged];
        [bindOpeButton addTarget:self action:@selector(bindOperationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [mulitSettingButton addTarget:self action:@selector(multiNumSettingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_digitalButton addTarget:self action:@selector(followOrderTypeOptionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_stockFuturesButton addTarget:self action:@selector(followOrderTypeOptionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingHeaderView;
}

- (CGFloat)accountInfoCellHeight
{
    if(_accountInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountInfoCell" owner:nil options:nil] lastObject];
        _accountInfoCellHeight = cell.frame.size.height;
    }
    return _accountInfoCellHeight;
}

- (CGFloat)accountHoldCellHeight
{
    if(_accountHoldCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountHoldCell" owner:nil options:nil] lastObject];
        _accountHoldCellHeight = cell.frame.size.height;
    }
    return _accountHoldCellHeight;
}

#pragma mark - 更新数据
- (void)reloadFollowOrderAccountDigitalInfo:(PCAccountModel *)digitalInfoEntity stockFuturesInfo:(PCAccountModel *)stockFuturesEntity accountDigitalHoldData:(NSArray *)digitalDataArr acountStockFuturesHoldData:(NSArray *)stockFuturesDataArr userFollowInfo:(PCHomeUserFollowOrderInfoModel *)userFollowEntity
{
    self.digitalAccountEntity = digitalInfoEntity;
    self.stockFuturesAccountEntity = stockFuturesEntity;
    self.digitalHoldDataArr = digitalDataArr;
    self.stockFuturesDataArr = stockFuturesDataArr;
    self.userFollowEntity = userFollowEntity;
    /** 跟新大v设置信息*/
    [self reloadSettingHeaderViewData];
    [_followOrderTableView reloadData];
}

/** 更新settingview页面*/
- (void)reloadSettingHeaderViewData
{
    UIView *contentView = [self.settingHeaderView viewWithTag:100];
    RZWebImageView *headIV = (RZWebImageView *)[self.settingHeaderView viewWithTag:101];
    UILabel *nameLabel = (UILabel *)[self.settingHeaderView viewWithTag:102];
    UILabel *openStateLabel = (UILabel *)[self.settingHeaderView viewWithTag:103];
    UIButton *bindOpeButton = (UIButton *)[self.settingHeaderView viewWithTag:104];
    UISwitch *openSwitch = (UISwitch *)[self.settingHeaderView viewWithTag:105];
    UILabel *multiLabel = (UILabel *)[self.settingHeaderView viewWithTag:106];
    if(checkIsStringWithAnyText(self.userFollowEntity.dvUid) && ![self.userFollowEntity.dvUid isEqualToString:@"0"]){       //是否已开通跟单
        headIV.hidden = NO;
        [headIV showHeaderImageViewWithUrl:self.userFollowEntity.dvHeadUrl];
        nameLabel.text = self.userFollowEntity.dvUserName;
        [bindOpeButton setTitle:NSLocalizedStringForKey(@"查看导师") forState:UIControlStateNormal];
        //更改namelabel的坐标
        if(nameLabel.frame.origin.x != 120){
            for (NSLayoutConstraint *l in contentView.constraints) {
                if (l.firstAttribute == NSLayoutAttributeLeading && l.firstItem == nameLabel) {
                    l.constant = 120;
                }
            }
        }
    }else{
        headIV.hidden = YES;
        //更改namelabel的坐标
        if(nameLabel.frame.origin.x != 84){
            for (NSLayoutConstraint *l in contentView.constraints) {
                if (l.firstAttribute == NSLayoutAttributeLeading && l.firstItem == nameLabel) {
                    l.constant = 84;
                }
            }
        }
        nameLabel.text = NSLocalizedStringForKey(@"未绑定");
        [bindOpeButton setTitle:NSLocalizedStringForKey(@"去绑定") forState:UIControlStateNormal];
    }
    //是否开通跟单，开通跟单与绑定大v逻辑分开
    if(self.userFollowEntity.isOpen){
        openStateLabel.text = NSLocalizedStringForKey(@"已开启");
    }else{
        openStateLabel.text = NSLocalizedStringForKey(@"未开启");
    }
    openSwitch.on = self.userFollowEntity.isOpen;
    multiLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"%@倍"),self.userFollowEntity.multiple];
    
}

#pragma mark - 按钮点击事件
- (void)followOrderTypeOptionsButtonPressed:(UIButton *)button
{
    UIView *contentView = [self.settingHeaderView viewWithTag:200];
    if(button == _digitalButton){
        if(_digitalButton.isSelected)
            return;
        _digitalButton.selected = YES;
        _stockFuturesButton.selected = NO;
        _digitalButton.layer.borderColor = RGBA(97, 117, 174, 1.0).CGColor;
        _stockFuturesButton.layer.borderColor = RGBA(61, 58, 80, 0.4).CGColor;
        [contentView bringSubviewToFront:_digitalButton];
    }else{
        if(_stockFuturesButton.isSelected){
            return;
        }
        _digitalButton.selected = NO;
        _stockFuturesButton.selected = YES;
        _digitalButton.layer.borderColor = RGBA(61, 58, 80, 0.4).CGColor;
        _stockFuturesButton.layer.borderColor = RGBA(97, 117, 174, 1.0).CGColor;
        [contentView bringSubviewToFront:_stockFuturesButton];
    }
    [_followOrderTableView reloadData];
}

/** 绑定与解除绑定*/
- (void)bindOperationButtonPressed:(UIButton *)button
{
    if([_delegate respondsToSelector:@selector(followOrderViewBindOperationButtonDidPressed:)]){
        [_delegate followOrderViewBindOperationButtonDidPressed:self.userFollowEntity];
    }
}

/** 设置倍数按钮*/
- (void)multiNumSettingButtonPressed:(UIButton *)button
{
    if([_delegate respondsToSelector:@selector(followOrderViewMultiNumButtonDidPressed)]){
        [_delegate followOrderViewMultiNumButtonDidPressed];
    }
}

/** 设置是否开通跟单*/
- (void)openFollowOrderOperation:(UISwitch *)openSwitch
{
    if([_delegate respondsToSelector:@selector(followOrderViewOpenFollowSwitchValueChanged:)]){
        [_delegate followOrderViewOpenFollowSwitchValueChanged:openSwitch.isOn];
    }
}

/** 问号点击事件*/
- (void)questionButtonPressed:(UIButton *)sender
{
    if([_delegate respondsToSelector:@selector(followOrderViewRiskQuestionButtonDidPressed)]){
        [_delegate followOrderViewRiskQuestionButtonDidPressed];
    }
}

#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){           //账户信息
        return self.settingHeaderView.frame.size.height;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){       //账户信息
        return self.settingHeaderView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 10)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){         //账户信息
        return 1;
    }else if(section == 1){   //持仓信息
        if(_digitalButton.isSelected){
            return [_digitalHoldDataArr count];
        }else{
            return [_stockFuturesDataArr count];
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){         //账户信息
        return self.accountInfoCellHeight;
    }else if(indexPath.section == 1){   //持仓信息
        return self.accountHoldCellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *holdCellIdentifier = @"PCBaseAccountHoldCellIdentifier";
    if(indexPath.section == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountInfoCell" owner:nil options:nil] lastObject];
        UILabel *assetsLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *cnyLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *riskLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *eableLabel = (UILabel *)[cell viewWithTag:103];
        UILabel *profitLabel = (UILabel *)[cell viewWithTag:104];
        UILabel *openBailLabel = (UILabel *)[cell viewWithTag:105];
        UILabel *frozenBailLabel = (UILabel *)[cell viewWithTag:106];
        UILabel *accountLabel = (UILabel *)[cell viewWithTag:107];
        UIButton *questionButton = (UIButton *)[cell viewWithTag:500];
        UILabel *freezeLabel = (UILabel *)[cell viewWithTag:501];
        [questionButton addTarget:self action:@selector(questionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        freezeLabel.text = @"跟單凍結資產(USDT)";
//        if(_digitalButton.isSelected){              //数字货币跟单资产
            /// 1国际期货 2外汇 3数字
            if (self.digitalAccountEntity.type == 1) {
                accountLabel.text = NSLocalizedStringForKey(@"国际期货跟单资产(USDT)");
            }else if (self.digitalAccountEntity.type == 2) {
                accountLabel.text = NSLocalizedStringForKey(@"外汇跟单资产(USDT)");
            }else if (self.digitalAccountEntity.type == 3) {
                accountLabel.text = NSLocalizedStringForKey(@"数字货币跟单资产(USDT)");
            }
            
            if(_digitalAccountEntity == nil){
                return cell;
            }
            assetsLabel.text = _digitalAccountEntity.assets;
            cnyLabel.text = _digitalAccountEntity.assetsCny;
            riskLabel.text = [NSString stringWithFormat:@"%@%%",_digitalAccountEntity.riskRate];
            eableLabel.text = _digitalAccountEntity.eableBail;
            profitLabel.text = [TradeUtil stringByAppendingPlusSymbolString:_digitalAccountEntity.profit];
            profitLabel.textColor = [TradeUtil textColorWithQuotationNumber:[_digitalAccountEntity.profit doubleValue]];
            openBailLabel.text = _digitalAccountEntity.openBail;
            frozenBailLabel.text = _digitalAccountEntity.disableAmount;
            return cell;
//        }else{                  //股指期货跟单资产
//            accountLabel.text = @"股指期货跟单资产(USDT)";
//            if(_stockFuturesAccountEntity == nil){
//                return cell;
//            }
//            assetsLabel.text = _stockFuturesAccountEntity.assets;
//            cnyLabel.text = _stockFuturesAccountEntity.assetsCny;
//            riskLabel.text = [NSString stringWithFormat:@"%@%%",_stockFuturesAccountEntity.riskRate];
//            eableLabel.text = _stockFuturesAccountEntity.eableBail;
//            profitLabel.text = [TradeUtil stringByAppendingPlusSymbolString:_stockFuturesAccountEntity.profit];
//            profitLabel.textColor = [TradeUtil textColorWithQuotationNumber:[_stockFuturesAccountEntity.profit doubleValue]];
//            openBailLabel.text = _stockFuturesAccountEntity.openBail;
//            frozenBailLabel.text = _stockFuturesAccountEntity.frozenBail;
//            return cell;
//        }
        
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:holdCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountHoldCell" owner:nil options:nil] lastObject];
        }
        PCBaseHoldCoinModel *entity = nil;
        if(_digitalButton.isSelected){
            entity = [_digitalHoldDataArr objectAtIndex:indexPath.row];
        }else{
            entity = [_stockFuturesDataArr objectAtIndex:indexPath.row];
        }
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *rateLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *handAmountLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *openPriceLabel = (UILabel *)[cell viewWithTag:103];
        UILabel *profitLabel = (UILabel *)[cell viewWithTag:104];
        NSString *titleString = [NSString stringWithFormat:@"%@·%@",entity.symbol,entity.buySellValue];
        NSRange range = [titleString rangeOfString:@"/"];
        NSMutableAttributedString *titleAttributed = [[[NSMutableAttributedString alloc] initWithString:titleString] autorelease];
        if(range.location != NSNotFound){
            [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f],NSForegroundColorAttributeName:RGBA(29, 49, 85, 1.0)} range:NSMakeRange(0,range.location + 1)];
            [titleAttributed addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f],NSForegroundColorAttributeName:RGBA(97, 117, 174, 0.4)} range:NSMakeRange(range.location,titleString.length - range.location)];
        }
        titleLabel.attributedText = titleAttributed;
        rateLabel.text = [NSString stringWithFormat:@"%@%%",[TradeUtil stringByAppendingPlusSymbolString:entity.profitRate]];
        rateLabel.textColor = [TradeUtil textColorWithQuotationNumber:[entity.profitRate doubleValue]];
        handAmountLabel.text = entity.openHand;
        openPriceLabel.text = entity.openPrice;
        profitLabel.text = [TradeUtil stringByAppendingPlusSymbolString:entity.profit];
        profitLabel.textColor = [TradeUtil textColorWithQuotationNumber:[entity.profit doubleValue]];
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.section == 1){
        if([_delegate respondsToSelector:@selector(followOrderViewDidSelctedHoldDataWithOrderId:)]){
            PCBaseHoldCoinModel *entity = nil;
            if(_digitalButton.isSelected){
                entity = [_digitalHoldDataArr objectAtIndex:indexPath.row];
            }else{
                entity = [_stockFuturesDataArr objectAtIndex:indexPath.row];
            }
            [_delegate followOrderViewDidSelctedHoldDataWithOrderId:entity.orderId];
        }
    }
}
@end

