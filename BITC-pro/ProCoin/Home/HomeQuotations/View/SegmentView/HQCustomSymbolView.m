//
//  HQCustomSymbolView.m
//  BYY
//
//  Created by Hay on 2019/10/22.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "HQCustomSymbolView.h"
#import "QuotationCoinBaseEntity.h"
#import "TradeUtil.h"


@interface HQCustomSymbolView()<UITableViewDelegate,UITableViewDataSource,HomeQuotationSortHeaderViewDelegate>

@property (copy, nonatomic) NSArray *tableData;
@property (retain, nonatomic) UITableView *symbolTableView;

/** 懒加载 */
@property (retain, nonatomic) UIView *loginView;           //需要登录页面
@property (retain, nonatomic) UIView *noDataView;          //没数据页面
@property (assign, nonatomic) CGFloat symbolDataCellHeight;             //cell高度
@property (retain, nonatomic) HomeQuotationsSortHeaderView *sortHeaderView;         //排序headerView


@end

@implementation HQCustomSymbolView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self  initialCustomSymbolView];
    }
    return self;
}

- (void)dealloc
{
    [_tableData release];
    [_symbolTableView release];
    [_loginView release];
    [_noDataView release];
    [_sortHeaderView release];
    [super dealloc];
}

- (void)initialCustomSymbolView
{
    self.backgroundColor = [UIColor whiteColor];
    self.symbolTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)] autorelease];
    self.symbolTableView.backgroundColor = [UIColor whiteColor];
    _symbolTableView.delegate = self;
    _symbolTableView.dataSource = self;
    [_symbolTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _symbolTableView.tableHeaderView = self.sortHeaderView;
    [self addSubview:_symbolTableView];
    
    self.loginView.hidden = YES;
    [self addSubview:self.loginView];
    self.noDataView.hidden = YES;
    [self addSubview:self.noDataView];
}

#pragma mark - 懒加载
- (UIView *)loginView
{
    if(!_loginView){
        _loginView = [[UIView alloc] initWithFrame:CGRectMake(15, (self.frame.size.height - 100) / 2.0f - 10, self.frame.size.width - 15 * 2, 100)];
        UILabel *tipsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 10, _loginView.frame.size.width, 32)] autorelease];
        [tipsLabel setTextAlignment:NSTextAlignmentCenter];
        tipsLabel.textColor = RGBA(29, 48, 85, 0.4);
        tipsLabel.font = [UIFont systemFontOfSize:14.0f];
        tipsLabel.text = NSLocalizedStringForKey(@"登录后可以关注自己喜欢的自选");
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginButton setFrame:CGRectMake((_loginView.frame.size.width - 70) / 2.0f, 50, 70, 36)];
        [loginButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginButton setBackgroundColor:RGBA(97, 117, 174, 1.0)];
        [loginButton setTitle:NSLocalizedStringForKey(@"登录") forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(loginButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_loginView addSubview:tipsLabel];
        [_loginView addSubview:loginButton];
    }
    return _loginView;
}

- (UIView *)noDataView
{
    if(!_noDataView){
        CGFloat noDataViewWidth = 240;
        CGFloat noDataViewHeight = 220;
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - noDataViewWidth)/2.0f, (self.frame.size.height - noDataViewHeight)/2.0f, noDataViewWidth, noDataViewHeight)];
        _noDataView.backgroundColor = [UIColor clearColor];
        UIImageView *logoIV = [[[UIImageView alloc] initWithFrame:CGRectMake((noDataViewWidth - 176)/2.0f, 0.0, 179, 176)] autorelease];
        logoIV.contentMode = UIViewContentModeScaleAspectFill;
        logoIV.image = [UIImage imageNamed:@"home_follow_bg_no_data"];
        UILabel *tipsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, logoIV.frame.size.height + 10, noDataViewWidth, 21)] autorelease];
        tipsLabel.text = NSLocalizedStringForKey(@"暂无关注的自选");
        tipsLabel.textColor = RGBA(29, 49, 85, 0.4);
        tipsLabel.font = [UIFont systemFontOfSize:14.0f];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:logoIV];
        [_noDataView addSubview:tipsLabel];
    }
    return _noDataView;
}

