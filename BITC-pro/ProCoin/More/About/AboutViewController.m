//
//  AboutViewController.m
//  Redz
//
//  Created by Taojin on 2018/6/12.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "AboutViewController.h"
#import "UIScrollView+AllowPanGestureEventPass.h"
#import "LoginBase.h"
#import "CommonUtil.h"
#import "TYWebViewController.h"

@interface AboutViewController ()
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSString* version;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.bounces = NO;
    [_tableView setScreenEdgePanGestureRecognizerPriority];
    _version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)leftButtonClicked:(UIButton *)sender {
    [self goBack];
}


#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"AboutHeaderView" owner:self options:nil] lastObject];
    
    UILabel *lable = (UILabel *)[headerView viewWithTag:101];
    lable.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedStringForKey(@"当前版本"), _version];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"AboutHeaderView" owner:self options:nil] lastObject];
    return headerView.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    BOOL bShowDefault = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isShowDefault"] boolValue];
    return bShowDefault?2:1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[[NSBundle mainBundle]loadNibNamed:@"AboutTableViewCell" owner:self options:nil] lastObject];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    NSString *identifier = @"AboutCellIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AboutTableViewCell" owner:self options:nil] lastObject];
    }

    UILabel *lable = (UILabel *)[cell viewWithTag:101];
    
    switch (indexPath.row) {
        case 0:
            lable.text = NSLocalizedStringForKey(@"服务条款");
            break;
        case 1:
            lable.text = NSLocalizedStringForKey(@"欢迎页");
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {// 服务条款
                TYWebViewController *web = [[TYWebViewController alloc] init];
                web.url = URL_SERVICE_PROTOCOL;
                [QMUIHelper.visibleViewController.navigationController pushViewController:web animated:YES];
            }
            break;
        case 1: // 欢迎页
            [self panelIntroLogin];
            break;
        default:
            break;
    }
    
}

- (void)panelIntroLogin{
    [CommonUtil setPageToAnimation];
    [self putValueToParamDictionary:FeedbackDict value:[NSNumber numberWithBool:YES] forKey:@"aboutUsIn"];
    [self pageToViewControllerForName:@"TJRIntroductionController" animated:NO];
}

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
@end
