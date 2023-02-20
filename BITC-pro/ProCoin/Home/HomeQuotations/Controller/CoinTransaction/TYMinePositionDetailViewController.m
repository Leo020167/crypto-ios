//
//  TYMinePositionDetailViewController.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/8/22.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYMinePositionDetailViewController.h"
#import "TYMineTransactionDetailDefaultCell.h"
#import "VeDateUtil.h"
#import "PCTransactionStopWinLossSettingView.h"
#import "TradeUtil.h"
#import "TYMinePositionModel.h"

@interface TYMinePositionDetailViewController ()<UITableViewDelegate, UITableViewDataSource, PCTransactionStopWinLossSettingViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UILabel *rateLabel;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) TYMinePositionModel *model;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, copy) NSString *limitPrice;

@property (nonatomic, strong) UIView *settingView;

@property (nonatomic, strong) UITextField *priceTextField;

@property (nonatomic, strong) UITextField *amountTextField;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, assign) CGFloat currentPriceCellHeight;

@end

@implementation TYMinePositionDetailViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [self setNav];
    
    [self initUI];
}

- (void)setNav{
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kUINormalNavBarHeight)];
    [self.view addSubview:navView];
    navView.backgroundColor = UIColor.whiteColor;

    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kUIStatusBarHeight, 44, 44)];
    [backBtn setImage:UIImageMake(@"btn_back_black") forState:0];
    backBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
        [self.navigationController popViewControllerAnimated:YES];
    };
    [navView addSubview:backBtn];

    UILabel *titleLabel = [[UILabel alloc] init];
    self.titleLabel = titleLabel;
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.font = UIFontMake(17);
    [navView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(navView);
        make.top.mas_equalTo(kUIStatusBarHeight);
        make.height.mas_equalTo(44);
    }];
}

- (void)initUI{
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(60);
    }];
}

- (void)getData{
    [YYRequestUtility Post:@"pro/order/detail.do" addParameters:@{@"symbol" : self.symbol} progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            TYMinePositionModel *model = [TYMinePositionModel yy_modelWithDictionary:responseDict[@"data"][@"data"]];
            self.model = model;
            self.titleLabel.text = self.model.symbol;
            self.priceLabel.text = self.model.profit;
            self.priceLabel.textColor = [TradeUtil textColorWithQuotationNumber:self.model.profit.doubleValue];
            self.rateLabel.text = [NSString stringWithFormat:@"%@%@", self.model.profitRate, @"%"];
            self.rateLabel.textColor = [TradeUtil textColorWithQuotationNumber:self.model.profit.doubleValue];
            [self.tableView reloadData];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)btnAction{
    [self.view addSubview:self.settingView];
    
//    PCTransactionStopWinLossSettingView *settingView = (PCTransactionStopWinLossSettingView *)[[[NSBundle mainBundle] loadNibNamed:@"PCTransactionStopWinLossSettingView" owner:nil options:nil] lastObject];
//    settingView.delegate = self;
////    settingView.priceDecimals = _detailEntity.priceDecimals;
//    [settingView showViewInView:self.view settingType:PCTDStopWinType];
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-keyboardRect.size.height - kUINormalBottomSafeDistance);
    }];
//    [self.bgView layoutIfNeeded];
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
    } completion:^(BOOL finished) {
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
        }];
    }];
    
}

