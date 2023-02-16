//
//  CountrySelectController.m
//  BYY
//
//  Created by Hay on 2019/9/26.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CountrySelectController.h"
#import "CommonUtil.h"
#import "NetWorkManage+Security.h"
#import "CountryCodeInfoEntity.h"

@interface CountrySelectController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
{
    BOOL isSearchState;         //是否搜索状态
    NSMutableArray *totalDataArr;
    NSMutableArray *searchDataArr;
}

/** 懒加载*/
@property (assign, nonatomic) CGFloat countryCodeCellHeight;
@property (assign, nonatomic) CGFloat countrySearchNoDataCellHeight;

@property (retain, nonatomic) IBOutlet UIView *topView;         //顶部view
@property (retain, nonatomic) IBOutlet UITableView *dataTableView;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation CountrySelectController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isSearchState = NO;
    totalDataArr = [[NSMutableArray alloc] init];
    searchDataArr = [[NSMutableArray alloc] init];
    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    
    [_searchBar setBackgroundImage:[CommonUtil createImageWithColor:[UIColor whiteColor]]];
    _searchBar.delegate = self;
    UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
    if (searchField) {
        // 背景色
        [searchField setBackgroundColor:[UIColor colorWithRed:244/255.0f green:244/255.0f blue:246/255.0f alpha:1.000]];
        // 设置字体颜色 & 占位符 (必须)
        searchField.textColor = RGBA(35, 35, 35, 1.0);
        searchField.font = [UIFont systemFontOfSize:13];
    }
    [_activityIndicatorView startAnimating];
    [self reqCountryInfoList];
}


- (void)dealloc
{
    [totalDataArr release];
    [searchDataArr release];
    [_topView release];
    [_dataTableView release];
    [_searchBar release];
    [_activityIndicatorView release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)closeViewControllerButtonPressed:(id)sender
{
    [_searchBar resignFirstResponder];
    if(checkIsStringWithAnyText(_searchBar.text)){
        _searchBar.text = @"";
        isSearchState = NO;
        [_dataTableView reloadData];
        return;
    }
    [self dismissModalFromParentViewController];
}

#pragma mark - 懒加载
- (CGFloat)countryCodeCellHeight
{
    if(_countryCodeCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CountryCodeInfoCell" owner:nil options:nil] lastObject];
        _countryCodeCellHeight = cell.frame.size.height;
    }
    return _countryCodeCellHeight;
}

- (CGFloat)countrySearchNoDataCellHeight
{
    if(_countrySearchNoDataCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CountryInfoSearchNoDataCell" owner:nil options:nil] lastObject];
        _countrySearchNoDataCellHeight = cell.frame.size.height;
    }
    return _countrySearchNoDataCellHeight;
}

#pragma mark - 请求数据
- (void)reqCountryInfoList{
    [YYRequestUtility Post:@"area/list.do" addParameters:nil progress:nil success:^(NSDictionary *responseDict) {
        [_activityIndicatorView stopAnimating];
        if ([responseDict[@"code"] intValue] == 200) {
            [totalDataArr removeAllObjects];
            for(NSDictionary *dic in responseDict[@"data"]){
                CountryCodeInfoEntity *infoEntity = [CountryCodeInfoEntity yy_modelWithDictionary:dic];
                [totalDataArr addObject:infoEntity];
            }
            [_dataTableView reloadData];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        [_activityIndicatorView stopAnimating];
        [QMUITips showError:NSLocalizedStringForKey(@"请求失败")];
    }];
}

#pragma mark - search bar delegate
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    isSearchState = YES;
//
//}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if(!checkIsStringWithAnyText(searchBar.text)){
        isSearchState = NO;
    }
    [_dataTableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(!checkIsStringWithAnyText(searchBar.text)){
        isSearchState = NO;
        [_dataTableView reloadData];
    }else{
        isSearchState = YES;
    }
    [searchDataArr removeAllObjects];
    for(CountryCodeInfoEntity *entity in totalDataArr){
        if([entity.enName containsString:searchBar.text] || [entity.tcName containsString:searchBar.text]){
            [searchDataArr addObject:entity];
        }
    }
    [_dataTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:true];
}


#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isSearchState){          //搜索状态
        if([searchDataArr count] == 0)
            return 1;
        return [searchDataArr count];
    }else{
        return [totalDataArr count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isSearchState && [searchDataArr count] == 0)
        return self.countrySearchNoDataCellHeight;
    return self.countryCodeCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *countryCodeCellIdentifier = @"CountryCodeInfoCellIdentifier";

    if(isSearchState && [searchDataArr count] == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CountryInfoSearchNoDataCell" owner:nil options:nil] lastObject];
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:countryCodeCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CountryCodeInfoCell" owner:nil options:nil] lastObject];
        }
        CountryCodeInfoEntity *entity = nil;
        if(isSearchState){
            entity = [searchDataArr objectAtIndex:indexPath.row];
        }else{
            entity = [totalDataArr objectAtIndex:indexPath.row];
            
        }
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *codeLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:102];
        titleLabel.text = entity.enName;
        codeLabel.text = entity.areaCode;
        nameLabel.text = entity.tcName;
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(isSearchState && [searchDataArr count] == 0)
        return;
    CountryCodeInfoEntity *entity = nil;
    if(isSearchState){
        entity = [searchDataArr objectAtIndex:indexPath.row];
    }else{
        entity = [totalDataArr objectAtIndex:indexPath.row];
        
    }
    [_searchBar resignFirstResponder];
    if (self.chooseDataBlock) {
        self.chooseDataBlock(entity);
    }
    [self dismissModalFromParentViewController];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([_searchBar isFirstResponder]){
        [_searchBar resignFirstResponder];
    }
}

@end
