//
//  WelcomeViewController.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-8-30.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "WelcomeViewController.h"
#import "TJRCache.h"
#import "LoginViewController.h"
#import "TJRImageAndDownFile.h"
#import "TJRBaseParserJson.h"
#import "TTCacheManager.h"

#import "LoginSQLModel.h"
#import "NetWorkManage+Home.h"
#import "NetWorkManage+Security.h"
#import "CommonUtil.h"

#define MAX_TIMEOUT 2

#define WELCOME_AD_URL_KEY @"WELCOME_AD_URL_KEY"

#define DYNAMIC_DNS_CACHE_KEY       @"DYNAMIC_DNS_CACHE_KEY"

@interface WelcomeViewController (){
    NSTimer* timer;
    NSInteger timerCount;
    BOOL bReqFinished;
}

@property (retain, nonatomic) IBOutlet TJRImageAndDownFile *downView;
@property (retain, nonatomic) IBOutlet UIView *tipsView;
@property (retain, nonatomic) IBOutlet UILabel *lbSecond;
@property (copy, nonatomic) NSString *pview;
@property (copy, nonatomic) NSString *params;
@end

@implementation WelcomeViewController
@synthesize indicatorImageView;
@synthesize bgImageView = _bgImageView;

- (void)dealloc {
    [_params release];
    [_pview release];
    [loginBase release];
    [indicatorImageView release];
    [_bgImageView release];
    [_lbSecond release];
    [_downView release];
    [_tipsView release];
    [super dealloc];
}

- (void)viewDidUnload {
    TT_RELEASE_SAFELY(loginBase);
    [self setIndicatorImageView:nil];
    [self setBgImageView:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    //[self setAnimationImage];
    [super viewDidLoad];
    isShow = NO;
    self.canDragBack = NO;
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSArray *launchImagesArr = infoDict[@"UILaunchImages"];
    NSMutableDictionary* keyDic = [[[NSMutableDictionary alloc]init]autorelease];
    for (NSDictionary * dic in launchImagesArr) {
        CGSize size = CGSizeFromString([dic objectForKey:@"UILaunchImageSize"]);
        NSString* strKey = [NSString stringWithFormat:@"%dx%d",(int)size.width,(int)size.height];
        NSString* strName = [NSString stringWithFormat:@"%@",[dic objectForKey:@"UILaunchImageName"]];
        if (TTIsStringWithAnyText(strKey)&& TTIsStringWithAnyText(strName)) {
            [keyDic setValue:strName forKey:strKey];
        }
    }
    NSString * key = [NSString stringWithFormat:@"%dx%d",(int)[UIScreen mainScreen].bounds.size.width, (int)[UIScreen mainScreen].bounds.size.height];
    UIImage * launchImage = [UIImage imageNamed:keyDic[key]];
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.bgImageView setImage:launchImage];
    
    loginBase = [[LoginBase alloc] init];
    loginBase.lbDelegate = self;
    
    timerCount = MAX_TIMEOUT;
    bReqFinished = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched:)];
    [tapGestureRecognizer setDelegate:self];
    [self.bgImageView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [indicatorImageView stopAnimating];
    [UIApplication sharedApplication].statusBarHidden = NO;    // 隐藏状态栏
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!isShow) {
        isShow = YES;
        [UIApplication sharedApplication].statusBarHidden = YES;// 隐藏状态栏
        [self loadAD];
        
//        NSString *dynamicDNSCacheJsonString = [[NSUserDefaults standardUserDefaults] objectForKey:DYNAMIC_DNS_CACHE_KEY];
//        if(checkIsStringWithAnyText(dynamicDNSCacheJsonString)){
//            /**如果存在缓存，则先进app，再请求重新赋值缓存*/
//            NSDictionary *dataDic = [CommonUtil jsonValue:dynamicDNSCacheJsonString];
//            [[NetWorkManage shareSingleNetWork] parserDynamicDNS:dataDic];
//
//            [self reqDynamicDNS];
//        }else{
//            [self reqDynamicDNS];
//        }
    }
    
}

