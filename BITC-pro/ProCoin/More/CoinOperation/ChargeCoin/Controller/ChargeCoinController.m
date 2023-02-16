//
//  ChargeCoinController.m
//  Cropyme
//
//  Created by Hay on 2019/9/9.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "ChargeCoinController.h"
#import "NetWorkManage+ExtractCoin.h"
#import "ExtractCoinDataEntity.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"
#import "CoinOperationInfoEntity.h"
#import "UIImage+Size.h"
#import "SelectCoinController.h"
#import "CoinRechargeViewController.h"
#import "MTDashLine.h"
#import "UIView+General.h"
#import "NetWorkManage+File.h"
#import "TextFieldToolBar.h"

@interface ChargeCoinController ()<SelectCoinControllerDelegate, TextFieldToolBarDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    NSArray *coinListArr;
    NSArray *chainTypeListArr;
    
    UIImagePickerController     *imagePicker;
    TextFieldToolBar *toolBar;
    NSTimer *refreshTimer;                  //刷新定时器
}

@property (retain, nonatomic) NSString *symbol;
@property (retain, nonatomic) CoinChargeConfigEntity *infoEntity;

/** 懒加载*/
@property (retain, nonatomic) SelectCoinController *selectController;           //选择币种

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIButton *coinTypeBtn;   //幣

@property (retain, nonatomic) IBOutlet UILabel *availableTipLabel;      //可用餘額（USDT）
@property (retain, nonatomic) IBOutlet UILabel *availableCountLabel;      //
@property (retain, nonatomic) IBOutlet UILabel *minTipLabel;        //最小充值金額（USDT）
@property (retain, nonatomic) IBOutlet UILabel *minCountLabel;

@property (retain, nonatomic) IBOutlet UIButton *copyBtn;

@property (retain, nonatomic) IBOutlet UIView *keyTypeView;         //键类型view

@property (retain, nonatomic) IBOutlet UIView *optionsView;
@property (retain, nonatomic) IBOutlet UIView *contentView;

@property (retain, nonatomic) IBOutlet UIImageView *qrCode;
@property (retain, nonatomic) IBOutlet UILabel *allowTips;  //只允许
@property (retain, nonatomic) IBOutlet UILabel *currentLinkLabel;   //當前鏈路
@property (retain, nonatomic) IBOutlet UILabel *addressLabel;

//@property (retain, nonatomic) IBOutlet UITextField *countField;
//@property (retain, nonatomic) IBOutlet UIImageView *uploadImageView;
//@property (retain, nonatomic) IBOutlet UIButton *deleteImgBtn;
//@property (nonatomic, strong) UIImage *qrImage;
//@property (nonatomic, copy) NSString *qrImage_str;

@property (nonatomic, retain) IBOutlet UIButton *rechargeBtn;
@property (nonatomic, copy) NSString *selectedChainType;    //链类型

@end

@implementation ChargeCoinController


- (void)viewDidLayoutSubviews {
    [_copyBtn applyRadiusMask:14 bottomLeft:14 bottomRight:6 topRight:6];
    
    [_contentView applyShadow];
    [[self.view viewWithTag:800] applyShadow];
    [[self.view viewWithTag:802] applyShadow];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_coinTypeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 7.0, 0.0, 0.0)];
    //[_rechargeBtn setTitle:NSLocalizedStringForKey(@"充值确认") forState:0];
    
    coinListArr = [[NSArray alloc] init];
    chainTypeListArr = [[NSArray alloc] init];
    
//    toolBar = [[TextFieldToolBar alloc] initWithDelegate:self numOfTextField:1];
//    _countField.inputAccessoryView = toolBar;
//
//    [self.uploadImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uploadQRBtnAction)]];
//    [self resetImage:_deleteImgBtn];
    
    [self reqCoinListData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //如果登陆了才进行获取数据操作
    
    if(checkIsStringWithAnyText(ROOTCONTROLLER_USER.userId)){
        [self startRefreshTimer];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self closeRefreshTimer];
    [super viewWillDisappear:animated];
}

