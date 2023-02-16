//
//  TJRIntroductionController.m
//  TJRtaojinroad
//
//  Created by taojinroad on 6/2/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "TJRIntroductionController.h"
#import "PanelIntroFooter4.h"
#import "CommonUtil.h"

@interface TJRIntroductionController ()<PanelIntroDelegate>
{
    PanelIntroFooter4 *footerView4;
    BOOL bAboutUsIn;
}
@end

@implementation TJRIntroductionController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.canDragBack = NO;
    
    UIView *headerView1 = [[NSBundle mainBundle] loadNibNamed:@"Panel1Header" owner:nil options:nil][0];
    UIView *footerView1 = [[NSBundle mainBundle] loadNibNamed:@"PanelIntroFooter1" owner:nil options:nil][0];
    MYIntroductionPanel *panel1 = [[[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, phoneRectScreen.size.width, self.view.frame.size.height) title:nil description:nil footer:footerView1 header:headerView1] autorelease];
    panel1.PanelSeparatorLine.hidden = YES;
    
    UIView *headerView2 = [[NSBundle mainBundle] loadNibNamed:@"Panel2Header" owner:nil options:nil][0];
    UIView *footerView2 = [[NSBundle mainBundle] loadNibNamed:@"PanelIntroFooter2" owner:nil options:nil][0];
    MYIntroductionPanel *panel2 = [[[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, phoneRectScreen.size.width, self.view.frame.size.height) title:nil description:nil footer:footerView2 header:headerView2] autorelease];
    panel2.PanelSeparatorLine.hidden = YES;
   
    UIView *headerView3 = [[NSBundle mainBundle] loadNibNamed:@"Panel3Header" owner:nil options:nil][0];
    UIView *footerView3 = [[NSBundle mainBundle] loadNibNamed:@"PanelIntroFooter3" owner:nil options:nil][0];
    UIButton *introLoginButton = (UIButton *)[footerView3 viewWithTag:100];
    [introLoginButton addTarget:self action:@selector(introLoginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    MYIntroductionPanel *panel3 = [[[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, phoneRectScreen.size.width, self.view.frame.size.height) title:nil description:nil footer:footerView3 header:headerView3] autorelease];
    panel3.PanelSeparatorLine.hidden = YES;

//    UIView *headerView4 = [[NSBundle mainBundle] loadNibNamed:@"Panel4Header" owner:nil options:nil][0];
//    footerView4 = [[PanelIntroFooter4 alloc] initWithFrame:CGRectMake(0, 0, phoneRectScreen.size.width, phoneRectScreen.size.height/3) nibNamed:@"PanelIntroFooter4"];
//    footerView4.delegate = self;
//    MYIntroductionPanel *panel4 = [[[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, phoneRectScreen.size.width, self.view.frame.size.height) title:nil description:nil footer:footerView4 header:headerView4] autorelease];
//    panel4.PanelSeparatorLine.hidden = YES;
    
    NSArray *panels = @[panel1,panel2,panel3];
    
    
    MYBlurIntroductionView *introductionView = [[[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, phoneRectScreen.size.width, phoneRectScreen.size.height - STATUS_BAR_HEIGHT - IPHONEX_BOTTOM_HEIGHT)] autorelease];
    introductionView.delegate = self;
    introductionView.RightSkipButton.hidden = YES;
    [introductionView buildIntroductionWithPanels:panels];
    introductionView.PageControl.currentPageIndicatorTintColor = RGBA(255, 110, 39, 1.0);
    introductionView.PageControl.pageIndicatorTintColor = RGBA(236, 237, 245, 1.0);
    introductionView.PageControl.userInteractionEnabled = NO;
    [introductionView setBackgroundColor:RGBA(250, 249, 249, 1)];
    
    [self.view addSubview:introductionView];
    
    bAboutUsIn = NO;
    if ([self getValueFromModelDictionary:FeedbackDict forKey:@"aboutUsIn"]) {
        bAboutUsIn = YES;
        [self removeParamFromModelDictionary:FeedbackDict forKey:@"aboutUsIn"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)panelIntroLogin{
    [CommonUtil setPageToAnimation];
    
    if (bAboutUsIn) {
        [self goBackWithAnimated:NO];
    }else{
        [self pageToViewControllerForName:@"HomeViewController" animated:NO];
    }
    
}

#pragma mark - 按钮事件
- (void)introLoginButtonPressed:(UIButton *)sender
{
    [CommonUtil setPageToAnimation];
    
    if (bAboutUsIn) {
        [self goBackWithAnimated:NO];
    }else{
        [self pageToViewControllerForName:@"HomeViewController" animated:NO];
    }
}

#pragma mark - MYIntroduction Delegate

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    
}


- (void)dealloc{

    [footerView4 release];
    [super dealloc];
}


@end