- (void)loadAD
{
    
    [self requestADData];
    
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    if ([userInfo objectForKey:WELCOME_AD_URL_KEY]){
        [self startAD:[userInfo objectForKey:WELCOME_AD_URL_KEY]];
    }else{
        [self login];
    }
}

- (IBAction)skipButtonClicked:(id)sender {
    [self finish];
}

#pragma mark - 登陆
- (void)login
{
    [loginBase getUserLoginInfoFromSQL];

    [CommonUtil setPageToAnimation];
    
    if (TJRIsIntroduction) {
        NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
        if ([userInfo objectForKey:[NSString stringWithFormat:@"introduction_version_%@",TJRAppVersion]]) {
            
            [self pageToViewControllerForName:@"HomeViewController" animated:NO];
        }else{
            [self pageToViewControllerForName:@"TJRIntroductionController" animated:NO];
        }
    }else{
        [self pageToViewControllerForName:@"HomeViewController" animated:NO];
    }
    
//    // 从数据库获取是否有登陆信息
//    if ([loginBase getUserLoginInfoFromSQL]) {
//        if ((ROOTCONTROLLER_USER.userAccount.length == 0) || (ROOTCONTROLLER_USER.password.length == 0)) {
//            [CommonUtil setPageToAnimation];
//            [self pageToViewControllerForName:@"LoginViewController" animated:NO];
//        } else {// 存在用户登陆信息
//            [CommonUtil setPageToAnimation];
//
//            BOOL bShowDefault = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isShowDefault"] boolValue];
//            if (TJRIsIntroduction && bShowDefault) {
//                NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
//                if ([userInfo objectForKey:[NSString stringWithFormat:@"introduction_version_%@",TJRAppVersion]]) {
//
//                    [self pageToViewControllerForName:@"HomeViewController" animated:NO];
//                }else{
//                    [self pageToViewControllerForName:@"TJRIntroductionController" animated:NO];
//                }
//            }else{
//                [self pageToViewControllerForName:@"HomeViewController" animated:NO];
//            }
//
//        }
//    }else {
//        //不存在登陆信息
//        [CommonUtil setPageToAnimation];
//        [self pageToViewControllerForName:@"LoginViewController" animated:NO];
//
//    }
}


// 设置指示器
- (void)setAnimationImage {
    UIImage *first = [UIImage imageNamed:@"welcome_animation_first_frame"];
    UIImage *second = [UIImage imageNamed:@"welcome_animation_second_frame"];
    UIImage *third = [UIImage imageNamed:@"welcome_animation_third_frame"];
    
    indicatorImageView.animationImages = [NSArray arrayWithObjects:first, second, third, nil];
    indicatorImageView.animationDuration = 3.0;
    indicatorImageView.animationRepeatCount = 0;
    [indicatorImageView startAnimating];
}

#pragma mark - 定时器 统计超时
- (void)startTimer{
    [self closeTimer];
    if (timer == nil) {
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeoutCalculater) userInfo:nil repeats:YES];
    }
}

- (void)closeTimer{
    @synchronized(timer) {
        if (timer && timer.isValid) {
            [timer invalidate];
            timer = nil;
        }
    }
}

- (void)timeoutCalculater{
    
    _lbSecond.text = [NSString stringWithFormat:@"%ld S",(long)timerCount];
    timerCount--;
    if (timerCount<0) {
        [self finish];
    }
}

- (void)finish{
    timerCount = 0;
    [self closeTimer];
    [self login];
}

