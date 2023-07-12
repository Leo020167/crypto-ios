//
//  MyOauthController.m
//  Redz
//
//  Created by taojinroad on 2018/11/21.
//  Copyright © 2018 淘金路. All rights reserved.
//

#import "MyOauthController.h"
#import "RZWebImageView.h"
#import "TextFieldToolBar.h"
#import "TJRBaseParserJson.h"
#import "NetWorkManage+User.h"
#import "NetWorkManage+File.h"
#import "CommonUtil.h"
#import "UIImage+Size.h"
#import "LoginSQLModel.h"
#import "TZImagePickerController.h"
#import "MyOauthPicAlertView.h"

#define TAG_HEAD    200
#define TAG_TAIL    201
#define TAG_HANDUP  202

@interface MyOauthController ()<TZImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    BOOL bReqFinished;
    MyOauthPicAlertView* myOauthPicAlertView;
    TextFieldToolBar* toolBar;
}

@property (retain, nonatomic) IBOutlet UIControl *bgView;
@property (retain, nonatomic) IBOutlet UITextField *tfName;
@property (retain, nonatomic) IBOutlet UITextField *tfNum;
@property (retain, nonatomic) IBOutlet RZWebImageView *ivCardHead;
@property (retain, nonatomic) IBOutlet RZWebImageView *ivCardTail;
@property (retain, nonatomic) IBOutlet UIButton *btnDone;
@property (retain, nonatomic) IBOutlet UIButton *btnCardHead;
@property (retain, nonatomic) IBOutlet UIButton *btnCardTail;
@property (retain, nonatomic) IBOutlet UIView *viewCardHead;
@property (retain, nonatomic) IBOutlet UIView *viewCardTail;
@property (retain, nonatomic) IBOutlet UILabel *lbStatusMsg;
@property (retain, nonatomic) IBOutlet UIView *statusBarView;
//@property (retain, nonatomic) IBOutlet TJRBaseTitleView *titleView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutStatusBarTop;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *layoutStatusBarHeight;

@property (retain, nonatomic) UIImage *imgCardHead;
@property (retain, nonatomic) UIImage *imgCardTail;

@property (copy, nonatomic) NSString *frontImgDemoUrl;
@property (copy, nonatomic) NSString *backImgDemoUrl;

/// 1正面 2反面
@property (nonatomic, assign) NSInteger type;

@end

@implementation MyOauthController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bReqFinished = YES;
    
    myOauthPicAlertView = [[MyOauthPicAlertView alloc]init];
    
    //添加toolbar
    toolBar = [[TextFieldToolBar alloc]initWithDelegate:self numOfTextField:2];
    _tfNum.inputAccessoryView = toolBar;
    _tfName.inputAccessoryView = toolBar;
    
    _statusBarView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT, phoneRectScreen.size.width, 30);
    _layoutStatusBarHeight.constant = 0;
    
    [self reqGetUserIdentity];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (IBAction)leftButtonClicked:(id)sender {
    [self goBack];
}

- (IBAction)cardHeadBtnClicked:(id)sender {
    [self takePicture:TAG_HEAD];
}

- (IBAction)cardTailBtnClicked:(id)sender {
    [self takePicture:TAG_TAIL];
}

- (IBAction)doneButtonClicked:(id)sender {
    if (_tfName.text.length < 1) {
        [self showToastCenter:NSLocalizedStringForKey(@"请输入有效姓名！")];
        return;
    }
    
    if (!checkIsStringWithAnyText(_tfNum.text)) {
        [self showToastCenter:NSLocalizedStringForKey(@"请输入身份证号码！")];
        return;
    }
    
    if(!checkIsStringWithAnyText(_frontImgDemoUrl)){
        [self showToastCenter:NSLocalizedStringForKey(@"请上传身份证人像页图片")];
        return;
    }
    if(!checkIsStringWithAnyText(_backImgDemoUrl)){
        [self showToastCenter:NSLocalizedStringForKey(@"请上传身份证国徽页图片")];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"是否资料确认无误？") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reqIdentitySubmit:_tfName.text certNo:_tfNum.text frontImgUrl:self.frontImgDemoUrl backImgUrl:self.backImgDemoUrl];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (IBAction)backgroundClicked:(id)sender {
    [_tfName resignFirstResponder];
    [_tfNum resignFirstResponder];
}

