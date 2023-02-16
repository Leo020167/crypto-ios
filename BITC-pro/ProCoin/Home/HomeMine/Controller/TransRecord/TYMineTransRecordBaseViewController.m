//
//  TYMineTransRecordBaseViewController.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/8/14.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYMineTransRecordBaseViewController.h"
#import "JXCategoryView.h"
#import "JXCategoryListContainerView.h"
#import "TYMineTransactionRecordListViewController.h"
#import "PCDigitalRecordScreenView.h"

@interface TYMineTransRecordBaseViewController ()<JXCategoryListContainerViewDelegate,JXCategoryViewDelegate, PCDigitalRecordScreenViewDelegate>

@property (nonatomic, strong) JXCategoryTitleView *myCategoryView;

@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) QMUIButton *titleBtn;

@property (nonatomic, copy) NSString *accountType;

@property (nonatomic, strong) UIButton *filterBtn;

/// 筛选的交易队
@property (nonatomic, copy) NSString *screenSymbol;

/// 筛选的订单类型
@property (nonatomic, copy) NSString *screenOrderType;

@end

@implementation TYMineTransRecordBaseViewController

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
    
    QMUIButton *titleBtn = [[QMUIButton alloc] init];
    self.titleBtn = titleBtn;
    [titleBtn setTitle:NSLocalizedStringForKey(@"交易记录") forState:0];
    [titleBtn setTitleColor:UIColor.blackColor forState:0];
    titleBtn.titleLabel.font = UIFontMake(17);
    [navView addSubview:titleBtn];
    [titleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(navView);
        make.top.mas_equalTo(kUIStatusBarHeight);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(SCREEN_WIDTH - 100);
    }];
    
//    UIButton *filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kUIStatusBarHeight, 60, 44)];
//    self.filterBtn = filterBtn;
//    [filterBtn setTitle:NSLocalizedStringForKey(@"筛选") forState:0];
//    [filterBtn setTitleColor:UIColor.blackColor forState:0];
//    filterBtn.titleLabel.font = UIFontMake(15);
//    [filterBtn addTarget:self action:@selector(filterBtnAction) forControlEvents:UIControlEventTouchUpInside];
//    [navView addSubview:filterBtn];
//    [filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(titleBtn);
//        make.right.mas_equalTo(-19);
//    }];
}

- (void)initUI{
    self.screenSymbol = @"";
    self.screenOrderType = @"";
    self.accountType = @"balance";
    self.view.backgroundColor = UIColorWhite;
    
    self.myCategoryView.frame = CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, 45);
    self.listContainerView.frame = CGRectMake(0, kUINormalNavBarHeight + 45, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.listContainerView];
    self.myCategoryView.listContainer = self.listContainerView;
    self.myCategoryView.delegate = self;
    [self.view addSubview:self.myCategoryView];
}

- (void)filterBtnAction{
    PCDigitalRecordScreenView *screenView = [[[PCDigitalRecordScreenView alloc] init] autorelease];
    screenView.delegate = self;
    screenView.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [screenView addSelfToParentViewController:self inputSymbol:self.screenSymbol orderType:self.screenOrderType];
}

#pragma mark - PCDigitalRecordScreenView delegate
- (void)digitalRecordScreenCommitDataWithSymbol:(NSString *)symbol orderType:(NSString *)orderType
{
    self.screenSymbol = symbol;
    self.screenOrderType = orderType;
    [self.myCategoryView reloadData];
}

- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    //侧滑手势处理
    self.filterBtn.hidden = index == 1;
    self.navigationController.interactivePopGestureRecognizer.enabled = (index == 0);
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)categoryView:(JXCategoryBaseView *)categoryView didScrollSelectedItemAtIndex:(NSInteger)index {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - JXCategoryListContainerViewDelegate
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    TYMineTransactionRecordListViewController *list = [[TYMineTransactionRecordListViewController alloc] init];
    list.screenSymbol = self.screenSymbol;
    list.screenOrderType = self.screenOrderType;
    list.accountType = self.accountType;
    list.index = index;
    return list;
}

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return 2;
}

#pragma mark =========================== 懒加载 ===========================
- (JXCategoryTitleView *)myCategoryView {
    if (!_myCategoryView) {
        _myCategoryView = [[JXCategoryTitleView alloc] init];
        _myCategoryView.titles = @[NSLocalizedStringForKey(@"委托记录"), NSLocalizedStringForKey(@"历史记录")];
        _myCategoryView.backgroundColor = [UIColor whiteColor];
        _myCategoryView.titleColor = UIColorMakeWithHex(@"#666666");
        _myCategoryView.titleSelectedColor = UIColorMakeWithHex(@"#333333");
        _myCategoryView.titleFont = UIFontMake(15);
        _myCategoryView.titleSelectedFont = UIFontMake(15);
        _myCategoryView.averageCellSpacingEnabled = YES;
        _myCategoryView.titleColorGradientEnabled = YES;
        _myCategoryView.titleLabelZoomEnabled = YES;
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

