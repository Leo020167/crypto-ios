//
//  TYQuotationsBaseViewController.m
//  ProCoin
//
//  Created by 李祥翔 on 2022/3/28.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYQuotationsBaseViewController.h"
#import "JXCategoryView.h"
#import "JXCategoryListContainerView.h"
#import "TYQuotationsListViewController.h"
#import "UIViewController+PublicMethods.h"
@interface TYQuotationsBaseViewController ()<JXCategoryListContainerViewDelegate,JXCategoryViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) JXCategoryTitleView *myCategoryView;

@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) NSTimer *requestDataTimer;

@property (nonatomic, strong) TYQuotationsListViewController *list1;

@property (nonatomic, strong) TYQuotationsListViewController *list2;

@property (nonatomic, strong) TYQuotationsListViewController *list3;

@end

@implementation TYQuotationsBaseViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self startRequestTimer];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self closeRequestTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNav];
    
    [self initUI];
}

- (void)setNav{
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kUINormalNavBarHeight)];
    [self.view addSubview:navView];
    navView.backgroundColor = UIColor.whiteColor;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedStringForKey(@"市场");
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.font = UIFontMake(17);
    [navView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(navView);
        make.top.mas_equalTo(kUIStatusBarHeight);
        make.height.mas_equalTo(44);
    }];
    
    UIButton *searchBtn = [[UIButton alloc] init];
    [searchBtn setImage:UIImageMake(@"util_Icon_search") forState:0];
    searchBtn.qmui_tapBlock = ^(__kindof UIControl *sender) {
        /// Segment顺序
        NSString *type = @[@"stock", @"digital", @"spot"][_myCategoryView.selectedIndex];
        [self putValueToParamDictionary:ProCoinSerachDict value:type  forKey:@"CoinSearchType"];
        [self pageToViewControllerForName:@"SearchCoinController"];
    };
    [navView addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(0);
        make.size.mas_equalTo(44);
    }];
}

- (void)initUI{
    self.view.backgroundColor = UIColorWhite;
    
        self.myCategoryView.frame = CGRectMake(0, kUINormalNavBarHeight, DEVICE_WIDTH, 45);
        self.listContainerView.frame = CGRectMake(0, kUINormalNavBarHeight + 45, DEVICE_WIDTH, DEVICE_HEIGHT - (kUINormalNavBarHeight + 45));
//    self.myCategoryView.frame = CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, 45);
//    self.listContainerView.frame = CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.listContainerView];
    self.myCategoryView.listContainer = self.listContainerView;
    self.myCategoryView.delegate = self;
    [self.view addSubview:self.myCategoryView];
    self.titles = @[NSLocalizedStringForKey(@"全球期指"), NSLocalizedStringForKey(@"合约"), NSLocalizedStringForKey(@"币币")];
    _myCategoryView.titles = self.titles;
}

- (void)startRequestTimer
{
    if(self.requestDataTimer && [self.requestDataTimer isValid]){
        [self closeRequestTimer];
    }
    self.requestDataTimer = [NSTimer timerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime target:self selector:@selector(getQuoteData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.requestDataTimer forMode:NSRunLoopCommonModes];
}

- (void)getQuoteData{
    if (self.list1) {
        [self.list1 getData];
    }
    if (self.list2) {
        [self.list2 getData];
    }
    if (self.list3) {
        [self.list3 getData];
    }
}

- (void)closeRequestTimer
{
    if(self.requestDataTimer && [self.requestDataTimer isValid]){
        [self.requestDataTimer invalidate];
        self.requestDataTimer = nil;
    }
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
    TYQuotationsListViewController *list = [[TYQuotationsListViewController alloc] init];
    list.index = index;
    if (index == 0) {
        self.list1 = list;
    }
    if (index == 1) {
        self.list2 = list;
    }
    if (index == 2) {
        self.list3 = list;
    }
    return list;
}

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.titles.count;
}

#pragma mark =========================== 懒加载 ===========================
- (JXCategoryTitleView *)myCategoryView {
    if (!_myCategoryView) {
        _myCategoryView = [[JXCategoryTitleView alloc] init];
        _myCategoryView.backgroundColor = [UIColor whiteColor];
        _myCategoryView.titleColor = UIColorMakeWithHex(@"#999999");
        _myCategoryView.titleSelectedColor = UIColorMakeWithHex(@"#000000");
        _myCategoryView.titleFont = UIFontMake(16);
        _myCategoryView.titleSelectedFont = UIFontMake(17);
        _myCategoryView.averageCellSpacingEnabled = YES;
        _myCategoryView.titleColorGradientEnabled = YES;
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