#pragma mark - 请求广告列表
- (void)requestADData
{
    if(bReqFinished)
    {
        bReqFinished = NO;
        
        TJRUser *u = [LoginSQLModel selectLoginInfo];
        NSString* userId = u.userId.length>0?u.userId:@"";
        NSString* token = u.token.length>0?u.token:@"";
        
        [[NetWorkManage shareSingleNetWork] reqADInfo:self userId:userId token:token finishedCallback:@selector(reqADDataFinished:) failedCallback:@selector(reqADDataFailed:)];
    }
}

- (void)reqADDataFinished:(id)result
{
    bReqFinished = YES;
    TJRBaseParserJson* jsonParser = [[[TJRBaseParserJson alloc]init]autorelease];
    
    if ([jsonParser parseBaseIsOk:result]) {
        
        NSDictionary* dic = [result objectForKey:@"data"];
        
        NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
        [userInfo removeObjectForKey:WELCOME_AD_URL_KEY];
        
        NSString* logoUrl = [dic objectForKey:@"imgUrl"];
        self.params = [dic objectForKey:@"params"];
        self.pview = [dic objectForKey:@"pview"];
        
        if (logoUrl.length>0) {
            [_downView showImageViewWithURL:logoUrl];
            [userInfo setObject:logoUrl forKey:WELCOME_AD_URL_KEY];
        }
        
    }
}

- (void)reqADDataFailed:(id)result
{
    bReqFinished = YES;
}

- (void)startAD:(NSString*)url{
    
    if (url.length>0) {
        NSData *data = [TTCacheManager dataForURL:url];
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            self.bgImageView.image = image;
            [self startTimer];
            self.tipsView.hidden = NO;
        }else{
            [self login];
        }
    }else{
        [self login];
    }
}

//#pragma mark - 请求动态接口
//- (void)reqDynamicDNS
//{
//    [[NetWorkManage shareSingleNetWork] reqAppDynamicDNS:self finishedCallback:@selector(reqDynamicDNSFinished:) failedCallback:@selector(reqDynamicDNSFailed:)];
//}
//
//- (void)reqDynamicDNSFinished:(NSDictionary *)json
//{
//    if([self checkJsonIsSuccess:json]){
//        NSDictionary *dataDic = [json objectForKey:@"data"];
//        NSString *dynamicDNSCacheJsonString = [[NSUserDefaults standardUserDefaults] objectForKey:DYNAMIC_DNS_CACHE_KEY];
//        if(checkIsStringWithAnyText(dynamicDNSCacheJsonString)){
//            /**如果存在缓存，则判断新的内容跟缓存是否一样，一样就不做任何操作，不一样就重新保存*/
//            if(![[CommonUtil jsonToString:dataDic] isEqualToString:dynamicDNSCacheJsonString]){
//                [[NSUserDefaults standardUserDefaults] setObject:[CommonUtil jsonToString:dataDic] forKey:DYNAMIC_DNS_CACHE_KEY];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
//        }else{
//            //如果之前没缓存，则写入缓存并跳转页面
//            [[NSUserDefaults standardUserDefaults] setObject:[CommonUtil jsonToString:dataDic] forKey:DYNAMIC_DNS_CACHE_KEY];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            [[NetWorkManage shareSingleNetWork] parserDynamicDNS:dataDic];
//            [self loadAD];
//        }
//
//    }
//}
//
//- (void)reqDynamicDNSFailed:(NSDictionary *)json
//{
//    [self performSelector:@selector(reqDynamicDNS) withObject:nil afterDelay:3.0];
//}

- (void)backgroundTouched:(UIGestureRecognizer*)recognizer{
    if (_pview.length){
        self.bgImageView.userInteractionEnabled = NO;
        
        [self putValueToParamDictionary:LoginDict value:[NSNumber numberWithBool:YES] forKey:@"WelcomeADClicked"];
        [self putValueToParamDictionary:LoginDict value:_pview forKey:@"WelcomeADPview"];
        [self putValueToParamDictionary:LoginDict value:_params forKey:@"WelcomeADParams"];
        [self finish];
    }
}

#pragma mark - rotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end

