//
//  CMDDepositWayView.m
//  Cropyme
//
//  Created by Hay on 2019/7/26.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CMDDepositWayView.h"
#import "RZWebImageView.h"
#import "CommonUtil.h"
#import "OTCTradeEntity.h"

@interface CMDDepositWayView()<UITableViewDelegate,UITableViewDataSource>
{
    CGFloat contentViewOriginViewHeight;           //初始高度
}

@property (retain, nonatomic) NSMutableArray *tableData;

/** 懒加载*/
@property (assign, nonatomic) CGFloat payWayCellHeight;

@property (retain, nonatomic) IBOutlet UITableView *wayTableView;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *contentViewLayoutConstraintBottom;           //contentView底部约束

@end

@implementation CMDDepositWayView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initDepositWayView];
    
}

- (void)initDepositWayView
{
    contentViewOriginViewHeight = _contentView.frame.size.height;
    _wayTableView.delegate = self;
    _wayTableView.dataSource = self;
    if (@available(iOS 11.0, *)) {
        self.wayTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
}

- (void)dealloc
{
    [_tableData release];
    [_wayTableView release];
    [_contentViewLayoutConstraintBottom release];
    [_contentView release];
    [super dealloc];
}

#pragma mark - 按钮点击事件
- (IBAction)backgroundViewTouchDown:(id)sender
{
    [self dismissDepositWayView];
}

#pragma mark - 显示或隐藏页面
- (void)showDepositWayViewInView:(UIView *)superView wayCount:(NSInteger)wayCount
{
    CGFloat height = self.payWayCellHeight * wayCount;
    self.frame = CGRectMake(0.0, 0.0, superView.frame.size.width, superView.frame.size.height);
    [CommonUtil viewHeightForAutoLayout:_contentView height:contentViewOriginViewHeight + (height - 60)];
    _contentViewLayoutConstraintBottom.constant = -(_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
    [self layoutIfNeeded];
    [superView addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintBottom.constant = 0.0;
        [self layoutIfNeeded];
    }];
}

- (void)dismissDepositWayView
{
    [UIView animateWithDuration:0.3 animations:^{
        _contentViewLayoutConstraintBottom.constant = -(_contentView.frame.size.height + IPHONEX_BOTTOM_HEIGHT);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 更新数据
- (void)reloadDepositWayData:(NSArray *)dataArr
{
    self.tableData = [NSMutableArray arrayWithArray:dataArr];
    
    [_wayTableView reloadData];
}

#pragma mark - 懒加载
- (CGFloat)payWayCellHeight
{
    if(_payWayCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FundWayCell" owner:nil options:nil] lastObject];
        _payWayCellHeight = cell.frame.size.height;
    }
    return _payWayCellHeight;
}



#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.payWayCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FundPayWayCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FundWayCell" owner:nil options:nil] lastObject];
    }

    OTCReceiptEntity *entity = [_tableData objectAtIndex:indexPath.row];
    RZWebImageView *logo = (RZWebImageView *)[cell viewWithTag:100];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *recommendLabel = (UILabel *)[cell viewWithTag:102];
    UIView *recommendView = (UIView *)[cell viewWithTag:103];
    [logo showImageWithUrl:entity.receiptTypeLogo];
    titleLabel.text = entity.receiptTypeValue;
    if(checkIsStringWithAnyText(entity.receiptDesc)){
        recommendView.hidden = NO;
        recommendLabel.text = entity.receiptDesc;
    }else{
        recommendView.hidden = YES;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if([_delegate respondsToSelector:@selector(depositWayViewDidSelectedWayWithIndex:)]){
        [_delegate depositWayViewDidSelectedWayWithIndex:indexPath.row];
    }
    [self dismissDepositWayView];
}



@end
