//
//  P2PAppealController.m
//  ProCoin
//
//  Created by UnWood on 2021/4/6.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "P2PAppealController.h"
#import "CommonUtil.h"
#import "TextFieldToolBar.h"
#import "NetWorkManage+P2P.h"
#import "TJRBaseParserJson.h"
#import "RZWebImageView.h"
#import "TZImagePickerController.h"
#import "NetWorkManage+File.h"
#import "UIImage+Size.h"

#define TAG_IMG_1    500
#define TAG_IMG_2    501

@interface P2PAppealController ()<UITextViewDelegate,TextFieldToolBarDelegate,TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    BOOL bReqFinished;
    TextFieldToolBar* toolBar;
    
    NSMutableArray* imgData;
}

@property (retain, nonatomic) IBOutlet UIButton *btnReason1;
@property (retain, nonatomic) IBOutlet UIButton *btnReason2;
@property (retain, nonatomic) IBOutlet UIButton *btnReason3;
@property (retain, nonatomic) IBOutlet UIButton *btnReason4;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet RZWebImageView *ivPhoto1;
@property (retain, nonatomic) IBOutlet RZWebImageView *ivPhoto2;
@property (retain, nonatomic) IBOutlet UITextView *tvContent;
@property (retain, nonatomic) IBOutlet UILabel *lbContentTips;
@property (retain, nonatomic) IBOutlet UIButton *btnConfirm;

@property (retain, nonatomic) UIImage *img1;
@property (retain, nonatomic) UIImage *img2;

@property (copy, nonatomic) NSString *orderId;
@end

@implementation P2PAppealController

- (void)viewDidLoad {
    [super viewDidLoad];

    //添加toolbar
    toolBar = [[TextFieldToolBar alloc]initWithDelegate:self numOfTextField:1];
    _tvContent.inputAccessoryView = toolBar;

    imgData = [[NSMutableArray alloc]init];
    
    bReqFinished = YES;
    
    if([self getValueFromModelDictionary:P2PDict forKey:@"orderId"]){
        self.orderId = [self getValueFromModelDictionary:P2PDict forKey:@"orderId"];
        [self removeParamFromModelDictionary:P2PDict forKey:@"orderId"];
    }
    if (TTIsStringWithAnyText(_orderId)) {
        [self reqFindReasonList:_orderId];
    }
}

- (void)dealloc{
    [_orderId release];
    [imgData release];
    [_btnReason1 release];
    [_btnReason2 release];
    [_btnReason3 release];
    [_btnReason4 release];
    [_scrollView release];
    [_ivPhoto1 release];
    [_ivPhoto2 release];
    [_tvContent release];
    [_btnConfirm release];
    [_lbContentTips release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}
- (IBAction)photo1BtnClicked:(id)sender {
    [self takePicture:TAG_IMG_1];
}
- (IBAction)photo2BtnClicked:(id)sender {
    [self takePicture:TAG_IMG_2];
}
- (IBAction)confirmBtnClicked:(id)sender {
    bool selected = NO;
    NSString* reason = @"";
    for (int i = 0; i< 4; i++) {
        UIButton* btn = (UIButton*)[self.view viewWithTag:100 + i];
        UILabel* lb = (UILabel*)[self.view viewWithTag:50 + i];
        if (btn.selected) {
            selected = YES;
            reason = lb.text;
            break;
        }
    }
    if (!selected) {
        [self showToast:NSLocalizedStringForKey(@"请选择申诉原因")];
        return;
    }
    
    NSString* img1 = @"";
    NSString* img2 = @"";
    if (imgData.count>=1) img2 = [imgData objectAtIndex:1];
    if (imgData.count>0) img1 = [imgData objectAtIndex:0];
    
    [self viewTouchDown:nil];
    
    [self reqAppealSubmitData:_orderId reason:reason image1Url:img1 image2Url:img2 message:_tvContent.text];
}

- (IBAction)reasonTouchDown:(id)sender {
    for (int i = 100; i< 104; i++) {
        UIButton* btn = (UIButton*)[self.view viewWithTag:i];
        btn.selected = NO;
    }
    UIButton* btn = (UIButton*)sender;
    btn.selected = YES;
}

//触摸背景收起键盘
- (IBAction)viewTouchDown:(id)sender {
    [_tvContent resignFirstResponder];
    [_scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)takePicture:(NSUInteger)tag{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"选择截图") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __block typeof(self) weakSelf = self;
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"从手机相册选择") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getInAlbum:tag];
    }];
    [alertController addAction:alertAction1];
    UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"拍照") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getInCamera:tag];
    }];
    [alertController addAction:alertAction2];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:alertController completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    switch (textField.tag) {
        case 1:
            [_tvContent becomeFirstResponder];
            break;
        case 2:
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
            distance = 250;
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

#pragma mark - text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSUInteger tag = [textView tag];
    [self animateView:tag];
}

