//
//  LeverageTransactionHeaderView.m
//  BYY
//
//  Created by Hay on 2019/12/24.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "LeverageTransactionHeaderView.h"
#import "LeverageBondView.h"
#import "CommonUtil.h"
#import "TradeUtil.h"
#import "RZButtonMenu.h"

@interface LeverageTransactionHeaderView ()<UITableViewDelegate,UITableViewDataSource,LeverageBondViewDelegate>
{
    CGFloat originHeight;
}

@property (copy, nonatomic) NSString *originSymbol;             //币种
@property (copy, nonatomic) NSString *buySell;                  //1为买，-1为卖
@property (copy, nonatomic) NSArray *bondBalanceArr;            //保证金数组
@property (copy, nonatomic) NSArray *multiNumArr;               //倍数数组
@property (copy, nonatomic) NSString *holdCash;
@property (copy, nonatomic) NSString *holdUsdt;
@property (copy, nonatomic) NSArray *buyDataArr;
@property (copy, nonatomic) NSArray *sellDataArr;
@property (copy, nonatomic) NSString *selectedBondBalance;      //选择的资金
@property (copy, nonatomic) NSString *selectedMultiNum;         //选中的倍数
@property (retain, nonatomic) LeverageCheckOutModel *checkOutModel;


/** 懒加载*/
@property (retain, nonatomic) LeverageBondView *bondSettingView;              //保证金设置view
@property (assign, nonatomic) CGFloat gearDataCellHeight;           //档位cell高度

@property (retain, nonatomic) IBOutlet UIButton *buyButton;         //看涨
@property (retain, nonatomic) IBOutlet UIButton *sellButton;        //看跌
@property (retain, nonatomic) IBOutlet UILabel *availableLabel;     //可用
@property (retain, nonatomic) IBOutlet UIButton *commintButton;     //提交按钮
@property (retain, nonatomic) IBOutlet UIView *bondView;            //保证金view
@property (retain, nonatomic) IBOutlet UITableView *buyTableView;
@property (retain, nonatomic) IBOutlet UITableView *sellTableView;
@property (retain, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (retain, nonatomic) IBOutlet UILabel *currentCashLabel;
@property (retain, nonatomic) IBOutlet UILabel *multiNumLabel;      //倍数Label
@property (retain, nonatomic) IBOutlet UIView *tipsView;
@property (retain, nonatomic) IBOutlet UILabel *tipsLabel;


@end

@implementation LeverageTransactionHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialTransactionHeaderView];
}

- (void)initialTransactionHeaderView
{
    originHeight = self.frame.size.height;
    _buyTableView.delegate = self;
    _buyTableView.dataSource = self;
    _sellTableView.delegate = self;
    _sellTableView.dataSource = self;
    self.selectedMultiNum = nil;
    [self.bondSettingView setFrame:CGRectMake(0,30, SCREEN_WIDTH * 17 /27.0f - 20, 85)];
    [_bondView addSubview:self.bondSettingView];
}

/** 获取当前高度*/
- (CGFloat)currentLeverageTransactionHeaderViewHeight
{
    return self.frame.size.height;
}

- (void)dealloc
{
    [_originSymbol release];
    [_buySell release];
    [_bondBalanceArr release];
    [_multiNumArr release];
    [_holdCash release];
    [_holdUsdt release];
    [_buyDataArr release];
    [_sellDataArr release];
    [_selectedBondBalance release];
    [_selectedMultiNum release];
    [_checkOutModel release];
    [_bondSettingView release];
    [_bondView release];
    [_buyButton release];
    [_sellButton release];
    [_commintButton release];
    [_availableLabel release];
    [_buyTableView release];
    [_sellTableView release];
    [_currentPriceLabel release];
    [_currentCashLabel release];
    [_multiNumLabel release];
    [_tipsView release];
    [_tipsLabel release];
    [super dealloc];
}

#pragma mark - 懒加载
- (LeverageBondView *)bondSettingView
{
    if(!_bondSettingView){
        _bondSettingView = [[[[NSBundle mainBundle] loadNibNamed:@"LeverageBondView" owner:nil options:nil] lastObject] retain];
        _bondSettingView.delegate = self;
    }
    return _bondSettingView;
}

- (CGFloat)gearDataCellHeight
{
    if(_gearDataCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"TransactionGearDataCell" owner:nil options:nil] lastObject];
        _gearDataCellHeight = cell.frame.size.height;
    }
    return _gearDataCellHeight;
}