- (void)takePicture:(NSUInteger)tag{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"选择身份证照片") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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



#pragma mark - req data
- (void)reqGetUserIdentity
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqUserGetIdentityAuthen:self finishedCallback:@selector(reqGetIdentityFinished:) failedCallback:@selector(reqGetIdentityFailed:)];
    }
    
}

- (void)reqGetIdentityFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    
    if ([parser parseBaseIsOk:result]) {
        NSDictionary *dataDic = [result objectForKey:@"data"];
        NSDictionary *dic = [dataDic objectForKey:@"identityAuth"];

        if (dic) {
            _tfName.text = [parser stringParser:dic name:@"name"];
            _tfNum.text = [parser stringParser:dic name:@"certNo"];
            self.frontImgDemoUrl = [parser stringParser:dic name:@"frontImgUrl"];
            self.backImgDemoUrl = [parser stringParser:dic name:@"backImgUrl"];
            [_ivCardHead showImageWithUrl:self.frontImgDemoUrl];
            [_ivCardTail showImageWithUrl:self.backImgDemoUrl];

            [_ivCardHead setHidden:NO];
            [_ivCardTail setHidden:NO];
            
            self.imgCardHead = _ivCardHead.image;
            [_viewCardHead bringSubviewToFront:_ivCardHead];
            self.imgCardTail = _ivCardTail.image;
            [_viewCardTail bringSubviewToFront:_ivCardTail];
            
            NSInteger reviewState = [parser integerParser:dic name:@"state"];
            _lbStatusMsg.text = [NSString stringWithFormat:@"%@",[parser stringParser:dic name:@"stateDesc"]];
            if (reviewState == 2) {             //不通过
                _bgView.userInteractionEnabled = YES;
                _tfNum.enabled = YES;
                _tfName.enabled = YES;
                _btnCardHead.enabled = YES;
                _btnCardTail.enabled = YES;
                _btnDone.enabled = YES;
            }else if (reviewState == 1 || reviewState == 0) {             //通过或审核中
                _bgView.userInteractionEnabled = NO;
                ROOTCONTROLLER_USER.userRealName = _tfName.text;
                ROOTCONTROLLER_USER.idCertify = reviewState;
                [LoginSQLModel updateLoginInfo:ROOTCONTROLLER_USER];
                _tfNum.enabled = NO;
                _tfName.enabled = NO;
                _btnCardHead.enabled = NO;
                _btnCardTail.enabled = NO;
                _btnDone.enabled = NO;
            }
            if (TTIsStringWithAnyText(_lbStatusMsg.text)) {
                [self showBarView];
            }
        }else{
            _tfNum.enabled = YES;
            _tfName.enabled = YES;
            _btnCardHead.enabled = YES;
            _btnCardTail.enabled = YES;
            _btnDone.enabled = YES;
        }
        
    }else{
        NSString* str = @"";
        if ([result objectForKey:@"msg"]) {
            str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
        }
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_ERROR];
    }
}

- (void)reqGetIdentityFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark - reqIdentitySubmit
- (void)reqIdentitySubmit:(NSString*)name certNo:(NSString*)certNo frontImgUrl:(NSString*)frontImgUrl backImgUrl:(NSString*)backImgUrl
{
    if (bReqFinished) {
        bReqFinished = NO;
        [self showProgressDefaultText];
        [[NetWorkManage shareSingleNetWork] reqUserIdentitySubmit:self name:name certNo:certNo frontImgUrl:frontImgUrl backImgUrl:backImgUrl finishedCallback:@selector(reqIdentitySubmitFinished:) failedCallback:@selector(reqIdentitySubmitFailed:)];
    }
}

