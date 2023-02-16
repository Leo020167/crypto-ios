//
//  CircleSearchViewController.m
//  Perval
//
//  Created by taojinroad on 2017/5/27.
//  Copyright © 2017年 淘金路. All rights reserved.
//

#import "CircleSearchViewController.h"
#import "CommonUtil.h"
#import "NetWorkManage+Circle.h"
#import "CircleSearchEntity.h"
#import "RZWebImageView.h"
#import "CircleSearchSQL.h"
#import "TJRBaseParserJson.h"

@interface CircleSearchViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate> {
    
    NSMutableArray<CircleSearchEntity *> *searchArray;
    NSMutableArray<CircleSearchEntity *> *historyArray;
    BOOL isEdit;
}

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UITableView *tvSearch;
@property (retain, nonatomic) IBOutlet UIView *headerView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation CircleSearchViewController


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
    CircleSearchEntity *entity = [historyArray objectAtIndex:indexPath.row];
    [CircleSearchSQL deleteSearchDataFromTable:entity];
    [historyArray removeObject:entity];
    [_tvSearch reloadData];
}

#pragma mark - 读取和保存数据
- (void)loadHistorySearchData
{
    [historyArray addObjectsFromArray:[CircleSearchSQL querySearchDataFromTable]];
}

- (void)saveHistorySearchData:(CircleSearchEntity *)item
{
    [CircleSearchSQL updateSearchDataToTable:item];
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
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TTIsStringWithAnyText(_searchBar.text) || isEdit ? searchArray.count : historyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CircleSearchDataCellIdentifier"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CircleSearchDataCell" owner:nil options:nil] lastObject];
        [CommonUtil cellSelectedColorWichCell:cell color:RGBA(210, 210, 210, 1.0)];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        UIButton *delButton = (UIButton *)[cell viewWithTag:102];
        [delButton addTarget:self action:@selector(deleteHistoryDataButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    CircleSearchEntity *item = nil;
    UIButton *delButton = (UIButton *)[cell viewWithTag:102];
    if (TTIsStringWithAnyText(_searchBar.text) || isEdit) {
        item = searchArray[indexPath.row];
        delButton.hidden = YES;
    } else {
        item = historyArray[indexPath.row];
        delButton.hidden = NO;
    }
    RZWebImageView *logo = (RZWebImageView *)[cell viewWithTag:100];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    [logo showHeaderImageViewWithUrl:item.circleLogo];
    if(checkIsStringWithAnyText(item.circleId)){
        nameLabel.text = [NSString stringWithFormat:@"%@(圈号：%@)",item.circleName,item.circleId];
    }else{
        nameLabel.text = [NSString stringWithFormat:@"%@",item.circleName];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [self.view endEditing:true];
    CircleSearchEntity *item = nil;
    if (TTIsStringWithAnyText(_searchBar.text)) {
        item = searchArray[indexPath.row];
    } else {
        item = historyArray[indexPath.row];
    }
    [self saveHistorySearchData:item];
    if (TTIsStringWithAnyText(item.circleId)) {//页面跳转
        [self putValueToParamDictionary:CircleDict value:item.circleId forKey:@"circleId"];
        [self pageToOrBackWithName:@"CircleJoinViewController"];
    }
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
        [[NetWorkManage shareSingleNetWork] reqCircleSearch:self keyValue:_searchBar.text finishedCallback:@selector(reqSearchUserDataFinished:) failedCallback:@selector(reqSearchUserDataFailed:)];
    } else {
        [searchArray removeAllObjects];
        _tvSearch.hidden = false;
        [_tvSearch reloadData];
    }

}

- (void)reqSearchUserDataFinished:(NSDictionary *)result
{
    TJRBaseParserJson *jsonParser = [[[TJRBaseParserJson alloc] init]autorelease];
    
    NSDictionary* json = [result objectForKey:@"data"];
    [searchArray removeAllObjects];
    
    if ([jsonParser parseBaseIsOk:result]) {
        NSDictionary *dic = [json objectForKey:@"circle"];
        if (dic && ![dic isKindOfClass:[NSNull class]]) {
            CircleSearchEntity *entity = [[[CircleSearchEntity alloc] initWithJson:dic] autorelease];
            [searchArray addObject:entity];
        }
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