#pragma mark -按钮点击事件
- (IBAction)operationButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton.selected)
        return;
    targetButton.selected = YES;
    if(targetButton == _buyButton){
        _sellButton.selected = NO;
        self.buySell = LeverageTransactionTypeBuy;
        [self resetHeaderViewBaseUI];
    }else{
        _buyButton.selected = NO;
        self.buySell = LeverageTransactionTypeSell;
        [self resetHeaderViewBaseUI];
    }
    
    if([_delegate respondsToSelector:@selector(buySellButtonDidPressedWithBuySell:)]){
        [_delegate buySellButtonDidPressedWithBuySell:self.buySell];
    }
}

- (IBAction)multiNumButtonPressed:(id)sender
{
    if([self.multiNumArr count] == 0)
        return;
    [[[RZButtonMenu alloc] initRZButtonMenu:self showView:sender menuTitles:self.multiNumArr menuIcon:nil menuFont:[UIFont systemFontOfSize:16] menuFontColor:RGBA(97, 117, 174, 1.0) menuBackgroundColor:RGBA(230, 230, 230, 1.0) menuSegmentingLineColor:RGBA(230, 230, 230, 1.0) menuPlacement:ShowAtBottom] autorelease];

}

- (IBAction)commitButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(commitOrderButtonDidPressedWithBondBalance:buySell:multiNum:)]){
        [_delegate commitOrderButtonDidPressedWithBondBalance:self.selectedBondBalance buySell:self.buySell multiNum:self.selectedMultiNum];
    }
}

#pragma mark - 初始化和更新数据
- (void)initHeaderViewWithBuySell:(NSString *)buySell originSymbol:(NSString *)originSymbol
{
    self.buySell = buySell;
    self.originSymbol = originSymbol;
    
    [self resetHeaderViewBaseUI];
}

- (void)resetHeaderViewBaseUI
{
    if([self.buySell isEqualToString:LeverageTransactionTypeBuy]){         //看涨
        _buyButton.selected = YES;
        _sellButton.selected = NO;
        [_commintButton setTitle:NSLocalizedStringForKey(@"看涨(做多)") forState:UIControlStateNormal];
        [_commintButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(0, 173, 136, 1.0)] forState:UIControlStateNormal];
    }else if([self.buySell isEqualToString:LeverageTransactionTypeSell]){  //看跌
        _buyButton.selected = NO;
        _sellButton.selected = YES;
        [_commintButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(226, 33, 78, 1.0)] forState:UIControlStateNormal];
        [_commintButton setTitle:NSLocalizedStringForKey(@"看跌(做空)") forState:UIControlStateNormal];
    }
    
    [self resetHoldCashOrHoldUsdt];
}

/** 设置checkOut信息*/
- (void)reloadCheckOutInfo:(LeverageCheckOutModel *)checkOutInfo
{
    self.checkOutModel = checkOutInfo;
    if(_checkOutModel.open){
        CGSize size = [CommonUtil getPerfectSizeByText:_checkOutModel.tip andFontSize:14.0f andWidth:SCREEN_WIDTH - 20];
        size.height = MAX(18, size.height);
        CGFloat height = size.height + 12;
        CGRect frame = self.frame;
        frame.size.height = height + originHeight;
        self.frame = frame;
        _tipsLabel.text = _checkOutModel.tip;
    }else{
        CGRect frame = self.frame;
        frame.size.height = originHeight;
        self.frame = frame;
    }
}

/** 设置倍数和保证金*/
- (void)reloadHeaderViewBondBalanceArr:(NSArray *)bondBalanceArr multiNumArr:(NSArray *)multiNumArr
{
    if([bondBalanceArr count] == 0 || [multiNumArr count] == 0)
        return;
    self.bondBalanceArr = bondBalanceArr;
    self.multiNumArr = multiNumArr;
    self.selectedMultiNum = [multiNumArr firstObject];
    self.selectedBondBalance = [bondBalanceArr firstObject];
    _multiNumLabel.text = [NSString stringWithFormat:@"%@X",self.selectedMultiNum];
    [self.bondSettingView reloadLeverageBondData:self.bondBalanceArr];
}

/** 更新可用*/
- (void)reloadHeaderViewHoldCash:(NSString *)holdCash holdUsdt:(NSString *)holdUsdt
{
    self.holdUsdt = holdUsdt;
    self.holdCash = holdCash;
    
    [self resetHoldCashOrHoldUsdt];
}