- (void)reqIdentitySubmitFinished:(id)result
{
    [self dismissProgress];
    bReqFinished = YES;
    
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    NSString* str = @"";
    if ([result objectForKey:@"msg"]) {
        str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];

    }
    if(!checkIsStringWithAnyText(str)){
        str = NSLocalizedStringForKey(@"操作成功");
    }
    if ([parser parseBaseIsOk:result]) {
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_SUCCEED];
        [self reqGetUserIdentity];
        _bgView.userInteractionEnabled = NO;
    }else{
        
        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_ERROR];
    }
}

- (void)reqIdentitySubmitFailed:(NSDictionary *)json
{
    bReqFinished = YES;
    [self dismissProgress];
    [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"请求失败") detailsMessage:NSLocalizedStringForKey(@"请检查网络") imageName:HUD_ERROR];
}

#pragma mark - reqIdentitySubmit
- (void)reqIdentifierSubmitFrontImage
{
    if(!_imgCardHead){
        return;
    }
    self.type = 1;
    [self showProgress:@"" detailsText:NSLocalizedStringForKey(@"上传图片中")];
    NSString* fileName = [UIImage createOriginalImage:_imgCardHead userId:ROOTCONTROLLER_USER.userId];
    [[NetWorkManage shareSingleNetWork] reqUploadUserCertificationFile:self imageFile:fileName finishedCallback:@selector(reqIdentifierSubmitFrontImageFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqIdentifierSubmitFrontImageFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *imageUrlList = [dataDic objectForKey:@"imageUrlList"];
        self.frontImgDemoUrl = [NSString stringWithFormat:@"%@",[imageUrlList firstObject]];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqIdentifierSubmitBackImage
{
    if(!_imgCardTail){
        return;
    }
    self.type = 2;
    [self showProgress:@"" detailsText:NSLocalizedStringForKey(@"上传图片中")];
    NSString* fileName = [UIImage createOriginalImage:_imgCardTail userId:ROOTCONTROLLER_USER.userId];
    [[NetWorkManage shareSingleNetWork] reqUploadUserCertificationFile:self imageFile:fileName finishedCallback:@selector(reqIdentifierSubmitBackImageFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqIdentifierSubmitBackImageFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSDictionary *dataDic = [json objectForKey:@"data"];
        NSArray *imageUrlList = [dataDic objectForKey:@"imageUrlList"];
        self.backImgDemoUrl = [NSString stringWithFormat:@"%@",[imageUrlList firstObject]];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

- (void)reqHttpRequestFailed:(NSDictionary *)json{
    if (self.type == 1) {
        self.ivCardHead.image = nil;
    }else if (self.type == 2){
        self.ivCardTail.image = nil;
    }
    [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
}

//- (void)reqIdentitySubmitFile:(NSString*)imgFile otherFile:(NSString*)otherFile videoFile:(NSString*)videoFile
//{
//    if (bReqFinished) {
//        bReqFinished = NO;
//        [self showProgressDefaultText];
//        [[NetWorkManage shareSingleNetWork] reqUploadUserIdentityFile:self imgFile:imgFile otherFile:otherFile videoFile:videoFile finishedCallback:@selector(reqIdentitySubmitFileFinished:) failedCallback:@selector(reqIdentitySubmitFailed:)];
//    }
//}
//
//- (void)reqIdentitySubmitFileFinished:(id)result
//{
//    bReqFinished = YES;
//
//    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
//
//
//    if ([parser parseBaseIsOk:result]) {
//        NSDictionary *dataDic = [result objectForKey:@"data"];
//        NSString* imgUrl = [parser stringParser:dataDic name:@"imgUrl"];
//        NSString* otherUrl = [parser stringParser:dataDic name:@"otherUrl"];
//        NSString* videoUrl = [parser stringParser:dataDic name:@"videoUrl"];
//        [self reqIdentitySubmit:_tfName.text certNo:_tfNum.text frontImgUrl:imgUrl backImgUrl:otherUrl holdImgUrl:videoUrl];
//
//    }else{
//        NSString* str = @"";
//        if ([result objectForKey:@"msg"]) {
//            str = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
//        }
//        [self showProgressHUDCompleteMessage:NSLocalizedStringForKey(@"提示") detailsMessage:str imageName:HUD_ERROR];
//    }
//}


#pragma mark - Text Field Delegate
- (IBAction)textFieldChange:(UITextField *)sender {
    if (TTIsStringWithAnyText(_tfName.text) && TTIsStringWithAnyText(_tfNum.text) && _imgCardHead && _imgCardTail) {
        _btnDone.enabled = YES;
    }else{
        _btnDone.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    switch (textField.tag) {
        case 1:
            [_tfName becomeFirstResponder];
            break;
        case 2:
            [_tfNum becomeFirstResponder];
            break;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSUInteger tag = [textField tag];
    [toolBar checkBarButton:tag];
}

#pragma mark - Text Field Tool Bar Delegate Methods
- (void)TFAnimateView:(NSUInteger)tag
{
}
- (void)TFDonePressed{
    [self backgroundClicked:nil];
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
        case TAG_HEAD:
        {
            self.imgCardHead = [photos firstObject];
            _ivCardHead.image = [photos firstObject];
            [_viewCardHead bringSubviewToFront:_ivCardHead];
            [self reqIdentifierSubmitFrontImage];           //请求上传
            break;
        }
        case TAG_TAIL:
        {
            self.imgCardTail = [photos firstObject];
            _ivCardTail.image = [photos firstObject];
            [_viewCardTail bringSubviewToFront:_ivCardTail];
            [self reqIdentifierSubmitBackImage];            //请求上传
            break;
        }
        default:
            break;
    }
    [self textFieldChange:nil];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 从相机获取照片
- (void)getInCamera:(NSUInteger)tag
{
    UIImagePickerController* imagePicker = [[[UIImagePickerController alloc] init]autorelease];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    imagePicker.view.tag = tag;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate Methods
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    switch (picker.view.tag) {
        case TAG_HEAD:
        {
            self.imgCardHead = image;
            _ivCardHead.image = image;
            [_viewCardHead bringSubviewToFront:_ivCardHead];
            [self reqIdentifierSubmitFrontImage];           //请求上传
            break;
        }
        case TAG_TAIL:
        {
            self.imgCardTail = image;
            _ivCardTail.image = image;
            [_viewCardTail bringSubviewToFront:_ivCardTail];
            [self reqIdentifierSubmitBackImage];            //请求上传
            break;
        }
        default:
            break;
    }
    [self textFieldChange:nil];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - status bar
- (void)showBarView{

    _layoutStatusBarHeight.constant = 0;
    
    [UIView animateWithDuration:0.4 animations:^{
        _layoutStatusBarHeight.constant = 30;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)hideBarView{

    _layoutStatusBarHeight.constant = 30;
    [UIView animateWithDuration:0.4 animations:^{
        _layoutStatusBarHeight.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [_statusBarView removeFromSuperview];
    }];
}

- (void)dealloc {
    [_frontImgDemoUrl release];
    [_backImgDemoUrl release];
    [myOauthPicAlertView release];
    [_imgCardHead release];
    [_imgCardTail release];
    [toolBar release];
    [_tfName release];
    [_tfNum release];
    [_ivCardHead release];
    [_ivCardTail release];
    [_btnDone release];
    [_btnCardHead release];
    [_btnCardTail release];
    [_bgView release];
    [_viewCardHead release];
    [_viewCardTail release];
    [_lbStatusMsg release];
    [_statusBarView release];
    [_layoutStatusBarTop release];
    [_layoutStatusBarHeight release];
    [super dealloc];
}
@end
