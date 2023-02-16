//
//  QuotationTransactionHeaderView.m
//  Cropyme
//
//  Created by Hay on 2019/6/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "QuotationTransactionHeaderView.h"
#import "CommonUtil.h"
#import "TextFieldToolBar.h"
#import "TradeUtil.h"
#import "PCCoinTransactionMenuView.h"

#define OrderTypeMenuViewTag    1
#define MultiNumMenuViewTag     2




@interface QuotationTransactionHeaderView()<UITableViewDelegate,UITableViewDataSource,TextFieldToolBarDelegate,UITextFieldDelegate,PCCoinTransactionMenuViewDelegate>
{
    CGFloat transactionViewOriginHeight;
    TextFieldToolBar *priceToolBar;
    TextFieldToolBar *amountToolBar;
    
    NSArray<NSString *> *orderTypeTitleArr;            //订单文本类型数组
    NSArray<NSString *> *orderTypeArr;                 //订单类型数组
    
    BOOL isNeedInitPriceTF;         //是否需要更新价格文本
}

@property (assign, nonatomic) CGFloat gearDataCellHeight;           //档位cell高度
@property (copy, nonatomic) NSArray *sellDataArr;            //档位卖出数据
@property (copy, nonatomic) NSArray *buyDataArr;             //档位买入数据
@property (retain, nonatomic) PCTradeConfigModel *configEntity;         //配置变量
@property (retain, nonatomic) PCTradeCheckOutModel *checkOutEntity;     //检查数据变量
@property (retain,  nonatomic) CoinQuotationDataEntity *quotationEnity;            //行情数据
@property (copy, nonatomic) NSString *buySell;          //买卖,1为买，2为卖
@property (copy, nonatomic) NSString *balance;          //成交金额
@property (copy, nonatomic) NSString *usdtRate;                         //usdt汇率,用于计算
@property (copy, nonatomic) NSString *myCoin;                           //我的usdt数量或者其他持币数量
@property (copy, nonatomic) NSString *maxAmount;                        //可用或可卖最大数量
@property (copy, nonatomic) NSString *multiNum;                         //倍数
@property (copy, nonatomic) NSString *orderType;                        //订单类型

@property (retain, nonatomic) IBOutlet UIButton *buyButton;             //买入按钮
@property (retain, nonatomic) IBOutlet UIButton *sellButton;            //卖出按钮
@property (retain, nonatomic) IBOutlet UIButton *operationButton;       //买入卖出按钮
@property (retain, nonatomic) IBOutlet UITableView *sellTableView;      //卖出tableview
@property (retain, nonatomic) IBOutlet UILabel *currentPriceLabel;      //当前价
@property (retain, nonatomic) IBOutlet UILabel *currentCashLabel;       //当前价约等于人民币
@property (retain, nonatomic) IBOutlet UITableView *buyTableView;       //买入tableview
@property (retain, nonatomic) IBOutlet UILabel *orderTypeLabel;         //订单文本，限价/市价委托
@property (retain, nonatomic) IBOutlet UILabel *multiNumLabel;          //倍数文本
@property (retain, nonatomic) IBOutlet UIView *multiNumView;            //倍数页面
@property (retain, nonatomic) IBOutlet UIView *orderTypeView;           //订单类型页面
@property (retain, nonatomic) IBOutlet UIView *inputPriceView;          //输入view
@property (retain, nonatomic) IBOutlet UIView *marketPriceTipsView;     //市价提示view
@property (retain, nonatomic) IBOutlet UIView *amountOptionsView;       //数量选项view
@property (retain, nonatomic) IBOutlet UITextField *priceTF;            //限价输入
@property (retain, nonatomic) IBOutlet UITextField *handAmountTF;       //手数
@property (retain, nonatomic) IBOutlet UILabel *availHandAmountLabel;   //可用手数
@property (retain, nonatomic) IBOutlet UILabel *bondLabel;              //保证金



@end

@implementation QuotationTransactionHeaderView