- (void)textViewDidChange:(UITextView *)textView{
    _lbContentTips.hidden = textView.text.length>0;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self viewTouchDown:nil];
        return NO;
    }
    return YES;
}

#pragma mark - 从相册获取照片
- (void)getInAlbum:(NSUInteger)tag{
    TZImagePickerController* imagePicker = [[[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES] autorelease];
    /**设置属性*/
    imagePicker.allowTakeVideo = NO;          //不允许内部视频
    imagePicker.allowTakePicture = YES;       //允许内部拍照
    imagePicker.allowPickingImage = YES;      //允许选择图片
    imagePicker.allowPickingVideo = NO;       //不允许选择视频
    imagePicker.showSelectedIndex = YES;
    imagePicker.allowCrop = NO;
    imagePicker.view.tag = tag;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - TZImagePickerController delegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{

    switch (picker.view.tag) {
        case TAG_IMG_1:
        {
            self.img1 = [photos firstObject];
            _ivPhoto1.image = [photos firstObject];
            [self.view bringSubviewToFront:_ivPhoto1];
            [self reqSubmitImage:_img1];
            break;
        }
        case TAG_IMG_2:
        {
            self.img2 = [photos firstObject];
            _ivPhoto2.image = [photos firstObject];
            [self.view bringSubviewToFront:_ivPhoto2];
            [self reqSubmitImage:_img2];
            break;
        }
        default:
            break;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 从相机获取照片
- (void)getInCamera:(NSUInteger)tag
{
    UIImagePickerController* imagePicker = [[[UIImagePickerController alloc] init]autorelease];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.view.tag = tag;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate Methods
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    switch (picker.view.tag) {
        case TAG_IMG_1:
        {
            self.img1 = image;
            _ivPhoto1.image = image;
            [self.view bringSubviewToFront:_ivPhoto1];
            [self reqSubmitImage:_img1];
            break;
        }
        case TAG_IMG_2:
        {
            self.img2 = image;
            _ivPhoto2.image = image;
            [self.view bringSubviewToFront:_ivPhoto2];
            [self reqSubmitImage:_img2];
            break;
        }
        default:
            break;
    }
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
    [[NetWorkManage shareSingleNetWork] reqUploadUserHeadUrlFile:self imageFile:fileName finishedCallback:@selector(reqSubmitImageFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqSubmitImageFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *imageUrlList = [dataDic objectForKey:@"imageUrlList"];
        NSString* imgUrl = [NSString stringWithFormat:@"%@",[imageUrlList firstObject]];
        if (TTIsStringWithAnyText(imgUrl)) {
            [imgData insertObject:imgUrl atIndex:0];
        }
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

#pragma mark - 请求数据接口
- (void)reqAppealSubmitData:(NSString*)orderId reason:(NSString*)reason image1Url:(NSString*)image1Url image2Url:(NSString*)image2Url message:(NSString*)message
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PAppealSubmit:self orderId:orderId reason:reason image1Url:image1Url image2Url:image2Url message:message  finishedCallback:@selector(reqAppealSubmitFinished:) failedCallback:@selector(reqAppealSubmitFailed:)];
    }
    
}

- (void)reqAppealSubmitFinished:(id)result
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

- (void)reqAppealSubmitFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark - 【申诉】初始化申诉理由列表
- (void)reqFindReasonList:(NSString*)orderId
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqP2PGetInitReasonList:self orderId:orderId finishedCallback:@selector(reqReasonListFinished:) failedCallback:@selector(reqReasonListFailed:)];
    }
    
}

- (void)reqReasonListFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    if([parser parseBaseIsOk:result]){

        for (int i = 0; i< 4; i++) {
            UIView* view = (UIView*)[self.view viewWithTag:400+i];
            view.hidden = YES;
        }
        
        NSArray *list= [result objectForKey:@"data"];
        for (int i = 0; i< list.count; i++) {
            NSString* reason = [list objectAtIndex:i];
            if (i>4) break;
            UILabel* lbReason = (UILabel*)[self.view viewWithTag:50+i];
            lbReason.text = reason;
            UIView* view = (UIView*)[self.view viewWithTag:400+i];
            view.hidden = NO;
        }
        
    }else{
        [self showErrorToastCenter:result defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqReasonListFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}
@end
