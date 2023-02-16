//
//  LanguageViewController.m
//  Encropy
//
//  Created by taojinroad on 2019/4/17.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "LanguageViewController.h"
#import "LanguageManager.h"
#import "LanguageTableViewCell.h"
#import "CommonUtil.h"


@interface LanguageViewController (){
    
    NSArray *languageData;
    NSArray *languagecountryCodes;
    NSString *languageString;
    NSString *languageCode;
}

@property (retain, nonatomic) IBOutlet UILabel *lbViewTitle;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIButton *btnOK;
@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    languageData = [LanguageManager languageStrings];
    languagecountryCodes = [LanguageManager languageCountryCodes];
    languageString = [LanguageManager currentLanguageString];
    languageCode = [LanguageManager currentLanguageCode];
    
    _lbViewTitle.text = NSLocalizedStringForKey(@"设置语言");
    [_btnOK setTitle:NSLocalizedStringForKey(@"保存語言設置") forState:UIControlStateNormal];
    
    [CommonUtil setExtraCellLineHidden:_tableView];
}

- (IBAction)leftButtonClicked:(id)sender {
    //不保存，直接退出
    if(TTIsStringWithAnyText(languageCode)){
        [LanguageManager saveLanguageByCode:languageCode];
    }
    [self goBack];
}

#pragma mark - 手势滑动返回时,如果不是pop到上一个页面时,调用
- (void)gestureDragBack {
    //不保存，直接退出
    if(TTIsStringWithAnyText(languageCode)){
        [LanguageManager saveLanguageByCode:languageCode];
    }
}

- (IBAction)safeButtonClicked:(id)sender {
    [CommonUtil setPageToAnimation];
    [[self getTJRAppDelegate].navigation popToRootViewControllerAnimated:NO];
    [self pageToOrBackWithName:@"HomeViewController" animated:NO];
}

#pragma mark -
#pragma mark - table view delegate and data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 10)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ELanguageCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LanguageCellIdentifier";
    LanguageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LanguageTableViewCell" owner:nil options:nil] lastObject];
    }
    NSString *code = languagecountryCodes[indexPath.row];
    [cell setLanguageName:languageData[indexPath.row] image:code andIsSelected:indexPath.row == [LanguageManager currentLanguageIndex]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [LanguageManager saveLanguageByIndex:indexPath.row];
    _btnOK.enabled = ![languageString isEqualToString:languageData[indexPath.row]];
    [_tableView reloadData];
}


- (void)dealloc {
    [_lbViewTitle release];
    [_tableView release];
    [_btnOK release];
    [super dealloc];
}
@end