- (void)awakeFromNib
{
    [super awakeFromNib];
    isNeedInitPriceTF = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    _sellTableView.delegate = self;
    _sellTableView.dataSource = self;
    _buyTableView.delegate = self;
    _buyTableView.dataSource = self;
    _priceTF.delegate = self;
    _handAmountTF.delegate = self;
    priceToolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    amountToolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
    _priceTF.inputAccessoryView = priceToolBar;
    _handAmountTF.inputAccessoryView = amountToolBar;
    transactionViewOriginHeight = self.frame.size.height;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [priceToolBar release];
    [amountToolBar release];
    [orderTypeTitleArr release];
    [orderTypeArr release];
    [_buyDataArr release];
    [_sellDataArr release];
    [_configEntity release];
    [_checkOutEntity release];
    [_quotationEnity release];
    [_buySell release];
    [_balance release];
    [_operationButton release];
    [_buyButton release];
    [_sellButton release];
    [_usdtRate release];
    [_myCoin release];
    [_maxAmount release];
    [_multiNum release];
    [_sellTableView release];
    [_buyTableView release];
    [_currentPriceLabel release];
    [_currentCashLabel release];
    [_orderTypeLabel release];
    [_multiNumLabel release];
    [_multiNumView release];
    [_orderTypeView release];
    [_inputPriceView release];
    [_marketPriceTipsView release];
    [_amountOptionsView release];
    [_priceTF release];
    [_handAmountTF release];
    [_availHandAmountLabel release];
    [_bondLabel release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)gearDataCellHeight
{
    if(_gearDataCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"TransactionGearDataCell" owner:nil options:nil] lastObject];
        _gearDataCellHeight = cell.frame.size.height;
    }
    return _gearDataCellHeight;
}

#pragma mark - 初始化页面数据
- (void)initHeaderViewWithbuySell:(NSString *)buySell
{
    self.buySell = buySell;
    orderTypeTitleArr = [[NSArray alloc] initWithObjects:NSLocalizedStringForKey(@"限价委托"),NSLocalizedStringForKey(@"市价委托"), nil];
    orderTypeArr = [[NSArray alloc] initWithObjects:PCTradeLimitOrderType,PCTradeMarketOrderType, nil];
    self.orderTypeLabel.text = [orderTypeTitleArr lastObject];
    self.orderType = [orderTypeArr lastObject];
    [self resetDefaultUIValue];
    [self orderTypeDidChanged];
}

- (void)initPriceTextField:(NSString *)initPrice
{
    _priceTF.text = initPrice;
    //通知数据更新
    [self viewCoreDataDidChanged];
}

/** 还原控件值*/
- (void)resetDefaultUIValue
{
    if([_buySell isEqualToString:PCQuotationTransactionBuyType]){         //购买
        _buyButton.selected = YES;
        _sellButton.selected = NO;
        [_operationButton setBackgroundImage:[CommonUtil createImageWithColor:[TradeUtil textColorWithQuotationNumber:1.0]] forState:UIControlStateNormal];
        [_operationButton setTitle:NSLocalizedStringForKey(@"看涨(做多)") forState:UIControlStateNormal];
        _inputPriceView.layer.borderColor = RGBA(0, 173, 136, 1.0).CGColor;
    }else{              //出售
        _buyButton.selected = NO;
        _sellButton.selected = YES;
        [_operationButton setBackgroundImage:[CommonUtil createImageWithColor:[TradeUtil textColorWithQuotationNumber:-1.0]] forState:UIControlStateNormal];
        [_operationButton setTitle:NSLocalizedStringForKey(@"看跌(做空)") forState:UIControlStateNormal];
        _inputPriceView.layer.borderColor = RGBA(226, 33, 78, 1.0).CGColor;
    }
    
}

#pragma mark - 更新交易配置
- (void)reloadHeaderViewConfig:(PCTradeConfigModel *)configEntity
{
    self.configEntity = configEntity;
    if([[_configEntity multiNumList] count] > 0){
        self.multiNumLabel.text = [NSString stringWithFormat:@"%@X",[[_configEntity multiNumList] firstObject]];
        self.multiNum = [[_configEntity multiNumList] firstObject];
        //通知发生变化
        [self viewCoreDataDidChanged];
    }
    if ([configEntity.accountType isEqualToString:@"stock"]) {
        self.multiNumView.hidden = YES;
    }
    //更新手数选项
    [self  reloadAmountOptionsView];
}

