//
//  SearchCoinController.m
//  Cropyme
//
//  Created by Hay on 2019/8/28.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "SearchCoinController.h"
#import "NetWorkManage+Trade.h"
#import "SearchCoinDataEntity.h"
#import "CommonUtil.h"
#import "SearchCoinSQL.h"

@interface SearchCoinController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    BOOL isEdit;            //是否正在编辑
    NSMutableArray<SearchCoinDataEntity *> *searchArray;
    NSMutableArray<SearchCoinDataEntity *> *historyArray;
}
/** 懒加载*/
@property (assign, nonatomic) CGFloat SearchDataCellHeight;
@property (assign, nonatomic) CGFloat SearchDataNoDataCellHeight;

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UITableView *tvSearch;
@property (retain, nonatomic) IBOutlet UIView *headerView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *tvSearchLayoutConstraintBottom;

@end

@implementation SearchCoinController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isEdit = NO;
    searchArray = [[NSMutableArray alloc] init];
    historyArray = [[NSMutableArray alloc] init];
    _tvSearch.delegate = self;
    _tvSearch.dataSource = self;
    _searchBar.delegate = self;
    UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
    if (searchField) {
        // 背景色
        [searchField setBackgroundColor:[UIColor colorWithRed:244/255.0f green:244/255.0f blue:246/255.0f alpha:1.000]];
        // 设置字体颜色 & 占位符 (必须)
        searchField.textColor = RGBA(35, 35, 35, 1.0);
        searchField.font = [UIFont systemFontOfSize:13];
    }
    [self loadHistorySearchData];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboardView) name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [searchArray release];
    [historyArray release];
    [_searchBar release];
    [_tvSearch release];
    [_headerView release];
    [_tvSearchLayoutConstraintBottom release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)SearchDataCellHeight
{
    if(_SearchDataCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchCoinCell" owner:nil options:nil] lastObject];
        _SearchDataCellHeight = cell.frame.size.height;
    }
    return _SearchDataCellHeight;
}

- (CGFloat)SearchDataNoDataCellHeight
{
    if(_SearchDataNoDataCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchCoinNoDataCell" owner:nil options:nil] lastObject];
        _SearchDataNoDataCellHeight = cell.frame.size.height;
    }
    return _SearchDataNoDataCellHeight;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (void)deleteHistoryDataButtonPressed:(UIButton *)sender
{
    UITableViewCell *cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_tvSearch indexPathForCell:cell];
    SearchCoinDataEntity *entity = [historyArray objectAtIndex:indexPath.row];
    [SearchCoinSQL deleteSearchCoinDataFromTable:entity];
    [historyArray removeObject:entity];
    [_tvSearch reloadData];
}

#pragma mark - 读取和保存数据
- (void)loadHistorySearchData
{
    [historyArray removeAllObjects];
    [historyArray addObjectsFromArray:[SearchCoinSQL querySearchCoinDataFromTable]];
}

- (void)saveHistorySearchData:(SearchCoinDataEntity *)item
{
    [SearchCoinSQL updateSearchCoinDataToTable:item];
}


#pragma mark - 请求数据
- (void)reqSearchCoin
{
    [[NetWorkManage shareSingleNetWork] reqSearchCoin:self symbol:_searchBar.text finishedCallback:@selector(reqSearchCoinFinished:) failedCallback:nil];
}

- (void)reqSearchCoinFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *searchResultList = [dataDic objectForKey:@"searchResultList"];
        [searchArray removeAllObjects];
        for(NSDictionary *dic in searchResultList){
            SearchCoinDataEntity *entity = [[[SearchCoinDataEntity alloc] initWithJson:dic] autorelease];
            [searchArray addObject:entity];
        }
        [_tvSearch reloadData];
    }
}

