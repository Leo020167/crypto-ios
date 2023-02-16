//
//  SegmentHoldCoinVC.m
//  Cropyme
//
//  Created by Hay on 2019/7/20.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "PCSegmentDigitalVC.h"
#import "TradeUtil.h"
#import "LewPopupViewAnimationSpring.h"

#define UserHiddenMinHoldCoinSetting        @"UserHiddenMinHoldCoinSetting"

@interface PCSegmentDigitalVC ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *tableData;          //持仓数据
}

/** 变量*/
@property (retain, nonatomic) PCAccountModel *accountInfoEntity;

/** 懒加载*/
@property (assign, nonatomic) CGFloat digitalInfoCellHeight;        //数字货币账户信息高度
@property (assign, nonatomic) CGFloat digitalHoldCellHeight;        //持仓cell高度


@end

@implementation PCSegmentDigitalVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    tableData = [[NSMutableArray alloc] init];
    _digitalCoinTableView.delegate = self;
    _digitalCoinTableView.dataSource = self;
    
    //reloadData 视图漂移或者闪动解决方法
    _digitalCoinTableView.estimatedRowHeight = 0;
    _digitalCoinTableView.estimatedSectionHeaderHeight = 0;
    _digitalCoinTableView.estimatedSectionFooterHeight = 0;
    
}

- (void)dealloc
{
    [_digitalCoinTableView release];
    [tableData release];
    [_accountInfoEntity release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (void)questionButtonPressed:(UIButton *)sender
{
    if([_delegate respondsToSelector:@selector(digitalRiskQuestionButtonDidPressed)]){
        [_delegate digitalRiskQuestionButtonDidPressed];
    }
}

#pragma mark - 懒加载
- (CGFloat)digitalInfoCellHeight
{
    if(_digitalInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountInfoCell" owner:nil options:nil] lastObject];
        _digitalInfoCellHeight = cell.frame.size.height;
    }
    return _digitalInfoCellHeight;
}

- (CGFloat)digitalHoldCellHeight
{
    if(_digitalHoldCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountHoldCell" owner:nil options:nil] lastObject];
        _digitalHoldCellHeight = cell.frame.size.height;
    }
    return _digitalHoldCellHeight;
}

#pragma mark - 更新数据
- (void)reloadDigitalAccountInfo:(PCAccountModel *)accountEntity accountHoldData:(NSArray *)dataArr
{
    self.accountInfoEntity = accountEntity;
    [tableData removeAllObjects];
    [tableData addObjectsFromArray:dataArr];
    
    [_digitalCoinTableView reloadData];
}

#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){           //顶部信息
        return 1;
    }else if(section == 1){     //持仓数据
        return [tableData count];
    }
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){         //顶部信息
        return self.digitalInfoCellHeight;
    }else if(indexPath.section == 1){
        return self.digitalHoldCellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *holdCellIdentifier = @"PCBaseAccountHoldCellIdentifier";
    if(indexPath.section == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountInfoCell" owner:nil options:nil] lastObject];
        UILabel *accountLabel = (UILabel *)[cell viewWithTag:107];
        accountLabel.text = NSLocalizedStringForKey(@"数字货币总资产(USDT)");
        if(_accountInfoEntity == nil){
            return cell;
        }
        UILabel *assetsLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *cnyLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *riskLabel = (UILabel *)[cell viewWithTag:102];
        UILabel *eableLabel = (UILabel *)[cell viewWithTag:103];
        UILabel *profitLabel = (UILabel *)[cell viewWithTag:104];
        UILabel *openBailLabel = (UILabel *)[cell viewWithTag:105];
        UILabel *frozenBailLabel = (UILabel *)[cell viewWithTag:106];
        UIButton *questionButton = (UIButton *)[cell viewWithTag:500];
        [questionButton addTarget:self action:@selector(questionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        assetsLabel.text = _accountInfoEntity.assets;
        cnyLabel.text = _accountInfoEntity.assetsCny;
        riskLabel.text = [NSString stringWithFormat:@"%@%%",_accountInfoEntity.riskRate];
        eableLabel.text = _accountInfoEntity.eableBail;
        profitLabel.text = [TradeUtil stringByAppendingPlusSymbolString:_accountInfoEntity.profit];
        profitLabel.textColor = [TradeUtil textColorWithQuotationNumber:[_accountInfoEntity.profit doubleValue]];
        openBailLabel.text = _accountInfoEntity.openBail;
        frozenBailLabel.text = _accountInfoEntity.frozenBail;
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:holdCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PCBaseAccountHoldCell" owner:nil options:nil] lastObject];
        }
        PCBaseHoldCoinModel *entity = [tableData objectAtIndex:indexPath.row];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1){
        if([_delegate respondsToSelector:@selector(digitalCoinTableViewDidSelectedCellWithIndexPath:)]){
            [_delegate digitalCoinTableViewDidSelectedCellWithIndexPath:indexPath];
        }
    }

}
@end
