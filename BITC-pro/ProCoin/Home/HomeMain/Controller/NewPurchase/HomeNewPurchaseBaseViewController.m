//
//  HomeNewPurchaseBaseViewController.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/12/3.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeNewPurchaseBaseViewController.h"
#import "JXCategoryView.h"
#import "JXCategoryListContainerView.h"
#import "HomeNewPurchaseViewController.h"

@interface HomeNewPurchaseBaseViewController ()<JXCategoryListContainerViewDelegate,JXCategoryViewDelegate>

@property (nonatomic, strong) JXCategoryTitleView *myCategoryView;

@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation HomeNewPurchaseBaseViewController

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
    titleLabel.text = NSLocalizedStringForKey(NSLocalizedStringForKey(@"新币申购"));
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
    self.listContainerView.frame = CGRectMake(0, kUINormalNavBarHeight + 20, SCREEN_WIDTH, SCREEN_HEIGHT);
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
    HomeNewPurchaseViewController *list = [[HomeNewPurchaseViewController alloc] init];
    list.index = index;
    return list;
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
        _myCategoryView.titles = @[NSLocalizedStringForKey(@"未开始"), NSLocalizedStringForKey(@"进行中"), NSLocalizedStringForKey(@"已结束")];
        _myCategoryView.backgroundColor = [UIColor whiteColor];
        _myCategoryView.titleColor = UIColorMakeWithHex(@"#666666");
        _myCategoryView.titleSelectedColor = UIColorMakeWithHex(@"#5FCE64");
        _myCategoryView.titleFont = UIFontMake(15);
        _myCategoryView.titleSelectedFont = UIFontMake(18);
        _myCategoryView.averageCellSpacingEnabled = NO;
        _myCategoryView.titleColorGradientEnabled = YES;
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorColor = UIColorMakeWithHex(@"#5FCE64");
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