- (void)sureBtnAction{
    if (!self.priceTextField.text.length) {
        [QMUITips showError:NSLocalizedStringForKey(@"请输入价格")];
        return;
    }
    if (!self.amountTextField.text.length) {
        [QMUITips showError:NSLocalizedStringForKey(@"请输入数量")];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"确定要设置当前价格和数量吗？") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [YYRequestUtility Post:@"pro/order/open.do" addParameters:@{@"symbol" : self.model.symbol, @"buySell" : @"sell", @"type" : @"2", @"price" : self.priceTextField.text, @"hand" : self.amountTextField.text, @"orderType" : @"limit"} progress:nil success:^(NSDictionary *responseDict) {
            if ([responseDict[@"code"] intValue] == 200) {
                NSString *msg = [NSString stringWithFormat:@"%@",[responseDict objectForKey:@"msg"]];
                if(!checkIsStringWithAnyText(msg)){
                    msg = NSLocalizedStringForKey(@"Successful operation");
                }
                [UIView animateWithDuration:1 animations:^{
                    self.priceTextField.text = @"";
                    self.amountTextField.text = @"";
                    [self.settingView removeFromSuperview];
                }];
                [QMUITips showSucceed:msg];
                [self getData];
            }else{
                [QMUITips showError:responseDict[@"msg"]];
            }
        } failure:^(NSError *error) {
        }];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (CGFloat)currentPriceCellHeight
{
    if(_currentPriceCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCTDCurrentPriceCell" owner:nil options:nil] lastObject];
        _currentPriceCellHeight = cell.frame.size.height;
    }
    return _currentPriceCellHeight;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2) {
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCTDCurrentPriceCell" owner:nil options:nil] lastObject];
        UILabel *symbolLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *currentPriceLabel = (UILabel *)[cell viewWithTag:101];
        UIImageView *stateIV = (UIImageView *)[cell viewWithTag:102];
        symbolLabel.text = [NSString stringWithFormat:@"%@%@",self.model.symbol, NSLocalizedStringForKey(@"现价")];
        currentPriceLabel.text = [NSString stringWithFormat:@"%@ %@%%",self.model.last,[TradeUtil stringByAppendingPlusSymbolString:self.model.rate]];
        currentPriceLabel.textColor = [TradeUtil textColorWithQuotationNumber:[self.model.rate doubleValue]];
        if([self.model.rate doubleValue] >= 0){
            stateIV.image = [UIImage imageNamed:@"leverage_icon_rise"];
        }else{
            stateIV.image = [UIImage imageNamed:@"leverage_icon_down"];
        }
        return cell;
    }
    TYMineTransactionDetailDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYMineTransactionDetailDefaultCell class]) forIndexPath:indexPath];
    cell.settingBtn.hidden = YES;
    cell.descBtn.hidden = YES;
    cell.descLabel.hidden = NO;
    cell.descLabel.textColor = UIColorMakeWithHex(@"#000000");
    if (indexPath.row == 0) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"成本");
        cell.descLabel.text = self.model.price;
    }else if (indexPath.row == 1) {
        cell.titleLabel.text = NSLocalizedStringForKey(@"数量/可用");
        cell.descLabel.text = [NSString stringWithFormat:@"%@/%@", self.model.amount, self.model.availableAmount];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row == 2 ? self.currentPriceCellHeight : 35;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 2) {
        [self putValueToParamDictionary:@"CoinTradeDic" value:self.model.symbol forKey:@"CoinQuotationsDetailSymbol"];
        [self pageToViewControllerForName:@"CoinQuotationsDetailController"];
    }
}

#pragma mark =========================== 懒加载 ===========================
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight - 60)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColor.clearColor;
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = self.footerView;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TYMineTransactionDetailDefaultCell class] forCellReuseIdentifier:NSStringFromClass([TYMineTransactionDetailDefaultCell class])];
    }
    return _tableView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = UIColorMakeWithHex(@"2B4166");
        titleLabel.font = UIFontMake(15);
        titleLabel.text = NSLocalizedStringForKey(@"盈利USDT");
        [_headerView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15);
            make.centerX.mas_equalTo(self.headerView);
        }];
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.textColor = UIColor.blackColor;
        priceLabel.font = UIFontBoldMake(17);
        self.priceLabel = priceLabel;
        [_headerView addSubview:priceLabel];
        [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.headerView);
        }];
        
        UILabel *rateLabel = [[UILabel alloc] init];
        rateLabel.textColor = UIColor.blackColor;
        rateLabel.font = UIFontMake(15);
        self.rateLabel = rateLabel;
        [_headerView addSubview:rateLabel];
        [rateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-15);
            make.centerX.mas_equalTo(self.headerView);
        }];
    }
    return _headerView;
}

- (UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
        
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:NSLocalizedStringForKey(@"设置止盈止损") forState:0];
        [btn setTitleColor:UIColor.whiteColor forState:0];
        btn.titleLabel.font = UIFontMake(15);
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = UIColorMakeWithHex(@"#7889B8");
        [_footerView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.footerView);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - 30, 40));
        }];
    }
    return _footerView;
}

