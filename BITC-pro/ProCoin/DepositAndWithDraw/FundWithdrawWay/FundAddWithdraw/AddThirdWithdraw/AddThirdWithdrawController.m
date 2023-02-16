//
//  AddThirdWithdrawController.m
//  Cropyme
//
//  Created by Hay on 2019/5/15.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "AddThirdWithdrawController.h"
#import "NetWorkManage+Trade.h"
#import "NetWorkManage+File.h"
#import "TZImagePickerController.h"
#import "CommonUtil.h"
#import "UIImage+Size.h"
#import "TextFieldToolBar.h"
#import "PayAlertView.h"

@interface AddThirdWithdrawController ()<TZImagePickerControllerDelegate,UITextFieldDelegate>
{
    BOOL isChooseQRCode;            //是否已选择二维码图片
}

@property (copy, nonatomic) NSString *receiptType;
@property (copy, nonatomic) NSString *uploadImageUrl;           //上传图片的链接
@property (retain, nonatomic) IBOutlet UILabel *navigationTitleLabel;
@property (retain, nonatomic) IBOutlet UITextField *nameTF;         //名字输入
@property (retain, nonatomic) IBOutlet UILabel *accountTitleLabel;  //账号标题
@property (retain, nonatomic) IBOutlet UITextField *accountTF;      //账号输入
@property (retain, nonatomic) IBOutlet UIImageView *qrCodeIV;       //二维码图片
@property (retain, nonatomic) IBOutlet UIView *infoTipsView;        //提示说明view
@property (retain, nonatomic) IBOutlet UIButton *saveButton;        //保存按钮

@end

@implementation AddThirdWithdrawController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isChooseQRCode = NO;
    _nameTF.delegate = self;
    _accountTF.delegate = self;
    [_saveButton setBackgroundImage:[CommonUtil createImageWithColor:RGBA(255, 143, 1 , 1.0)] forState:UIControlStateNormal];
    if([self getValueFromModelDictionary:FundExchangeDic forKey:@"AddThirdWithdrawReceiptType"]){
        self.receiptType = [self getValueFromModelDictionary:FundExchangeDic forKey:@"AddThirdWithdrawReceiptType"];
        [self removeParamFromModelDictionary:FundExchangeDic forKey:@"AddThirdWithdrawReceiptType"];
    }
    if([_receiptType integerValue] == 1){
        _navigationTitleLabel.text = NSLocalizedStringForKey(@"添加支付宝收款");
        _accountTitleLabel.text = NSLocalizedStringForKey(@"支付宝账号");
    }else if([_receiptType integerValue] == 2){
        _navigationTitleLabel.text = NSLocalizedStringForKey(@"添加微信收款");
        _accountTitleLabel.text = NSLocalizedStringForKey(@"微信账号");
    }else{
        _navigationTitleLabel.text = @"";
    }
    
    [self addBorderToLayer:_infoTipsView];
}

- (void)dealloc
{
    [_receiptType release];
    [_uploadImageUrl release];
    [_nameTF release];
    [_accountTF release];
    [_qrCodeIV release];
    [_navigationTitleLabel release];
    [_saveButton release];
    [_infoTipsView release];
    [_accountTitleLabel release];
    [super dealloc];
}

/** 为view添加虚线描边边框*/
- (void)addBorderToLayer:(UIView *)view
{
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = RGBA(255, 143, 1.0, 1).CGColor;
    border.fillColor = nil;
    CGRect frame = view.bounds;
    frame.size.width = SCREEN_WIDTH - 30;
    border.path = [UIBezierPath bezierPathWithRect:frame].CGPath;
    border.frame = frame;
    border.lineWidth = 1;
    border.lineCap = @"square";
    border.lineDashPattern = @[@3, @3];
    [view.layer addSublayer:border];
}


#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)addQRCodeButtonPressed:(id)sender
{
    TZImagePickerController *imagePickerVc = [[[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES] autorelease];
    /**设置属性*/
    imagePickerVc.allowTakeVideo = NO;          //不允许内部拍照
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingImage = YES;      //允许选择图片
    imagePickerVc.allowPickingVideo = NO;       //不允许选择视频
    imagePickerVc.showSelectedIndex = YES;
    imagePickerVc.allowCrop = NO;

    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (IBAction)saveReceiptButtonPressed:(id)sender
{
    if(!checkIsStringWithAnyText(_accountTF.text)){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入账户")];
        return;
    }
    if(!checkIsStringWithAnyText(_nameTF.text)){
        [self showToastCenter:NSLocalizedStringForKey(@"请输入姓名")];
        return;
    }
    if(!isChooseQRCode){
        [self showToastCenter:NSLocalizedStringForKey(@"请选择二维码图片")];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"是否确定要保存该收款方式?") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqUploadQRCode];;
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)backgroundViewTouchDown:(id)sender
{
    [_nameTF resignFirstResponder];
    [_accountTF resignFirstResponder];
}

#pragma mark - 请求数据
- (void)reqUserSaveReceipt:(NSString *)payPass
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqUserSaveReceipt:self receiptType:_receiptType receiptId:@"0" receiptName:_nameTF.text receiptNo:_accountTF.text bankName:@"" bankBranch:@"" qrCodeUrl:self.uploadImageUrl payPass:payPass finishedCallback:@selector(reqUserSaveReceiptFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqUserSaveReceiptFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        [self showToastCenter:NSLocalizedStringForKey(@"保存成功")];
        [self goBackToViewControllerForName:@"FundWithdrawManagerController" animated:YES];
    }else{
        if([self checkIsNeedTradePassword:json]){          //需要输入交易密码
            PayAlertView* payAlertView = [[[PayAlertView alloc]initWithTitle:nil message:NSLocalizedStringForKey(@"验证身份") delegate:self] autorelease];
            [payAlertView show];
        }else if(![self checkIsNeedSetTradePassword:json]){     //不需要设置交易密码
            [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
        }
        
    }
}

- (void)reqUploadQRCode
{
    [self showProgressDefaultText];
    NSString *imageFile = [UIImage createOriginalImage:_qrCodeIV.image userId:ROOTCONTROLLER_USER.userId];
    [[NetWorkManage shareSingleNetWork] reqWithdrawUploadQRCodeImage:self imageFile:imageFile finishedCallback:@selector(reqUploadQRCodeFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqUploadQRCodeFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *urlArr = [dataDic objectForKey:@"imageUrlList"];
        self.uploadImageUrl = [NSString stringWithFormat:@"%@",[urlArr firstObject]];
        [self reqUserSaveReceipt:@""];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求保存图片异常")];
    }
}

#pragma mark - TZImagePickerController delegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    isChooseQRCode = YES;
    _qrCodeIV.image = [photos lastObject];
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - payAlertView delegate
- (void)payAlertView:(PayAlertView *)toolView finish:(NSString*)password
{
    if (password.length>0) {
        [self reqUserSaveReceipt:password];
        [toolView close];
    }else{
        [toolView reset];
    }
}


@end
