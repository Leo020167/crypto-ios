//
//  MyHomeTableView.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-7.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "MyHomeTableView.h"
#import "RAJudgement.h"
#import "CommonUtil.h"
#import "MyHomeViewController.h"
    
#define     TitleColor          [UIColor colorWithRed:249.0f/255.0f green:249.0f/255.0f blue:249.0f/255.0f alpha:1.0f]
#define     SubTitleColor       [UIColor colorWithRed:132.0f/255.0f green:132.0f/255.0f blue:132.0f/255.0f alpha:1.0f]

#define MyHomeBaseInfoCellIcon 300
#define MyHomeBaseInfoCellTitle 301
#define MyHomeBaseInfoCellContent 302


@implementation MyHomeTableView
@synthesize user;
@synthesize mhDelegate;
@synthesize headImageView;
@synthesize myNameTextField;
@synthesize responderController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization{
    self.delegate = self;
    self.dataSource = self;
    self.separatorColor = TitleColor;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    //图片缩放对象
    imageFocus = [[PicScalingFocus alloc]init];
    imageFocus.delegate = self;
    
}

- (void)dealloc
{
    [myNameTextField release];
    [user release];
    [headImageView release];
    [imageFocus release];
    [responderController release];
    [super dealloc];
}

#pragma mark -
#pragma mark - Table View Data Source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) return 144;
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) return 5;
    if (section == 1) return 1;
    
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        
    UITableViewCell *cell = nil;
    NSInteger row = [indexPath row];
    
    static NSString *identifierHeadImageCell = @"MyHomeHeadImageCellIdentifier";
    static NSString *identifierBaseInfoCel = @"MyHomeBaseInfoCellIdentifier";
    static NSString *identifierEditName = @"MyHomeEditNameCellIdentifier";
    static NSString *identifierNoEdit = @"MyHomeNoEditNameCellIdentifier";
    static NSString *identifierDesc = @"MyHomeDescInfoCellIdentifier";

    if (indexPath.section == 0) {
        
        switch (row) {
            case 0: { //用户头像
                cell = [tableView dequeueReusableCellWithIdentifier:identifierHeadImageCell];
                if(cell == nil){
                    cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"MyHomeHeadImageCell" owner:nil options:nil] lastObject];
                }
                UILabel *lbTitle = (UILabel *)[cell viewWithTag:101];
                lbTitle.text = NSLocalizedStringForKey(@"头像");
                RZWebImageView *tempHeadView = (RZWebImageView *)[cell viewWithTag:999];
                self.headImageView = tempHeadView;
                [imageFocus.focusManager installOnView:tempHeadView];
                [tempHeadView showImageWithUrl:user.headurl];
            }
                break;
            case 1:{   //名字

                    cell = [tableView dequeueReusableCellWithIdentifier:identifierEditName];
                    if (cell == nil) {
                        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"MyHomeEditNameCell" owner:nil options:nil] lastObject];

                        UITextField *nameTextField = (UITextField *)[cell viewWithTag:521];
                        nameTextField.delegate = self;
                        [nameTextField addTarget:self action:@selector(saveName:) forControlEvents:UIControlEventEditingDidEndOnExit];
                        [nameTextField addTarget:self action:@selector(saveName:) forControlEvents:UIControlEventEditingDidEnd];
                    }
                    UILabel *lbTitle = (UILabel *)[cell viewWithTag:101];
                    lbTitle.text = NSLocalizedStringForKey(@"昵称");
                    UITextField *nameTextField = (UITextField *)[cell viewWithTag:521];
                    self.myNameTextField = nameTextField;
                    if ([RAJudgement isContainNull:user.name]) user.name = @"";
                    myNameTextField.text = user.name;
                }
                break;
            case 2:{ // 用户ID
                cell = [tableView dequeueReusableCellWithIdentifier:identifierNoEdit];
                if(cell == nil){
                    cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"MyHomeNoEditNameCell" owner:nil options:nil] lastObject];
                    UILabel *lbContent = (UILabel *)[cell viewWithTag:100];
                    UILabel *lbTitle = (UILabel *)[cell viewWithTag:101];
                    lbTitle.text = @"ID";
                    lbContent.text = ROOTCONTROLLER_USER.userId;
                }
            }
                break;

            case 3:{         //性别
                cell = [tableView dequeueReusableCellWithIdentifier:identifierBaseInfoCel];
                if(cell == nil){
                    cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"MyHomeBaseInfoCell" owner:nil options:nil] lastObject];
                }
                
                UILabel *lbTitle = (UILabel *)[cell viewWithTag:MyHomeBaseInfoCellTitle];
                UILabel *lbContent = (UILabel *)[cell viewWithTag:MyHomeBaseInfoCellContent];
                lbTitle.text = NSLocalizedStringForKey(@"性别");
                NSString *sex = @"";
                if ([user.sex isEqualToString:@"0"])
                    sex = NSLocalizedStringForKey(@"女");
                else if([user.sex isEqualToString:@"1"])
                    sex = NSLocalizedStringForKey(@"男");
                lbContent.text = sex;
            }
                break;
            case 4:{         //生日
                cell = [tableView dequeueReusableCellWithIdentifier:identifierBaseInfoCel];
                if(cell == nil){
                    cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"MyHomeBaseInfoCell" owner:nil options:nil] lastObject];
                }
                
                UILabel *lbTitle = (UILabel *)[cell viewWithTag:MyHomeBaseInfoCellTitle];
                UILabel *lbContent = (UILabel *)[cell viewWithTag:MyHomeBaseInfoCellContent];
                lbTitle.text = NSLocalizedStringForKey(@"生日");
                if ([RAJudgement isContainNull:user.birthday])
                    user.birthday = @"";
                lbContent.text = user.birthday;
            }
                break;
            default:
                break;
        }
    }else if(indexPath.section == 1) {
        
        
        switch (row) {
            case 0:{    //个性签名
                cell = [tableView dequeueReusableCellWithIdentifier:identifierDesc];
                if(cell == nil){
                    cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"MyHomeDescInfoCell" owner:nil options:nil] lastObject];
                }
                
                UILabel *lbTitle = (UILabel *)[cell viewWithTag:100];
                UILabel *lbContent = (UILabel *)[cell viewWithTag:101];
                
                lbTitle.text = NSLocalizedStringForKey(@"个人简介");
                if([RAJudgement isContainNull:user.selfDescription])
                    user.selfDescription = @"";
                lbContent.text = user.selfDescription;
            }
                break;
            default:
                break;
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        //姓名
        [myNameTextField becomeFirstResponder];
    }else {
        [myNameTextField resignFirstResponder];
        if ([mhDelegate respondsToSelector:@selector(MHTableView:didSelectRowAtIndexPath:)])
            [mhDelegate MHTableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)saveName:(id)sender{
    UITextField *t = (UITextField*)sender;
    
    if (![user.name isEqualToString:t.text]) {
        if ([mhDelegate respondsToSelector:@selector(MHIsChanged:)]) {
            [mhDelegate MHIsChanged:YES];
        }
    }
    //编辑结束
    if([mhDelegate respondsToSelector:@selector(nameTextFieldShouldEditingDidEnd)]){
        [mhDelegate nameTextFieldShouldEditingDidEnd];
    }
    user.name = t.text;
}

#pragma mark - textField delegate 
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    //编辑开始
    if([mhDelegate respondsToSelector:@selector(nameTextFieldShouldBeginEditing)]){
        [mhDelegate nameTextFieldShouldBeginEditing];
    }
    return YES;
}

#pragma mark - FocusDelegate
- (UIImage *)picScalingFocus:(PicScalingFocus *)focus onTouchPic:(UIView *)view
{
    MyHomeViewController *homeViewControoler = (MyHomeViewController *)mhDelegate;
    homeViewControoler.canDragBack = NO;
    if (user.maxHeadUrl.length>0) {
        focus.picPath = user.maxHeadUrl;
    }
    return ((RZWebImageView *)view).image;
}

- (void)picScalingFocus:(PicScalingFocus *)focus downloadFile:(UIView *)view{
    if (user.maxHeadUrl.length>0) {
        [focus loadImageWithURL:user.maxHeadUrl];
    }
}

- (void)focusManagerUninstall
{
    MyHomeViewController *homeViewControoler = (MyHomeViewController *)mhDelegate;
    homeViewControoler.canDragBack = YES;
}

@end