- (UIView *)settingView{
    if (!_settingView) {
        _settingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _settingView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.2];
    
        UIButton *tapBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 200)];
        tapBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
            [UIView animateWithDuration:1 animations:^{
                self.priceTextField.text = @"";
                self.amountTextField.text = @"";
                [self.settingView removeFromSuperview];
            }];
        };
        [_settingView addSubview:tapBtn];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
        self.bgView = bgView;
        bgView.backgroundColor = UIColor.whiteColor;
        [_settingView addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(200);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 40)];
        titleLabel.textColor = UIColorMakeWithHex(@"#333333");
        titleLabel.text = NSLocalizedStringForKey(@"设置止盈止损");
        titleLabel.font = UIFontMake(15);
        [bgView addSubview:titleLabel];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 40)];
        priceLabel.textColor = UIColorMakeWithHex(@"#333333");
        priceLabel.text = NSLocalizedStringForKey(@"价格");
        priceLabel.font = UIFontMake(17);
        [bgView addSubview:priceLabel];
        [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
        }];
        
        UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 40)];
        amountLabel.textColor = UIColorMakeWithHex(@"#333333");
        amountLabel.text = NSLocalizedStringForKey(@"数量");
        amountLabel.font = UIFontMake(17);
        [bgView addSubview:amountLabel];
        [amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(priceLabel.mas_bottom).offset(10);
        }];
        
        UITextField *priceTextField = [[UITextField alloc] init];
        self.priceTextField = priceTextField;
        priceTextField.textColor = UIColorMakeWithHex(@"#333333");
        priceTextField.placeholder = NSLocalizedStringForKey(@"请输入价格");
        priceTextField.font = UIFontMake(15);
        priceTextField.keyboardType = UIKeyboardTypeDecimalPad;
        [bgView addSubview:priceTextField];
        [priceTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(priceLabel.mas_right).offset(15);
            make.centerY.mas_equalTo(priceLabel);
            make.height.mas_equalTo(40);
            make.width.mas_equalTo(200);
        }];
        
        UITextField *amountTextField = [[UITextField alloc] init];
        self.amountTextField = amountTextField;
        amountTextField.textColor = UIColorMakeWithHex(@"#333333");
        amountTextField.placeholder = NSLocalizedStringForKey(@"请输入数量");
        amountTextField.font = UIFontMake(15);
        amountTextField.keyboardType = UIKeyboardTypeDecimalPad;
        [bgView addSubview:amountTextField];
        [amountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(amountLabel.mas_right).offset(15);
            make.centerY.mas_equalTo(amountLabel);
            make.height.mas_equalTo(40);
            make.width.mas_equalTo(200);
        }];
        
        UIButton *sureBtn = [[UIButton alloc] init];
        [sureBtn setTitle:NSLocalizedStringForKey(@"确定") forState:0];
        [sureBtn setTitleColor:UIColor.whiteColor forState:0];
        sureBtn.titleLabel.font = UIFontMake(15);
        sureBtn.layer.cornerRadius = 5;
        sureBtn.layer.masksToBounds = YES;
        [sureBtn addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
        sureBtn.backgroundColor = UIColorMakeWithHex(@"#7889B8");
        [bgView addSubview:sureBtn];
        [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(bgView);
            make.top.mas_equalTo(amountTextField.mas_bottom).offset(25);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - 30, 40));
        }];
    }
    return _settingView;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        
        UIButton *buyBtn = [[UIButton alloc] init];
        [buyBtn setTitle:NSLocalizedStringForKey(@"买入") forState:0];
        [buyBtn setTitleColor:UIColor.whiteColor forState:0];
        buyBtn.titleLabel.font = UIFontMake(15);
        buyBtn.layer.cornerRadius = 5;
        buyBtn.layer.masksToBounds = YES;
        buyBtn.backgroundColor = QuotationGreenColor;
        buyBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
            [self putValueToParamDictionary:CoinTradeDic value:_symbol forKey:@"CoinTransactionSymbol"];
            [self putValueToParamDictionary:CoinTradeDic value:@"1" forKey:@"CoinTransactionBuySell"];
            [self pageToViewControllerForName:@"TYCoinTransactionController"];
        };
        [_bottomView addSubview:buyBtn];
        [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(10);
            make.size.mas_equalTo(CGSizeMake((SCREEN_WIDTH - 40) / 2.0, 40));
        }];
        
        UIButton *sellBtn = [[UIButton alloc] init];
        [sellBtn setTitle:NSLocalizedStringForKey(@"卖出") forState:0];
        [sellBtn setTitleColor:UIColor.whiteColor forState:0];
        sellBtn.titleLabel.font = UIFontMake(15);
        sellBtn.layer.cornerRadius = 5;
        sellBtn.layer.masksToBounds = YES;
        sellBtn.backgroundColor = QuotationRedColor;
        sellBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
            [self putValueToParamDictionary:CoinTradeDic value:_symbol forKey:@"CoinTransactionSymbol"];
            [self putValueToParamDictionary:CoinTradeDic value:@"-1" forKey:@"CoinTransactionBuySell"];
            [self pageToViewControllerForName:@"TYCoinTransactionController"];
        };
        [_bottomView addSubview:sellBtn];
        [sellBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.top.mas_equalTo(10);
            make.size.mas_equalTo(CGSizeMake((SCREEN_WIDTH - 40) / 2.0, 40));
        }];
    }
    return _bottomView;
}


@end
