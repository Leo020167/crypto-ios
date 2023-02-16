//
//  SearchCommodityVC.m
//  Perval
//
//  Created by taojinroad on 2017/5/27.
//  Copyright © 2017年 淘金路. All rights reserved.
//

#import "SearchUserController.h"
#import "CommonUtil.h"
#import "NetWorkManage+Home.h"
#import "SearchDataEntity.h"
#import "RZWebImageView.h"
#import "SearchDataSQL.h"

NSString *const SearchHistorySaveKey = @"SearchCommodityHistorySaveKey";
NSString *const HistorySeparator     = @"#$@";//历史查询分割符

@interface SearchUserController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate> {
    NSMutableArray<SearchDataEntity *> *searchArray;
    NSMutableArray<SearchDataEntity *> *historyArray;
    BOOL isEdit;
}

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UITableView *tvSearch;
@property (retain, nonatomic) IBOutlet UIView *headerView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation SearchUserController


- (void)viewDidLoad {
    [super viewDidLoad];
    searchArray = [[NSMutableArray alloc] init];
    historyArray = [[NSMutableArray alloc] init];

    [_searchBar setBackgroundImage:[CommonUtil createImageWithColor:[UIColor whiteColor]]];
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

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (void)deleteHistoryDataButtonPressed:(UIButton *)sender
{
    UITableViewCell *cell = [CommonUtil getTableViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_tvSearch indexPathForCell:cell];
    SearchDataEntity *entity = [historyArray objectAtIndex:indexPath.row];
    [SearchDataSQL deleteSearchDataFromTable:entity];
    [historyArray removeObject:entity];
    [_tvSearch reloadData];
}

#pragma mark - 读取和保存数据
- (void)loadHistorySearchData
{
    [historyArray addObjectsFromArray:[SearchDataSQL querySearchDataFromTable]];
}

- (void)saveHistorySearchData:(SearchDataEntity *)item
{
    [SearchDataSQL updateSearchDataToTable:item];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!isEdit && !TTIsStringWithAnyText(_searchBar.text) && historyArray.count > 0) {
        return CGRectGetHeight(_headerView.frame);
    }
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!isEdit && !TTIsStringWithAnyText(_searchBar.text) && historyArray.count > 0) {
        return _headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(checkIsStringWithAnyText(_searchBar.text) || isEdit){
        return [searchArray count];
    }else{
        return [historyArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    SearchDataEntity *item = nil;
    if(checkIsStringWithAnyText(_searchBar.text) || isEdit){
        item = searchArray[indexPath.row];
        if(item.type == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchDataCellIdentifier"];
            if(!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchDataCell" owner:nil options:nil] lastObject];
                [CommonUtil cellSelectedColorWichCell:cell color:RGBA(210, 210, 210, 1.0)];
                UIButton *delButton = (UIButton *)[cell viewWithTag:102];
                [delButton addTarget:self action:@selector(deleteHistoryDataButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            RZWebImageView *logo = (RZWebImageView *)[cell viewWithTag:100];
            UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
            UIButton *delButton = (UIButton *)[cell viewWithTag:102];
            delButton.hidden = YES;
            [logo showHeaderImageViewWithUrl:item.headUrl];
            nameLabel.text = [NSString stringWithFormat:@"%@(ID:%@)",item.name,item.userId];
            
            return cell;
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchSpecialLinkCellIdentifier"];
            if(!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchSpecialLinkCell" owner:nil options:nil] lastObject];
                [CommonUtil cellSelectedColorWichCell:cell color:RGBA(210, 210, 210, 1.0)];
            }
            UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
            nameLabel.text = [NSString stringWithFormat:@"%@",item.name];
            return cell;
        }
        
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchDataCellIdentifier"];
        if(!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchDataCell" owner:nil options:nil] lastObject];
            [CommonUtil cellSelectedColorWichCell:cell color:RGBA(210, 210, 210, 1.0)];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            UIButton *delButton = (UIButton *)[cell viewWithTag:102];
            [delButton addTarget:self action:@selector(deleteHistoryDataButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        item = historyArray[indexPath.row];
        
        RZWebImageView *logo = (RZWebImageView *)[cell viewWithTag:100];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
        UIButton *delButton = (UIButton *)[cell viewWithTag:102];
        delButton.hidden = NO;
        [logo showHeaderImageViewWithUrl:item.headUrl];
        nameLabel.text = [NSString stringWithFormat:@"%@(ID:%@)",item.name,item.userId];
        
        return cell;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    SearchDataEntity *item = nil;
    if (TTIsStringWithAnyText(_searchBar.text) || isEdit) {
        if([searchArray count] == 0){
            return;
        }
        
        item = searchArray[indexPath.row];
    } else {
        if([historyArray count] == 0){
            return;
        }
        
        item = historyArray[indexPath.row];
    }
    if(item.type == 0){     //正常搜索结果
        [self saveHistorySearchData:item];
        if (checkIsStringWithAnyText(item.userId)) {//页面跳转
            [self putValueToParamDictionary:ProCoinBaseDict value:item.userId forKey:@"PersonalMainTargetUid"];
            [self pageToViewControllerForName:@"PersonalMainController"];
        }
    }else if(item.type == 1){   //搜索广告链接
        if(checkIsStringWithAnyText(item.url)){
            TYWebViewController *web = [[TYWebViewController alloc] init];
            web.url = item.url;
            [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
        }
    }
//    [self.view endEditing:true];
    
}

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
    [self reqSearchUserData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:true];
    [self reqSearchUserData];
}

#pragma mark - 查找数据
- (void)reqSearchUserData
{
    NSString *searchString = _searchBar.text;
    if (TTIsStringWithAnyText(searchString)) {
        [[NetWorkManage shareSingleNetWork] reqHomeSearchUser:self keyValue:_searchBar.text finishedCallback:@selector(reqSearchUserDataFinished:) failedCallback:@selector(reqSearchUserDataFailed:)];
    } else {
        [searchArray removeAllObjects];
        _tvSearch.hidden = false;
        [_tvSearch reloadData];
    }

}

- (void)reqSearchUserDataFinished:(NSDictionary *)json
{
    NSDictionary *dataDic = [json objectForKey:@"data"];
    NSDictionary *searchDic = [dataDic objectForKey:@"search"];
    [searchArray removeAllObjects];
    if(searchDic != nil){
        SearchDataEntity *entity = [[[SearchDataEntity alloc] initWithJson:searchDic] autorelease];
        [searchArray addObject:entity];
    }
   
    [UIView animateWithDuration:0.25 animations:^{
        _tvSearch.hidden = TTIsStringWithAnyText(_searchBar.text) && searchArray.count == 0;
    }];
    [_tvSearch reloadData];
    
}

- (void)reqSearchUserDataFailed:(NSDictionary *)json
{
    [self showToastCenter:NSLocalizedStringForKey(@"请求失败")];
}


#pragma mark - 键盘回调
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    [UIView animateWithDuration:0.25 animations:^{
        _bottomConstraint.constant = CGRectGetHeight(keyboardRect);
        [_tvSearch setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }];
}

- (void)hideKeyboardView
{
    [UIView animateWithDuration:0.25 animations:^{
        _bottomConstraint.constant = 0;
        [_tvSearch setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }];
}

- (void)dealloc
{
    [searchArray removeAllObjects];
    [historyArray removeAllObjects];
    RELEASE(historyArray);
    RELEASE(searchArray);
    [_tvSearch release];
    [_searchBar release];
    [_headerView release];
    [_bottomConstraint release];
    [super dealloc];
}
@end