#pragma mark - 开启定时器
- (void)startRefreshTimer
{
    if(refreshTimer == nil){
        refreshTimer = [NSTimer timerWithTimeInterval:ROOTCONTROLLER.quotationRefreshTime target:self selector:@selector(getChargeConfig) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:refreshTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)closeRefreshTimer
{
    if(refreshTimer && refreshTimer.isValid){
        [refreshTimer invalidate];
        refreshTimer = nil;
    }
}

#pragma mark - 充值
- (IBAction)rechargeBtnAction{
    //CoinRechargeViewController *recharge = [[CoinRechargeViewController alloc] init];
    //recharge.model = self.dataArray[chainTypeIndex];
    //[QMUIHelper.visibleViewController.navigationController pushViewController:recharge animated:YES];

    if (_symbol == nil) return;
//    if (!self.countField.text.length) {
//        [QMUITips showError:NSLocalizedStringForKey(@"请输入充值数量")];
//        return;
//    }
//    if (!self.qrImage_str.length) {
//        [QMUITips showError:NSLocalizedStringForKey(@"请上传充值截图")];
//        return;
//    }
    
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
//    [para setObject:self.countField.text forKey:@"amount"];
//    [para setObject:self.qrImage_str forKey:@"image"];
    [para setObject:self.addressLabel.text forKey:@"address"];
    [para setObject:self.symbol forKey:@"symbol"];
    if (self.selectedChainType) {
        [para setObject:self.selectedChainType forKey:@"chainType"];
    }
    
    [YYRequestUtility Post:@"depositeWithdraw/chargeSubmit.do" addParameters:para progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            [QMUITips showSucceed:responseDict[@"msg"]];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}


- (void)bindChainTypeView {
    
    if ([_symbol.uppercaseString isEqualToString: @"USDT"]) {
        [self.keyTypeView setHidden:NO];
    } else {
        [self.keyTypeView setHidden:YES];
        return;
    }
    
    [_optionsView qmui_removeAllSubviews];
    CGFloat width = 64;
    CGFloat height = 30;
    CGFloat tap = 8;
    UIButton *firstButton;
    for(int i = 0; i < chainTypeListArr.count; i++){
        NSString *string = [NSString stringWithFormat:@"%@", chainTypeListArr[i]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.layer.cornerRadius = 5;
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = UIColorMakeWithHex(@"#00BAB8").CGColor;
        [button addTarget:self action:@selector(optionsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1000+i;
        [button setFrame:CGRectMake(0.0 + (tap + width) * i , 0.0, width, height)];
        [button setTitle:string forState:UIControlStateNormal];
        [button setTitleColor:UIColorMakeWithHex(@"#00BAB8") forState: UIControlStateNormal];
        [button setTitleColor:UIColorMakeWithHex(@"#ffffff") forState: UIControlStateSelected];
        [button setBackgroundImage:[UIImage qmui_imageWithColor:UIColorMakeWithHex(@"#ffffff")] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage qmui_imageWithColor:UIColorMakeWithHex(@"#00BAB8")] forState:UIControlStateSelected];
        
        button.titleLabel.font = UIFontMake(15);
        if ([self.selectedChainType isEqualToString: string]) {
            firstButton = button;
        }
        [_optionsView addSubview:button];
    }
    if (chainTypeListArr.count > 0 && !self.selectedChainType) {
        firstButton = (UIButton *)[_optionsView viewWithTag:1000];
    }
    if (firstButton) {[self optionsButtonPressed:firstButton];}
}


/// 点击链
- (void)optionsButtonPressed:(UIButton *)sender {
    if(sender.isSelected){ return; }
    
    sender.selected = YES;
    _currentLinkLabel.text = [sender titleForState:0];
    [self updateButtonWithSelectedState:sender];
    NSInteger tag = sender.tag - 1000;
    self.selectedChainType = chainTypeListArr[tag];
    _currentLinkLabel.text = _selectedChainType;
    [self.infoEntity.addressList enumerateObjectsUsingBlock:^(CoinChargeConfigAddress * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.symbol isEqual:self.symbol] && [[obj.chainType uppercaseString] isEqual:[self.selectedChainType uppercaseString]]) {
            _addressLabel.text = obj.address;
            _qrCode.image = [UIImage createQRForString:obj.address withSize:180];
            *stop = YES;
        }
    }];
    
    for(int i = 0; i < chainTypeListArr.count; i++){
        if(i == tag)
            continue;
        UIButton *button = [_optionsView viewWithTag:1000+i];
        button.selected = NO;
        [self updateButtonWithNormalState:button];
    }
}

- (void)setInfoEntity:(CoinChargeConfigEntity *)infoEntity {
    _infoEntity = [infoEntity retain];
    _availableCountLabel.text = infoEntity.availableAmount;
    _minCountLabel.text = infoEntity.minChargeAmount;
    
    if (self.selectedChainType) {
        [self.infoEntity.addressList enumerateObjectsUsingBlock:^(CoinChargeConfigAddress * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.symbol isEqual:self.symbol] && [[obj.chainType uppercaseString] isEqual:[self.selectedChainType uppercaseString]]) {
                _addressLabel.text = obj.address;
                _qrCode.image = [UIImage createQRForString:obj.address withSize:180];
                *stop = YES;
            }
        }];
    } else {
        NSString *address = infoEntity.addressList.firstObject.address;
        _addressLabel.text = address;
        _qrCode.image = [UIImage createQRForString:address withSize:180];
    }
}

/// 获取冲币信息
/// /// "data": {"availableAmount": "10","addressList": [{"address": "JKLJKSJGIOUIO454334","symbol": "BTC"}],"minChargeAmount": "1"},
- (void)getChargeConfig {
    if (_symbol == nil) return;
    [YYRequestUtility Post:@"depositeWithdraw/getChargeConfigs.do" addParameters:@{@"symbol": _symbol} progress:nil success:^(NSDictionary *responseDict) {
        if ([responseDict[@"code"] intValue] == 200) {
            self.infoEntity = [CoinChargeConfigEntity yy_modelWithDictionary:responseDict[@"data"]];
        }else{
            [QMUITips showError:responseDict[@"msg"]];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)bindSymbol:(NSString *)symbol {
    self.symbol = symbol;
    self.selectedChainType = nil;
    _currentLinkLabel.text = @"";
    [_coinTypeBtn setTitle:symbol forState:0];
    self.availableTipLabel.text = [NSString stringWithFormat: NSLocalizedStringForKey(@"可用余额()"), symbol];
    self.minTipLabel.text = [NSString stringWithFormat: NSLocalizedStringForKey(@"最小充值金额()"), symbol];
    self.allowTips.text = [NSString stringWithFormat: NSLocalizedStringForKey(@"只允许充值"), symbol];
    [self getChargeConfig];
    [self bindChainTypeView];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    if(info == nil)
        return;
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-keyboardRect.size.height - kUINormalBottomSafeDistance);
    }];

    [_scrollView qmui_scrollToBottom];
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.35 animations:^{
    } completion:^(BOOL finished) {
        [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
        }];
    }];
    
}

