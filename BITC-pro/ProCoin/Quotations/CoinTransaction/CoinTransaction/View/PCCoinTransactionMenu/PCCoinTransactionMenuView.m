//
//  PCCoinTransactionMenuView.m
//  ProCoin
//
//  Created by Hay on 2020/2/26.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCCoinTransactionMenuView.h"

@interface PCCoinTransactionMenuView ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (assign, nonatomic) id<PCCoinTransactionMenuViewDelegate> delegate;

@property (retain, nonatomic) UITableView *dataTableView;

@property (copy, nonatomic) NSArray *titleArray;            //标题数组
@property (assign, nonatomic) CGSize unitSize;                  //选项size
@property (retain, nonatomic) UIFont *menuFont;             //选项字体
@property (retain, nonatomic) UIColor *menuColor;           //选项颜色

@property (assign, nonatomic) CGRect startFrame;            //弹出位置

@end

@implementation PCCoinTransactionMenuView


- (instancetype _Nullable)initTransactionView:(id)delegate titleArray:(NSArray<NSString *>  *_Nonnull)titleArray menuUnitSize:(CGSize)size menuFont:(UIFont * _Nullable)font menuFontColor:(UIColor * _Nullable)fontColor
{
    self = [super init];
    if(self){
        self.delegate = delegate;
        self.titleArray = titleArray;
        self.unitSize = size;
        self.menuFont = font;
        self.menuColor = fontColor;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;        //必须设置，否则不能透明

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTapEvent:)] autorelease];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    self.view.backgroundColor = RGBA(0, 0, 0, 0.2);
}

- (void)dealloc
{
    [[self.view layer] removeAllAnimations];
    [_dataTableView release];
    [_titleArray release];
    [_menuFont release];
    [_menuColor release];
    [super dealloc];
}


- (void)presentInView:(UIView *)sender
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.startFrame = [sender convertRect:sender.bounds toView:window];// 转成相对于self.view的绝对坐标
    
    self.dataTableView = [[[UITableView alloc] initWithFrame:CGRectMake(_startFrame.origin.x, _startFrame.origin.y + _startFrame.size.height, _unitSize.width, [_titleArray count] * _unitSize.height) style:UITableViewStylePlain] autorelease];
    self.dataTableView.scrollEnabled = NO;
    self.dataTableView.dataSource = self;
    self.dataTableView.delegate = self;
    [self.dataTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    
    [_dataTableView reloadData];
    
    UIViewController *rootVC = window.rootViewController;
    rootVC.definesPresentationContext = YES;
    // 当前主控制器推出菜单栏
    if (rootVC.presentedViewController == nil) {
        [rootVC presentViewController:self animated:NO completion:nil];
    }
    
    //添加增加的动画
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.5];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[self.view layer] addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    [self.view addSubview:self.dataTableView];
}

- (void)removeMenuView
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - 背景点击事件
- (void)backgroundViewTapEvent:(UIGestureRecognizer *)reg
{
    [self removeMenuView];
}

#pragma mark - UIGestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(touch.view == self.view)
        return YES;
    return NO;          //如果是tableview则不响应
}

#pragma mark- 菜单TableView代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 通知代理处理点击事件
    if ([self.delegate respondsToSelector:@selector(menuViewDidClick:row:unitTitle:)]) {
        [self.delegate menuViewDidClick:self.view row:indexPath.row unitTitle:self.titleArray[indexPath.row]];
    }
    // 移除菜单
    [self removeMenuView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%lu-+%lu", indexPath.row, indexPath.section]];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%lu-+%lu", indexPath.row, indexPath.section]];
        // 设置标题格式
        cell.textLabel.textColor = self.menuColor;
        cell.textLabel.font = self.menuFont;
        cell.backgroundColor = [UIColor clearColor];
        // 设置菜单点击背景
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1];
//        // 移除最后一个cell的分割线
//        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//
//            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
//        }
        // 设置菜单标题
        cell.textLabel.text = self.titleArray[indexPath.row];
        
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.unitSize.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}




@end