#pragma mark - 更新手数选项
- (void)reloadAmountOptionsView
{
    if([[_amountOptionsView subviews] count] > 0){
        [[_amountOptionsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    CGFloat unitButtonWidth = (_amountOptionsView.frame.size.width - 30) / 4.0f;
    if([self.configEntity handList] > 0){
        for(int i = 0 ; i < [self.configEntity.handList count]; i++){
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake((unitButtonWidth + 10) * i, 0.0, unitButtonWidth, _amountOptionsView.frame.size.height)];
            button.layer.borderColor = RGBA(97, 117, 174, 1.0).CGColor;
            button.layer.borderWidth = 1.0;
            button.layer.cornerRadius = 3.0;
            [button setTitleColor:RGBA(29, 49, 85, 0.6) forState:UIControlStateNormal];
            [button setTitle:[self.configEntity.handList objectAtIndex:i] forState:UIControlStateNormal];
            [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [button setBackgroundImage:[CommonUtil createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            button.tag = 100 + i;
            [button addTarget:self action:@selector(amountOptionsButonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.amountOptionsView addSubview:button];
        }
    }
}

#pragma mark - 更新档位数据
- (void)realoadGearData:(NSArray *)buyGearData sellGearData:(NSArray *)sellGearData currentQuotation:(CoinQuotationDataEntity *)quotationEntity
{
    self.buyDataArr = buyGearData;
    self.sellDataArr = sellGearData;
    
    [_buyTableView reloadData];
    [_sellTableView reloadData];
    
    if(isNeedInitPriceTF){          //只初始化一次
        isNeedInitPriceTF = NO;
        _priceTF.text = quotationEntity.last;
        //通知数据发生变化
        [self viewCoreDataDidChanged];
    }
    
    _currentPriceLabel.text = quotationEntity.last;
    _currentPriceLabel.textColor = [TradeUtil textColorWithQuotationNumber:quotationEntity.rate.doubleValue];
    _currentCashLabel.text = quotationEntity.lastCny;
}

#pragma mark - transactionHeaderView
- (CGFloat)transactionHeaderViewCurrentHeight
{
    return transactionViewOriginHeight;
}

#pragma mark - 按钮点击事件
- (IBAction)operationButtonPressed:(id)sender
{
    UIButton *targetButton = (UIButton *)sender;
    if(targetButton == _buyButton){
        if(targetButton.isSelected){
            return;
        }
        targetButton.selected = YES;
        _sellButton.selected = NO;
        self.buySell = PCQuotationTransactionBuyType;
        [self resetDefaultUIValue];
    }else{
        if(targetButton.isSelected){
            return;
        }
        targetButton.selected = YES;
        _buyButton.selected = NO;
        self.buySell = PCQuotationTransactionSellType;
        [self resetDefaultUIValue];
    }
    //通知数据发生变化
    [self viewCoreDataDidChanged];
}

/** 订单类型点击事件*/
- (IBAction)orderTypeButtonPressed:(id)sender
{
    PCCoinTransactionMenuView *menuView = [[[PCCoinTransactionMenuView alloc] initTransactionView:self titleArray:orderTypeTitleArr menuUnitSize:CGSizeMake(_orderTypeView.frame.size.width, 40) menuFont:[UIFont systemFontOfSize:14] menuFontColor:RGBA(97, 117, 174, 1.0)] autorelease];
    menuView.view.tag = OrderTypeMenuViewTag;
    [menuView presentInView:_orderTypeView];
}

/** 倍数按钮点击事件*/
- (IBAction)multiNumButtonPressed:(id)sender
{
    if([_configEntity.multiNumList count] > 0){
        NSMutableArray *titleArr = [NSMutableArray array];
        for(NSString *multiNum in _configEntity.multiNumList){
            [titleArr addObject:[NSString stringWithFormat:@"%@X",multiNum]];
        }
        PCCoinTransactionMenuView *menuView = [[[PCCoinTransactionMenuView alloc] initTransactionView:self titleArray:titleArr menuUnitSize:CGSizeMake(_multiNumView.frame.size.width, 40) menuFont:[UIFont systemFontOfSize:14] menuFontColor:RGBA(97, 117, 174, 1.0)] autorelease];
        menuView.view.tag = MultiNumMenuViewTag;
        [menuView presentInView:_multiNumView];
    }
    
}

/** 提交订单按钮点击*/
- (IBAction)commitOrderButtonPressed:(id)sender
{
    [_priceTF resignFirstResponder];
    [_handAmountTF resignFirstResponder];
    if([_delegate respondsToSelector:@selector(commitOrderButtonPressedOrderType:inputPrice:handAmount:multiNum:buySell:openBond:)]){
        if([_orderType isEqualToString:PCTradeLimitOrderType]){
            [_delegate commitOrderButtonPressedOrderType:self.orderType inputPrice:_priceTF.text handAmount:_handAmountTF.text multiNum:self.multiNum buySell:self.buySell openBond:self.checkOutEntity.openBail];
        }else{      //后端逻辑，当市场时必须返回0的价格
            [_delegate commitOrderButtonPressedOrderType:self.orderType inputPrice:@"0" handAmount:_handAmountTF.text multiNum:self.multiNum buySell:self.buySell openBond:self.checkOutEntity.openBail];
        }

    }
}

/** 手数选项点击事件*/
- (void)amountOptionsButonPressed:(UIButton *)sender
{
    NSInteger tag = sender.tag - 100;
    _handAmountTF.text = [self.configEntity.handList objectAtIndex:tag];
    //通知发生了变化
    [self viewCoreDataDidChanged];
}

/** 减号按钮点击事件*/
- (IBAction)minusButtonPressed:(id)sender
{
    if([_priceTF.text doubleValue] <= 0 || !checkIsStringWithAnyText(_priceTF.text)){
        _priceTF.text = @"0";
        return;
    }
    
    if(self.configEntity != nil){
        NSDecimalNumber *decimalNum = [NSDecimalNumber decimalNumberWithString:@"10"];
        NSDecimalNumber *result = [decimalNum decimalNumberByRaisingToPower:self.configEntity.priceDecimals];
        CGFloat value = [result integerValue];
        CGFloat minValue = (CGFloat)1.0 / value;
        NSString *format = [NSString stringWithFormat:@"%%.%@f",@(self.configEntity.priceDecimals)];
        _priceTF.text = [NSString stringWithFormat:format,[_priceTF.text doubleValue] - minValue];
    }
}

/** 加号按钮点击事件*/
- (IBAction)plusButtonPressed:(id)sender
{
    if(!checkIsStringWithAnyText(_priceTF.text)){
        _priceTF.text = @"0";
    }
    if(self.configEntity != nil){
        NSDecimalNumber *decimalNum = [NSDecimalNumber decimalNumberWithString:@"10"];
        NSDecimalNumber *result = [decimalNum decimalNumberByRaisingToPower:self.configEntity.priceDecimals];
        CGFloat value = [result integerValue];
        CGFloat minValue = (CGFloat)1.0 / value;
        NSString *format = [NSString stringWithFormat:@"%%.%@f",@(self.configEntity.priceDecimals)];
        _priceTF.text = [NSString stringWithFormat:format,[_priceTF.text doubleValue] + minValue];
    }
}

- (IBAction)transferCoinButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(transactionHeaderViewTransferCoinButtonDidPressed)]){
        [_delegate transactionHeaderViewTransferCoinButtonDidPressed];
    }
}


#pragma mark - 更新计算数据
- (void)reloadCheckOutData:(PCTradeCheckOutModel *)checkOutEntity
{
    self.checkOutEntity = checkOutEntity;
    _availHandAmountLabel.text = [NSString stringWithFormat:NSLocalizedStringForKey(@"可开%@手"),checkOutEntity.maxHand];
    _bondLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringForKey(@"开仓保证金"), checkOutEntity.openBail];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(tableView == _buyTableView){             //买入档
        if(indexPath.row < [_buyDataArr count]){
            CoinTradeGearEntity *gearEntity = [_buyDataArr objectAtIndex:indexPath.row];
            _priceTF.text = gearEntity.price;
        }
        
    }else{                      //卖出档
        if([_sellDataArr count] < GearCount){
            if(indexPath.row >= GearCount - [_sellDataArr count]){
                CoinTradeGearEntity *gearEntity = [_sellDataArr objectAtIndex:indexPath.row - (GearCount - [_sellDataArr count])];
                _priceTF.text = gearEntity.price;
            }
        }else{
            CoinTradeGearEntity *gearEntity = [_sellDataArr objectAtIndex:indexPath.row];
            _priceTF.text = gearEntity.price;
        }
        
    }
    [self TFDonePressed];
}

#pragma mark - text field tool bar delegate
- (void)TFDonePressed
{
    if([_priceTF isFirstResponder]){
        [_priceTF resignFirstResponder];
    }
    
    if([_handAmountTF isFirstResponder]){
        [_handAmountTF resignFirstResponder];
    }

    //通知发生了变化
    [self viewCoreDataDidChanged];
}

#pragma mark - 状态类型价格和数量发生改变
- (void)viewCoreDataDidChanged
{
    if([_delegate respondsToSelector:@selector(transactionHeaderViewDidChangedOrderType:inputPrice:handAmount:multiNum:buySell:)]){
        if([_orderType isEqualToString:PCTradeLimitOrderType]){
           [_delegate transactionHeaderViewDidChangedOrderType:self.orderType inputPrice:_priceTF.text handAmount:_handAmountTF.text multiNum:self.multiNum buySell:self.buySell];
        }else{      //后端逻辑，当市场时必须返回0的价格
            [_delegate transactionHeaderViewDidChangedOrderType:self.orderType inputPrice:@"0" handAmount:_handAmountTF.text multiNum:self.multiNum buySell:self.buySell];
        }
        
    }
}

#pragma mark - text field delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL success = YES;
    if(textField == _priceTF && self.configEntity != nil){
        success = [CommonUtil limitPayMoneyDot:textField shouldChangeCharactersInRange:range replacementString:string dotPreBits:7 dotAfterBits:self.configEntity.priceDecimals];
    }
    return success;
}

#pragma mark - 输入文本框文字改变事件
- (void)textFieldTextDidChanged:(NSNotification *)notification
{
    [self viewCoreDataDidChanged];
}


#pragma  mark - 弹下键盘
- (void)inputTextResignFirstResponder
{
    if([_priceTF isFirstResponder] || [_handAmountTF isFirstResponder]){
       [self TFDonePressed];
    }
    
}

#pragma mark - 订单模式发生改变
- (void)orderTypeDidChanged
{
    if([self.orderType isEqualToString:PCTradeLimitOrderType]){        //限价
        _inputPriceView.hidden = NO;
        _marketPriceTipsView.hidden = YES;
    }else{      //市价
        _inputPriceView.hidden = YES;
        _marketPriceTipsView.hidden = NO;
    }
}

#pragma mark - PCCoinTransactionMenuViewDelegate
- (void)menuViewDidClick:(UIView *)menuView row:(NSInteger)row unitTitle:(NSString *)title
{
    if(menuView.tag == OrderTypeMenuViewTag){
        self.orderTypeLabel.text = title;
        self.orderType = [orderTypeArr objectAtIndex:row];
        [self orderTypeDidChanged];
        //通知数据发生变化
        [self viewCoreDataDidChanged];
    }else if(menuView.tag == MultiNumMenuViewTag){
        self.multiNumLabel.text = title;
        self.multiNum = [_configEntity.multiNumList objectAtIndex:row];
        //通知数据发生变化
        [self viewCoreDataDidChanged];
    }
    

}
@end
