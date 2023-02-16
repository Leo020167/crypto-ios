//
//  PersonalMainFollowController.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/5.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "PersonalMainFollowController.h"
#import "PersonalMainFollowCell.h"
#import "PCMultiNumSettingView.h"
#import "PersonalMainFollowAlertController.h"

@interface PersonalMainFollowController ()<UITableViewDelegate, UITableViewDataSource, PCMultiNumSettingViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) NSInteger hasBind;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIView *footerView;

@end

@implementation PersonalMainFollowController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    [self setNav];
    
    [self initUI];
    
    [self getMainData];
}

- (void)setNav{
    self.index = 0;
    self.hasBind = 0;
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
    titleLabel.text = NSLocalizedStringForKey(@"申请绑定");
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
    [self.view addSubview:self.tableView];
}

- (void)getMainData{
    [YYRequestUtility Post:@"follow/getTypes.do" addParameters:@{@"dvUid" : self.uid} progress:nil success:^(NSDictionary *responseDict) {
        NSLog(@"responseDict : %@", responseDict);
        if ([responseDict[@"code"] intValue] == 200) {
            [self.dataSource removeAllObjects];
            NSArray *dataArray = responseDict[@"data"][@"data"][@"types"];
            for (NSInteger i = 0; i < dataArray.count; i ++) {
                PersonalMainFollowModel *model = [PersonalMainFollowModel yy_modelWithDictionary:dataArray[i]];
                model.row = i;
                if (model.isBind == 1) {
                    self.hasBind = 1;
                    self.index = i;
                }
                [self.dataSource addObject:model];
            }
            int showBind = [responseDict[@"data"][@"data"][@"showBind"] intValue];
            if (showBind == 1) {
                self.tableView.tableFooterView = self.footerView;
            }else{
                self.tableView.tableFooterView = [UIView new];
            }
            [self.tableView reloadData];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
    }];
}

- (void)sureBtnAction{
    
    PersonalMainFollowAlertController *alert = [[PersonalMainFollowAlertController alloc] init];
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    alert.sureBtnActionBlock = ^{
        PCMultiNumSettingView *settingView = [[PCMultiNumSettingView alloc] init];
        settingView.delegate = self;
        settingView.view.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [settingView showMultiNumViewInController:self];
    };
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:@"确定绑定当前跟单吗？" preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleDefault handler:nil]];
//    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self blindAction];
//    }]];
//    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - PCMultiNumSettingView delegate
- (void)multiNumSettingViewCommitData:(PCMultiNumSettingView *)viewController multiNum:(NSString *)multiNum
{
    PersonalMainFollowModel *model = self.dataSource[self.index];
    if(!checkIsStringWithAnyText(multiNum)){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入倍数")];
        return;
    }
    if([multiNum integerValue] < 0){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入大于0的倍数")];
        return;
    }
    [viewController dismissMultiNumView];
    if (multiNum.intValue > model.maxMultiNum) {
        [self showToastCenter:[NSString stringWithFormat:NSLocalizedStringForKey(@"输入跟单倍数不能大于%ld!"), (long)model.maxMultiNum]];
        return;
    }
    if (multiNum.intValue < model.minMultiNum) {
        [self showToastCenter:[NSString stringWithFormat:NSLocalizedStringForKey(@"输入跟单倍数不能小于%ld!"), (long)model.minMultiNum]];
        return;
    }
    [YYRequestUtility Post:@"follow/applyForFollow.do" addParameters:@{@"dvUid" : self.uid, @"typeId" : model.id, @"multiNum" : multiNum} progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            [QMUITips showSucceed:responseDict[@"msg"]];
            [self.navigationController popViewControllerAnimated:YES];
        }else if ([responseDict[@"code"] intValue] == 1005){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:responseDict[@"msg"] message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"去划转") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self pageToViewControllerForName:@"PCTransferCoinController"];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PersonalMainFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PersonalMainFollowCell class]) forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.section];
    if (self.index == indexPath.section) {
        cell.titleBtn.selected = YES;
    }else{
        cell.titleBtn.selected = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.hasBind == 1) return;
    self.index = indexPath.section;
    [tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

#pragma mark =========================== 懒加载 ===========================
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kUINormalNavBarHeight) style:QMUITableViewStyleInsetGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.estimatedRowHeight = 200;
        _tableView.backgroundColor = UIColorMakeWithHex(@"#F5F5F5");
        _tableView.tableFooterView = self.footerView;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[PersonalMainFollowCell class] forCellReuseIdentifier:NSStringFromClass([PersonalMainFollowCell class])];
    }
    return _tableView;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        
        UIButton *sureBtn = [[UIButton alloc] init];
        [sureBtn setTitle:NSLocalizedStringForKey(@"确定") forState:0];
        [sureBtn setTitleColor:UIColor.whiteColor forState:0];
        sureBtn.titleLabel.font = UIFontMake(15);
        sureBtn.backgroundColor = UIColorMakeWithHex(@"#4B5FA3");
        sureBtn.layer.cornerRadius = 5;
        sureBtn.layer.masksToBounds = YES;
        [sureBtn addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:sureBtn];
        [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 50));
            make.center.mas_equalTo(self.footerView);
        }];
    }
    return _footerView;
}

@end