#pragma mark - 懒加载
- (SelectCoinController *)selectController
{
    if(!_selectController){
        _selectController = [[SelectCoinController alloc] init];
        [_selectController.view setFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _selectController.delegate = self;
    }
    return _selectController;
}


/** 按钮点击事件*/
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)copyButtonPressed:(id)sender
{
    [UIPasteboard generalPasteboard].string = _addressLabel.text;
}

- (IBAction)chooseCoinButtonPressed:(id)sender {
    if([coinListArr count] == 0){
        [self showToastCenter:NSLocalizedStringForKey(@"No coins available for top-up at the moment")];
        return;
    }
    //self.selectController.modalPresentationStyle = UIModalPresentationFullScreen;
    self.selectController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.selectController.view.backgroundColor=[UIColor colorWithWhite:0 alpha:0.4];
    [self.selectController reloadSelectCoinData:coinListArr];
    [self presentViewController:self.selectController animated:YES completion:^{
        
    }];
}


- (IBAction)saveQRCodeButtonPressed:(id)sender {
    [self saveImageInPhotosAlbum:_qrCode.image];
}


- (IBAction)addressButtonPressed:(id)sender
{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = _addressLabel.text;
    [self showToastCenter:NSLocalizedStringForKey(@"复制成功")];
}

- (IBAction)recordButtonPressed:(id)sender
{
    [self pageToViewControllerForName:@"PCCoinOperationRecordController"];
}