#pragma mark - table view delegate and data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!isEdit && !checkIsStringWithAnyText(_searchBar.text) && historyArray.count > 0) {
        return CGRectGetHeight(_headerView.frame);
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!isEdit && !TTIsStringWithAnyText(_searchBar.text) && historyArray.count > 0) {
        return _headerView;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isEdit || checkIsStringWithAnyText(_searchBar.text)){
        if(checkIsStringWithAnyText(_searchBar.text)){
            if([searchArray count] == 0){
                return 1;
            }else{
                return [searchArray count];
            }
        }else{
            return 0;
        }
    }else{
        return [historyArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(checkIsStringWithAnyText(_searchBar.text) || isEdit){
        if([searchArray count] == 0){
            return self.SearchDataNoDataCellHeight;
        }
    }
    return self.SearchDataCellHeight;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(checkIsStringWithAnyText(_searchBar.text) || isEdit){
        if([searchArray count] > 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCoinCellIdentifier"];
            if(!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchCoinCell" owner:nil options:nil] lastObject];
                [CommonUtil cellSelectedColorWichCell:cell color:RGBA(210, 210, 210, 1.0)];
                UIButton *delButton = (UIButton *)[cell viewWithTag:101];
                [delButton addTarget:self action:@selector(deleteHistoryDataButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            }
            SearchCoinDataEntity *item = searchArray[indexPath.row];
            UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
            UIButton *delButton = (UIButton *)[cell viewWithTag:101];
            nameLabel.text = item.symbol;
            delButton.hidden = YES;
            
            return cell;
        }else{
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchCoinNoDataCell" owner:nil options:nil] lastObject];
            
            return cell;
        }
        
        
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCoinCellIdentifier"];
        if(!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchCoinCell" owner:nil options:nil] lastObject];
            [CommonUtil cellSelectedColorWichCell:cell color:RGBA(210, 210, 210, 1.0)];
            UIButton *delButton = (UIButton *)[cell viewWithTag:101];
            [delButton addTarget:self action:@selector(deleteHistoryDataButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        SearchCoinDataEntity *item = historyArray[indexPath.row];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
        UIButton *delButton = (UIButton *)[cell viewWithTag:101];
        nameLabel.text = item.symbol;
        delButton.hidden = NO;
        return cell;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
//    [self.view endEditing:true];
    SearchCoinDataEntity *item = nil;
    if (TTIsStringWithAnyText(_searchBar.text) || isEdit) {
        if(searchArray.count == 0)
            return;
        item = searchArray[indexPath.row];
    } else {
        if(historyArray.count == 0)
            return;
        item = historyArray[indexPath.row];
    }
    if(item.type == 0){         //正常跳搜索
        [self saveHistorySearchData:item];
        if (checkIsStringWithAnyText(item.symbol)) {//页面跳转
            [self putValueToParamDictionary:CoinTradeDic value:item.symbol forKey:@"CoinQuotationsDetailSymbol"];
            [self putValueToParamDictionary:CoinTradeDic value:item.originSymbol forKey:@"CoinQuotationsDetailOriginSymbol"];
            [self putValueToParamDictionary:CoinTradeDic value:item.marketType forKey:@"CoinQuotationDetailMarketType"];
            [self pageToViewControllerForName:@"CoinQuotationsDetailController"];
        }
    }else if(item.type == 1){   //跳链接
        if(checkIsStringWithAnyText(item.url)){
            TYWebViewController *web = [[TYWebViewController alloc] init];
            web.url = item.url;
            [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
        }
    }
    
}

#pragma mark - search bar delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    isEdit = true;
    [_tvSearch reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    isEdit = false;
    [_tvSearch reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self reqSearchCoin];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:true];
    [self reqSearchCoin];
}



#pragma mark - 键盘回调
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    [UIView animateWithDuration:0.25 animations:^{
        _tvSearchLayoutConstraintBottom.constant = CGRectGetHeight(keyboardRect);
        [_tvSearch setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }];
}

- (void)hideKeyboardView
{
    [UIView animateWithDuration:0.25 animations:^{
        _tvSearchLayoutConstraintBottom.constant = 0;
        [_tvSearch setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }];
}




@end