/** 设置可用数据信息*/
- (void)resetHoldCashOrHoldUsdt
{
    if([self.buySell isEqualToString:LeverageTransactionTypeBuy]){          //买入
        _availableLabel.text = [NSString stringWithFormat:@"%@：%@USDT", NSLocalizedStringForKey(@"可用"), self.holdUsdt];
    }else{
        _availableLabel.text = [NSString stringWithFormat:@"%@：%@USDT", NSLocalizedStringForKey(@"可用"), self.holdUsdt];
    }
}

#pragma mark - 更新档位数据
- (void)realoadGearData:(NSArray *)buyGearData sellGearData:(NSArray *)sellGearData currentQuotation:(CoinQuotationDataEntity *)quotationEntity
{
    self.buyDataArr = buyGearData;
    self.sellDataArr = sellGearData;
    
    [_buyTableView reloadData];
    [_sellTableView reloadData];
    
    _currentPriceLabel.text = quotationEntity.last;
    _currentPriceLabel.textColor = [TradeUtil textColorWithQuotationNumber:quotationEntity.rate.doubleValue];
    _currentCashLabel.text = quotationEntity.lastCny;
}

#pragma mark - table view delegat and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return GearCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.gearDataCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *gearCellIdentifier = @"TransactionGearDataCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:gearCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TransactionGearDataCell" owner:nil options:nil] lastObject];
    }
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:101];
    UIImageView *progressIV = (UIImageView *)[cell viewWithTag:102];
    CoinTradeGearEntity *gearEntity = nil;
    if(tableView == _sellTableView){
        if([_sellDataArr count] < GearCount){
            
            if(indexPath.row < GearCount - [_sellDataArr count]){
                priceLabel.text = @"---";
                amountLabel.text = @"---";
                [CommonUtil viewWidthForAutoLayout:progressIV width:0];
            }else{
                gearEntity = [_sellDataArr objectAtIndex:indexPath.row - (GearCount - [_sellDataArr count])];
                priceLabel.text = gearEntity.price;
                amountLabel.text = gearEntity.amount;
                CGFloat widthProgress = ([gearEntity.depthRate integerValue] / 100.0f) * (SCREEN_WIDTH / 27.0f * 10.0f);
                [CommonUtil viewWidthForAutoLayout:progressIV width:widthProgress];
            }
            
        }else{
            gearEntity = [_sellDataArr objectAtIndex:indexPath.row];
            priceLabel.text = gearEntity.price;
            amountLabel.text = gearEntity.amount;
            CGFloat widthProgress = ([gearEntity.depthRate integerValue] / 100.0f) * (SCREEN_WIDTH / 27.0f * 10.0f);
            [CommonUtil viewWidthForAutoLayout:progressIV width:widthProgress];
        }
        
    }else{
        if(indexPath.row < [_buyDataArr count]){
            gearEntity = [_buyDataArr objectAtIndex:indexPath.row];
            priceLabel.text = gearEntity.price;
            amountLabel.text = gearEntity.amount;
            CGFloat widthProgress = ([gearEntity.depthRate integerValue] / 100.0f) * (SCREEN_WIDTH / 27.0f * 10.0f);
            [CommonUtil viewWidthForAutoLayout:progressIV width:widthProgress];
        }else{
            priceLabel.text = @"---";
            amountLabel.text = @"---";
            [CommonUtil viewWidthForAutoLayout:progressIV width:0];
        }
    }
    return cell;
}

#pragma mark - menu button delegate
- (void)menu:(BaseMenuViewController *)menu didClickedItemUnitWithTag:(NSInteger)tag andItemUnitTitle:(NSString *)title
{
    NSString *multiNum = [self.multiNumArr objectAtIndex:tag];
    _multiNumLabel.text = [NSString stringWithFormat:@"%@X",multiNum];
    self.selectedMultiNum = multiNum;
    if([_delegate respondsToSelector:@selector(multiNumDidSelectedWithMultiNum:)]){
        [_delegate multiNumDidSelectedWithMultiNum:self.selectedMultiNum];
    }
}

#pragma mark - LeverageBondView delegate
- (void)leverageBondBalanceDidChanged:(NSString *)bondBalance
{
    self.selectedBondBalance = bondBalance;
    if([_delegate respondsToSelector:@selector(bondBalanceDidSelectedWithBondBalance:)]){
        [_delegate bondBalanceDidSelectedWithBondBalance:self.selectedBondBalance];
    }
}

@end
