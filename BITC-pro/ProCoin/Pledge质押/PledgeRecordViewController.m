//
//  PledgeRecordViewController.m
//  ProCoin
//
//  Created by Luo Chun on 2022/11/8.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "PledgeRecordViewController.h"
#import "JXCategoryView.h"
#import "JXCategoryListContainerView.h"
#import "HomeNewPurchaseViewController.h"
#import "PledgeRecordCell.h"
#import "YYRequestUtility.h"

@interface PledgeRecordBaseViewController ()<JXCategoryListContainerViewDelegate,JXCategoryViewDelegate>

@property (nonatomic, strong) JXCategoryTitleView *myCategoryView;

@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation PledgeRecordBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNav];
    
    [self initUI];
}

- (void)setNav{
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
    titleLabel.text = NSLocalizedStringForKey(NSLocalizedStringForKey(@"质押记录"));
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
    self.myCategoryView.frame = CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, 45);
    self.listContainerView.frame = CGRectMake(0, CGRectGetMaxY(_myCategoryView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(_myCategoryView.frame));
    [self.view addSubview:self.listContainerView];
    self.myCategoryView.listContainer = self.listContainerView;
    self.myCategoryView.delegate = self;
    [self.view addSubview:self.myCategoryView];
    self.myCategoryView.defaultSelectedIndex = 1;
}

- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    //侧滑手势处理
    self.navigationController.interactivePopGestureRecognizer.enabled = (index == 0);
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)categoryView:(JXCategoryBaseView *)categoryView didScrollSelectedItemAtIndex:(NSInteger)index {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - JXCategoryListContainerViewDelegate
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    PledgeRecordViewController *vc = [[[PledgeRecordViewController alloc] initWithNibName:@"PledgeRecordViewController" bundle:nil] autorelease];
    vc.index = index;
    //PledgeRecordViewController *list = [[HomeNewPurchaseViewController alloc] init];
    //list.index = index;
    return vc;
}

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return 3;
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

#pragma mark =========================== 懒加载 ===========================
- (JXCategoryTitleView *)myCategoryView {
    if (!_myCategoryView) {
        _myCategoryView = [[JXCategoryTitleView alloc] init];
        _myCategoryView.titles = @[NSLocalizedStringForKey(@"进行中"), NSLocalizedStringForKey(@"已结束")];
        _myCategoryView.backgroundColor = [UIColor whiteColor];
        _myCategoryView.titleColor = UIColorMakeWithHex(@"#A2A9BC");
        _myCategoryView.titleSelectedColor = UIColorMakeWithHex(@"#4D4BDA");
        _myCategoryView.titleFont = [UIFont qmui_mediumSystemFontOfSize:16];
        _myCategoryView.titleSelectedFont = [UIFont qmui_mediumSystemFontOfSize:16];
        _myCategoryView.averageCellSpacingEnabled = NO;
        _myCategoryView.titleColorGradientEnabled = YES;
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorColor = UIColorMakeWithHex(@"#4D4BDA");
        _myCategoryView.indicators = @[lineView];
    }
    return _myCategoryView;
}

- (JXCategoryListContainerView *)listContainerView {
    if (!_listContainerView) {
        _listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    }
    return _listContainerView;
}

@end


@interface PledgeRecordViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) IBOutlet UIView *noDataView;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) NSInteger page;


@end

@implementation PledgeRecordViewController

#pragma mark =========================== 懒加载 ===========================
#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [_noDataView setHidden:YES];
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    [self getData];
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = [[NSMutableArray alloc] initWithArray: dataSource];
    [_noDataView setHidden: dataSource.count > 0];
    [_tableView reloadData];
}

- (void)initUI{
    self.view.backgroundColor = UIColorMakeWithHex(@"#F4F6F4");
    //UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight) style:QMUITableViewStyleInsetGrouped];
    //_tableView.delegate = self;
    //_tableView.dataSource = self;
    //tableView.qmui_insetGroupedHorizontalInset = 15;
    //tableView.backgroundColor = UIColor.whiteColor;
    //tableView.estimatedRowHeight = 163;
    _tableView.tableHeaderView = [[UIView alloc] init];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //[_tableView registerClass:[PledgeRecordCell class] forCellReuseIdentifier:NSStringFromClass([PledgeRecordCell class])];
}

- (void)getData{
    [YYRequestUtility Post:@"pledge/recordList.do" addParameters:@{@"status": @(self.index)} progress:nil success:^(NSDictionary *responseDict) {
            if ([responseDict[@"code"] intValue] == 200) {
                //[self.dataSource removeAllObjects];
                self.dataSource = responseDict[@"data"];
                //for (NSDictionary *dict in responseDict[@"data"][@"quotes"]) {
                    //HomeQuoteModel *model = [HomeQuoteModel yy_modelWithDictionary:dict];
                    //[self.dataSource addObject:model];
                //}
                [self.tableView reloadData];
            }else{
                [QMUITips showError:responseDict[@"msg"]];
            }
        } failure:^(NSError *error) {
    
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 15)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 173;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PledgeRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PledgeRecordCell"];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PledgeRecordCell" owner:nil options:nil] lastObject];
    }
    cell.model = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

@end