- (CGFloat)symbolDataCellHeight
{
    if(_symbolDataCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeQuotationsCoinCell" owner:nil options:nil] lastObject];
        _symbolDataCellHeight = cell.frame.size.height;
    }
    return _symbolDataCellHeight;
}

- (HomeQuotationsSortHeaderView *)sortHeaderView
{
    if(!_sortHeaderView){
        _sortHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"HomeQuotationsSortHeaderView" owner:nil options:nil] lastObject] retain];
        _sortHeaderView.delegate = self;
    }
    return _sortHeaderView;
}


#pragma mark - 按钮点击事件
- (void)loginButtonDidPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(customSymbolViewLoginButtonPressed)]){
        [_delegate customSymbolViewLoginButtonPressed];
    }
}

#pragma mark - 加载数据
/** 未登录数据 */
- (void)customSymbolViewDidNotLoginData
{
    self.loginView.hidden = NO;
    self.noDataView.hidden = YES;
    _symbolTableView.hidden = YES;
}

/** 重新加载数据 */
- (void)reloadCustomSymbolViewData:(NSArray *)dataArr
{
    if(!_loginView.hidden){
        _loginView.hidden = YES;
    }
    
    if([dataArr count] == 0){
        if(!_symbolTableView.hidden){
            _symbolTableView.hidden = YES;
        }
        if(_noDataView.hidden){
            _noDataView.hidden = NO;
        }
    }else{
        if(_symbolTableView.hidden){
            _symbolTableView.hidden = NO;
        }
        if(!_noDataView.hidden){
            _noDataView.hidden = YES;
        }
    }
    
    self.tableData = dataArr;
    [_symbolTableView reloadData];
    
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.symbolDataCellHeight;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *customSymbolCellIdentifier = @"HomeQuotationsCoinCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:customSymbolCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"HomeQuotationsCoinCell" owner:nil options:nil] lastObject];
    }
    QuotationCoinBaseEntity *entity = [_tableData objectAtIndex:indexPath.row];
    UILabel *symbolLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:104];
    UILabel *rateLabel = (UILabel *)[cell viewWithTag:103];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:102];
    UIView *priceView = (UIView *)[cell viewWithTag:105];
    UILabel *tipsLabel = (UILabel *)[cell viewWithTag:106];
    
    NSRange symbolRange = [entity.symbol rangeOfString:@"/"];
    NSMutableAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:entity.symbol] autorelease];
    if(symbolRange.location != NSNotFound){
        [string addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0f],NSForegroundColorAttributeName:RGBA(97, 117, 174, 0.4)} range:NSMakeRange(symbolRange.location, entity.symbol.length - symbolRange.location)];
    }
    symbolLabel.attributedText = string;
    
    
    priceLabel.text = entity.price;
    nameLabel.text = entity.name;
    rateLabel.text = [NSString stringWithFormat:@"%@%%",[TradeUtil stringByAppendingPlusSymbolString:entity.rate]];
    priceView.backgroundColor = [TradeUtil textColorWithQuotationNumber:entity.rate.floatValue];
    amountLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedStringForKey(@"量"), entity.amount];
    if(checkIsStringWithAnyText(entity.tip)){
        tipsLabel.hidden = NO;
        tipsLabel.text = entity.tip;
    }else{
        tipsLabel.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QuotationCoinBaseEntity *entity = [_tableData objectAtIndex:indexPath.row];
    if([_delegate respondsToSelector:@selector(customSymbolViewSymbolDidSelected:originSymbol:marketType:)]){
        [_delegate customSymbolViewSymbolDidSelected:entity.symbol originSymbol:entity.originSymbol marketType:entity.marketType];
    }
}

#pragma mark - HomeQuotationSortHeaderViewDelegate   (排序回调)
- (void)sortHeaderView:(UIView *)sortView sortField:(NSString *)field sortState:(SortButtonState)state
{
    if([_delegate respondsToSelector:@selector(customSymbolViewSortButtonDidSelectedWithSortField:sortState:)]){
        [_delegate customSymbolViewSortButtonDidSelectedWithSortField:field sortState:[NSString stringWithFormat:@"%@",@(state)]];
    }
}

- (SortButtonState)customSymbolViewCurrentSortState
{
    return [self.sortHeaderView currentSortState];
}

- (NSString *)customSymbolViewCurrentSortField
{
    return [self.sortHeaderView currentSortField];
}

@end
