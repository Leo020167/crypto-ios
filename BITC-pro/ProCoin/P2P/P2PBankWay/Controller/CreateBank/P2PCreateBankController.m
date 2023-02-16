//
//  P2PCreateBankController.m
//  ProCoin
//
//  Created by UnWood on 2021/4/6.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "P2PCreateBankController.h"
#import "CommonUtil.h"
#import "TextFieldToolBar.h"
#import "NetWorkManage+P2P.h"
#import "TJRBaseParserJson.h"
#import "P2PPaymentEntity.h"
#import "RZWebImageView.h"
#import "TZImagePickerController.h"
#import "NetWorkManage+File.h"
#import "UIImage+Size.h"

@interface P2PCreateBankController () <UITextFieldDelegate,TextFieldToolBarDelegate,TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    BOOL bReqFinished;
    TextFieldToolBar* toolBar;
    
    NSMutableArray* tableData;
}
@property (retain, nonatomic) IBOutlet RZWebImageView *ivPhoto1;
@property (retain, nonatomic) IBOutlet UITextField *tfName;
@property (retain, nonatomic) IBOutlet UITextField *tfReceipt;
@property (retain, nonatomic) IBOutlet UITextField *tfReceiptNo;
@property (retain, nonatomic) IBOutlet UIButton *btnConfirm;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *lbTitle;
@property (retain, nonatomic) IBOutlet UILabel *lbNameTips;
@property (retain, nonatomic) IBOutlet UILabel *lbReceiptTips;
@property (retain, nonatomic) IBOutlet UILabel *lbReceiptNoTips;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutNumberHeight;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutQRcodeHeight;

@property (copy, nonatomic) NSString *receiptType;
@property (copy, nonatomic) NSString *paymentId;
@property (copy, nonatomic) NSString *qrCodeUrl;

@property (retain, nonatomic) UIImage *img1;

@property (retain, nonatomic) P2PPaymentEntity *entity;
@end

@implementation P2PCreateBankController

- (void)viewDidLoad {
    [super viewDidLoad];

    //添加toolbar
    toolBar = [[TextFieldToolBar alloc]initWithDelegate:self numOfTextField:2];
    _tfName.inputAccessoryView = toolBar;
    _tfReceiptNo.inputAccessoryView = toolBar;
    
    bReqFinished = YES;
    
    if([self getValueFromModelDictionary:P2PDict forKey:@"receiptType"]){
        self.receiptType = [self getValueFromModelDictionary:P2PDict forKey:@"receiptType"];
        [self removeParamFromModelDictionary:P2PDict forKey:@"receiptType"];
    }
    if([self getValueFromModelDictionary:P2PDict forKey:@"paymentId"]){
        self.paymentId = [self getValueFromModelDictionary:P2PDict forKey:@"paymentId"];
        [self removeParamFromModelDictionary:P2PDict forKey:@"paymentId"];
    }
    if([self getValueFromModelDictionary:P2PDict forKey:@"paymentEntity"]){
        self.entity = [self getValueFromModelDictionary:P2PDict forKey:@"paymentEntity"];
        [self removeParamFromModelDictionary:P2PDict forKey:@"paymentEntity"];
    }
    
    self.qrCodeUrl = @"";
    
    if (_entity != nil) {
        _tfName.text = _entity.receiptName;
        _tfReceiptNo.text = _entity.receiptNo;
        _tfReceipt.text = _entity.bankName;
        self.qrCodeUrl = _entity.qrCode;
        self.paymentId = _entity.paymentId;
        self.receiptType = _entity.receiptType;
        
        [_ivPhoto1 showImageWithUrl:_entity.qrCode];
        [self.view bringSubviewToFront:_ivPhoto1];
        _btnConfirm.enabled = YES;
    }
    
    if ([_receiptType isEqualToString:@"3"]) {
        _layoutNumberHeight.constant = 100;
        _layoutQRcodeHeight.constant = 0;
        _lbTitle.text = (_entity != nil)?NSLocalizedStringForKey(@"修改银行卡"):NSLocalizedStringForKey(@"添加银行卡");
        _lbNameTips.text = NSLocalizedStringForKey(@"银行卡姓名");
        _lbReceiptNoTips.text = NSLocalizedStringForKey(@"银行卡账号");
        
    }else if ([_receiptType isEqualToString:@"1"]) {
        _layoutNumberHeight.constant = 0;
        _layoutQRcodeHeight.constant = 140;
        _lbTitle.text = (_entity != nil)?NSLocalizedStringForKey(@"修改支付宝账号"):NSLocalizedStringForKey(@"支付宝账号");
        _lbNameTips.text = NSLocalizedStringForKey(@"支付宝姓名");
        _lbReceiptNoTips.text = NSLocalizedStringForKey(@"支付宝账号");
        
    }else if ([_receiptType isEqualToString:@"2"]) {
        _layoutNumberHeight.constant = 0;
        _layoutQRcodeHeight.constant = 140;
        _lbTitle.text = (_entity != nil)?NSLocalizedStringForKey(@"修改微信账号"):NSLocalizedStringForKey(@"微信账号");
        _lbNameTips.text = NSLocalizedStringForKey(@"微信姓名");
        _lbReceiptNoTips.text = NSLocalizedStringForKey(@"微信账号");
    }
    
}

