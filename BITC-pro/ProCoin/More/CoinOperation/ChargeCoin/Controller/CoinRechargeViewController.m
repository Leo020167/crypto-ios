//
//  CoinRechargeViewController.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/30.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "CoinRechargeViewController.h"
#import "NetWorkManage+file.h"
#import "UIImage+Size.h"

@interface CoinRechargeViewController ()<UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
    UIImagePickerController     *imagePicker;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIButton *qrBtn;

@property (nonatomic, copy) NSString *qrImage_str;

@property (nonatomic, strong) UITextField *textField;

@end

@implementation CoinRechargeViewController

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
    titleLabel.text = NSLocalizedStringForKey(@"充值确认");
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.font = UIFontMake(17);
    [navView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(navView);
        make.top.mas_equalTo(kUIStatusBarHeight);
        make.height.mas_equalTo(44);
    }];
    
    UIButton *submitBtn = [[UIButton alloc] init];
    [submitBtn setTitle:NSLocalizedStringForKey(@"提交") forState:0];
    [submitBtn setTitleColor:UIColorMakeWithHex(@"3B4A91") forState:0];
    submitBtn.titleLabel.font = UIFontMake(15);
    [submitBtn addTarget:self action:@selector(submitBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:submitBtn];
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(titleLabel);
        make.right.mas_equalTo(0);
        make.size.mas_equalTo(44);
    }];
}

- (void)initUI{
    [self.view addSubview:self.tableView];
}

- (void)submitBtnAction{
    if (!self.textField.text.length) {
        [QMUITips showError:NSLocalizedStringForKey(@"请输入充值数量")];
        return;
    }
    if (!self.qrImage_str.length) {
        [QMUITips showError:NSLocalizedStringForKey(@"请上传充值截图")];
        return;
    }
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    [para setObject:self.textField.text forKey:@"amount"];
    [para setObject:@"" forKey:@"address"];
    [para setObject:self.qrImage_str forKey:@"image"];
    [para setObject:@"1" forKey:@"inOut"];
    [para setObject:self.model.type forKey:@"chainType"];
    
    [YYRequestUtility Post:@"depositeWithdraw/localSubmit.do" addParameters:para progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            [QMUITips showSucceed:responseDict[@"msg"]];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)qrBtnAction{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"选择图片") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"从相册选择") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getInAlbum];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"拍照") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getInCamera];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 从相册获取照片
- (void)getInAlbum{
    if (!imagePicker) {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
    }
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - 从相机获取照片
- (void)getInCamera{
    if (!imagePicker) {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
    }
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate Methods
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [self.qrBtn setImage:image forState:0];
    NSString *imageFile = [UIImage createOriginalImage:image userId:ROOTCONTROLLER_USER.userId];
    [[NetWorkManage shareSingleNetWork] reqWithdrawUploadQRCodeImage:self imageFile:imageFile finishedCallback:@selector(reqUploadQRCodeFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)reqUploadQRCodeFinished:(NSDictionary *)json
{
    if([[json objectForKey:@"success"] boolValue]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *urlArr = [dataDic objectForKey:@"imageUrlList"];
        self.qrImage_str = [NSString stringWithFormat:@"%@",[urlArr firstObject]];
    }
}

- (void)reqHttpRequestFailed:(NSDictionary *)json{
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark =========================== 懒加载 ===========================
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kUINormalNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return _tableView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 30, SCREEN_WIDTH - 20, 50)];
        self.textField = textField;
        textField.placeholder = NSLocalizedStringForKey(@"请输入充值数量");
        textField.font = UIFontMake(15);
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.textColor = UIColorMakeWithHex(@"#333333");
        textField.backgroundColor = UIColorMakeWithHex(@"#F6F6F6");
        textField.layer.cornerRadius = 5;
        textField.layer.masksToBounds = YES;
        textField.leftViewMode = UITextFieldViewModeAlways;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 50)];
        textField.leftView = leftView;
        [_headerView addSubview:textField];
        
        
        UIButton *qrBtn = [[UIButton alloc] init];
        [qrBtn setImage:UIImageMake(@"home_car_add_img") forState:0];
        self.qrBtn = qrBtn;
        [qrBtn addTarget:self action:@selector(qrBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:qrBtn];
        [qrBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.headerView);
            make.size.mas_equalTo(100);
            make.top.mas_equalTo(120);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = NSLocalizedStringForKey(@"请上传充值截图");
        titleLabel.textColor = UIColor.blackColor;
        titleLabel.font = UIFontMake(13);
        [_headerView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(qrBtn);
            make.top.mas_equalTo(qrBtn.mas_bottom).offset(15);
        }];
    }
    return _headerView;
}


@end
