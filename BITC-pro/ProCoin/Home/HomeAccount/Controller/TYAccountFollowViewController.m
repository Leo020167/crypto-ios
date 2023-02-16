//
//  TYAccountFollowViewController.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/9/4.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYAccountFollowViewController.h"
#import "TYAccountFollowHeaderView.h"
#import "TYAccountFollowInfoCell.h"
#import "PCBaseHoldCoinModel.h"

@interface TYAccountFollowViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) TYAccountFollowHeaderView *headerView;

@property (nonatomic, strong) NSMutableArray *financeArray;

@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);

@property (nonatomic, strong) PCAccountModel *tokenModel;

@property (nonatomic, assign) CGFloat accountHoldCellHeight;

@end

@implementation TYAccountFollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void)initUI{
    self.financeArray = [NSMutableArray array];
    [self.view addSubview:self.tableView];
}

- (void)getData:(PCAccountModel *)model{
    self.tokenModel = model;
    self.headerView.model = model.dvModel;
    [self.financeArray removeAllObjects];
    for(NSDictionary *dic in model.openList){
        PCBaseHoldCoinModel *entity = [[[PCBaseHoldCoinModel alloc] initWithJson:dic] autorelease];
        [self.financeArray addObject:entity];
    }
    self.headerView.bindBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
        if (model.dvModel.dvUid.length) {
            [self putValueToParamDictionary:ProCoinBaseDict value:model.dvModel.dvUid forKey:@"PersonalMainTargetUid"];
            [self pageToViewControllerForName:@"PersonalMainController"];
        }else{
            [self pageToViewControllerForName:@"HomeBigVController"];
        }
    };
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){           //账户信息
        return 1;
    }else if(section == 1){     //财务记录
        return self.financeArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){     //账户信息
        return 210;
    }else if(indexPath.section == 1){   //财务记录
        return self.accountHoldCellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        TYAccountFollowInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TYAccountFollowInfoCell class]) forIndexPath:indexPath];
        if(self.tokenModel == nil)
            return cell;
        cell.followModel = self.tokenModel;
        cell.rateBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
            NSString *localRiskRateDesc = [[NSUserDefaults standardUserDefaults] objectForKey:HomeRiskRateDescLocalKey];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:localRiskRateDesc preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleCancel handler:nil]];
            [QMUIHelper.visibleViewController presentViewController:alertController animated:YES completion:nil];
        };
        return cell;
    }else{
        static NSString *holdCellIdentifier = @"PCBaseAccountHoldCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:holdCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountHoldCell" owner:nil options:nil] lastObject];
        }
        PCBaseHoldCoinModel *entity = self.financeArray[indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 1) {
        PCBaseHoldCoinModel *entity = self.financeArray[indexPath.row];
        [self putValueToParamDictionary:ProCoinBaseDict value:entity.orderId forKey:@"TransactionDetailOrderId"];
        [self pageToViewControllerForName:@"PCTransactionDetailController"];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
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

#pragma mark =========================== 懒加载 ===========================
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight - 50 - kUINormalTabBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColorMakeWithHex(@"#F5F5F5");
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[TYAccountFollowInfoCell class] forCellReuseIdentifier:NSStringFromClass([TYAccountFollowInfoCell class])];
    }
    return _tableView;
}

- (TYAccountFollowHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[TYAccountFollowHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    }
    return _headerView;
}

- (CGFloat)accountHoldCellHeight
{
    if(_accountHoldCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountHoldCell" owner:nil options:nil] lastObject];
        _accountHoldCellHeight = cell.frame.size.height;
    }
    return _accountHoldCellHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.scrollCallback(scrollView);
}

#pragma mark - JXPagingViewListViewDelegate
- (UIScrollView *)listScrollView {
    return self.tableView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.scrollCallback = callback;
}

- (UIView *)listView {
    return self.view;
}

@end