- (void)dealloc{

    [_entity release];
    [_qrCodeUrl release];
    [_paymentId release];
    [_receiptType release];
    [toolBar release];
    [_tfName release];
    [_tfReceipt release];
    [_tfReceiptNo release];
    [_btnConfirm release];
    [_scrollView release];
    [_lbTitle release];
    [_lbNameTips release];
    [_lbReceiptTips release];
    [_lbReceiptNoTips release];
    [_layoutNumberHeight release];
    [_layoutQRcodeHeight release];
    [_ivPhoto1 release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

- (IBAction)confirmBtnClicked:(id)sender {
    
    if ([_receiptType isEqualToString:@"3"] && !TTIsStringWithAnyText(_tfReceipt.text)) {
        [self showToast:NSLocalizedStringForKey(@"请输入开户行")];
        return;
    }
    
    [self reqSavePaymentData:_receiptType paymentId:_paymentId receiptName:_tfName.text receiptNo:_tfReceiptNo.text bankName:_tfReceipt.text qrCodeUrl:_qrCodeUrl];
}

//触摸背景收起键盘
- (IBAction)viewTouchDown:(id)sender {
    [_tfName resignFirstResponder];
    [_tfReceipt resignFirstResponder];
    [_tfReceiptNo resignFirstResponder];
    [_scrollView setContentOffset:CGPointZero animated:YES];
}

- (IBAction)photo1BtnClicked:(id)sender {
    [self takePicture];
}

- (void)takePicture{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"选择二维码图片") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __block typeof(self) weakSelf = self;
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"从手机相册选择") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getInAlbum];
    }];
    [alertController addAction:alertAction1];
    UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"拍照") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getInCamera];
    }];
    [alertController addAction:alertAction2];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:alertController completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Text Field Delegate

- (IBAction)textFieldChange:(UITextField *)textField {
    if (TTIsStringWithAnyText(_tfName.text) && TTIsStringWithAnyText(_tfReceiptNo.text) ) {
        _btnConfirm.enabled = YES;
    }else{
        _btnConfirm.enabled = NO;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    switch (textField.tag) {
        case 1:
            [_tfName becomeFirstResponder];
            break;
        case 2:
            [_tfReceipt becomeFirstResponder];
            break;
        case 3:
            [_tfReceiptNo becomeFirstResponder];
            break;
        case 4:
            break;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSUInteger tag = [textField tag];
    [self animateView:tag];
    [toolBar checkBarButton:tag];
}

- (void)animateView:(NSUInteger)tag{

    float distance = 0;
    switch (tag) {
        case 1:
            distance = 0;
            break;
        case 2:
            distance = 80;
            break;
            
    }
    [_scrollView setContentOffset:CGPointMake(0.0, distance) animated:YES];
}


#pragma mark - Text Field Tool Bar Delegate Methods
- (void)TFAnimateView:(NSUInteger)tag{
}
- (void)TFDonePressed{
    [self viewTouchDown:nil];
}
#pragma mark - 从相册获取照片
- (void)getInAlbum{
    TZImagePickerController* imagePicker = [[[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES] autorelease];
    /**设置属性*/
    imagePicker.allowTakeVideo = NO;          //不允许内部视频
    imagePicker.allowTakePicture = YES;       //允许内部拍照
    imagePicker.allowPickingImage = YES;      //允许选择图片
    imagePicker.allowPickingVideo = NO;       //不允许选择视频
    imagePicker.showSelectedIndex = YES;
    imagePicker.allowCrop = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - TZImagePickerController delegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{

    self.img1 = [photos firstObject];
    _ivPhoto1.image = [photos firstObject];
    [self.view bringSubviewToFront:_ivPhoto1];
    [self reqSubmitImage:_img1];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 从相机获取照片
- (void)getInCamera
{
    UIImagePickerController* imagePicker = [[[UIImagePickerController alloc] init]autorelease];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate Methods
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    self.img1 = image;
    _ivPhoto1.image = image;
    [self.view bringSubviewToFront:_ivPhoto1];
    [self reqSubmitImage:_img1];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - reqIdentitySubmit
- (void)reqSubmitImage:(UIImage*)img
{
    if(!img){
        return;
    }
    [self showProgress:NSLocalizedStringForKey(@"提示") detailsText:NSLocalizedStringForKey(@"上传图片中")];
    NSString* fileName = [UIImage createOriginalImage:img userId:ROOTCONTROLLER_USER.userId];
    [[NetWorkManage shareSingleNetWork] reqUploadUserHeadUrlFile:self imageFile:fileName finishedCallback:@selector(reqSubmitImageFinished:) failedCallback:@selector(reqSavePaymentFailed:)];
}

- (void)reqSubmitImageFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *imageUrlList = [dataDic objectForKey:@"imageUrlList"];
        NSString* imgUrl = [NSString stringWithFormat:@"%@",[imageUrlList firstObject]];
        self.qrCodeUrl = imgUrl;
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

#pragma mark - 请求数据接口
- (void)reqSavePaymentData:(NSString*)receiptType paymentId:(NSString*)paymentId receiptName:(NSString*)receiptName receiptNo:(NSString*)receiptNo bankName:(NSString*)bankName qrCodeUrl:(NSString*)qrCodeUrl
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PSavePayment:self receiptType:receiptType paymentId:paymentId receiptName:receiptName receiptNo:receiptNo bankName:bankName qrCodeUrl:qrCodeUrl finishedCallback:@selector(reqSavePaymentFinished:) failedCallback:@selector(reqSavePaymentFailed:)];
    }
    
}

- (void)reqSavePaymentFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
    }
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_SUCCEED];
        self.view.userInteractionEnabled = NO;
        [self performSelector:@selector(goBack) withObject:nil afterDelay:1.0];
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }

}

- (void)reqSavePaymentFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}
@end