//- (IBAction)resetImage:(UIButton *)sender
//{
//    _uploadImageView.image = [UIImage imageNamed:@"home_car_add_img"];
//    _qrImage = nil;
//    _qrImage_str = nil;
//    [sender setHidden:YES];
//}

#pragma mark - 请求数据
- (void)reqCoinListData
{
    [[NetWorkManage shareSingleNetWork] reqDepositeWithdrawCoinList:self inOut:@"1" finishedCallback:@selector(reqCoinListDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCoinListDataFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        coinListArr = [[NSArray alloc] initWithArray: (NSArray*) [dataDic objectForKey:@"coinList"]];
        chainTypeListArr = [[NSArray alloc] initWithArray: (NSArray*) [dataDic objectForKey:@"chainTypeList"]];
        if (coinListArr.count > 0) {
            [self bindSymbol: [coinListArr.firstObject stringValue]];
        }

    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

#pragma mark - SelectCoinController delegate
- (void)selectCoinDidSelctedWithSymol:(NSString *)symbol {
    [self bindSymbol:symbol];
    
}

- (void)dealloc
{
    [_symbol release];
    [_infoEntity release];
    [_selectController release];
    [_availableTipLabel release];
    [_availableCountLabel release];
    [_minTipLabel release];
    [_minCountLabel release];
    [_copyBtn release];
    [_optionsView release];
    [_keyTypeView release];
    [_contentView release];
    [_allowTips release];
    [_currentLinkLabel release];
    
//    [_rechargeBtn release];
//    [_countField release];
//    [_uploadImageView release];
//    [_deleteImgBtn release];
    [chainTypeListArr release];
    [_coinTypeBtn release];
    [_qrCode release];
    [_addressLabel release];

    [super dealloc];
}

- (void)uploadQRBtnAction{
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
//- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
//    self.qrImage = image;
//    self.uploadImageView.image = image;
//    [self.deleteImgBtn setHidden:NO];
//    NSString *imageFile = [UIImage createOriginalImage:image userId:ROOTCONTROLLER_USER.userId];
//    [[NetWorkManage shareSingleNetWork] reqWithdrawUploadQRCodeImage:self imageFile:imageFile finishedCallback:@selector(reqUploadQRCodeFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}
//- (void)reqUploadQRCodeFinished:(NSDictionary *)json
//{
//    if([self checkJsonIsSuccess:json]){
//        NSDictionary *dataDic = [json objectForKey:@"data"];
//        NSArray *urlArr = [dataDic objectForKey:@"imageUrlList"];
//        self.qrImage_str = [NSString stringWithFormat:@"%@",[urlArr firstObject]];
//    }else{
//    }
//}

#pragma mark - TextFieldToolBar delegate
//- (void)TFDonePressed
//{
//    [_countField resignFirstResponder];
//}

#pragma mark - 设置按钮状态
- (void)updateButtonWithSelectedState:(UIButton *)button
{
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    //button.layer.borderColor = RGBA(97, 117, 174, 1.0).CGColor;
    button.layer.borderWidth = 0;
}

- (void)updateButtonWithNormalState:(UIButton *)button
{
    [button setTitleColor:UIColorMakeWithHex(@"#00BAB8") forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    button.layer.borderColor = UIColorMakeWithHex(@"#00BAB8").CGColor;
    button.layer.borderWidth = 1.0;
}

#pragma mark - 保存到相册
- (void)saveImageInPhotosAlbum:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = nil ;
    if(error){
        msg = NSLocalizedStringForKey(@"保存图片失败") ;
    }else{
        msg = NSLocalizedStringForKey(@"保存图片成功") ;
    }
    
    [self showToastCenter:msg];
}



@end
