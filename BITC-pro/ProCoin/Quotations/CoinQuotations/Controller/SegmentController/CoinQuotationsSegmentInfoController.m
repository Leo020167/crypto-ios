//
//  CoinQuotationsSegmentInfoController.m
//  Cropyme
//
//  Created by Hay on 2019/9/2.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CoinQuotationsSegmentInfoController.h"
#import "CommonUtil.h"

@interface CoinQuotationsSegmentInfoController ()<UITableViewDelegate,UITableViewDataSource>

@property (retain, nonatomic) CoinIntroEntity *coinIntroEntity;

/** 懒加载*/
@property (assign, nonatomic) CGFloat baseInfoCellHeight;   //基本信息cell高度
@property (assign, nonatomic) CGFloat descCellHeight;       //描述cell高度

@end

@implementation CoinQuotationsSegmentInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _infoTableView.delegate = self;
    _infoTableView.dataSource = self;
}


- (void)dealloc
{
    [_infoTableView release];
    [_coinIntroEntity release];
    [super dealloc];
}

- (void)reloadCoinQuotationSegmentInfo:(CoinIntroEntity *)introEntity
{
    self.coinIntroEntity = introEntity;
    [_infoTableView reloadData];
}

#pragma mark - 懒加载
- (CGFloat)baseInfoCellHeight
{
    if(_baseInfoCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CQDCoinBaseInfoCell" owner:nil options:nil] lastObject];
        _baseInfoCellHeight = cell.frame.size.height;
    }
    return _baseInfoCellHeight;
}

- (CGFloat)descCellHeight
{
    if(_descCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"CQDCoinDescCell" owner:nil options:nil] lastObject];
        _descCellHeight = cell.frame.size.height;
    }
    return _descCellHeight;
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        CGSize whitePaperSize = [CommonUtil getPerfectSizeByText:_coinIntroEntity.whitePaperUrl andFontSize:12.0f andWidth:SCREEN_WIDTH - 140];
        CGSize officalWebSize = [CommonUtil getPerfectSizeByText:_coinIntroEntity.officialWebUrl andFontSize:12.0f andWidth:SCREEN_WIDTH - 140];
        CGSize blockSize = [CommonUtil getPerfectSizeByText:_coinIntroEntity.blockUrl andFontSize:12.0f andWidth:SCREEN_WIDTH - 140];
        whitePaperSize.height = MAX(15.5, whitePaperSize.height);
        officalWebSize.height = MAX(15.5, officalWebSize.height);
        blockSize.height = MAX(15.5, blockSize.height);
        
        return self.baseInfoCellHeight + (whitePaperSize.height - 15.5) + (officalWebSize.height - 15.5) + (blockSize.height - 15.5);
    }else if(indexPath.row == 1){
        CGSize size = [CommonUtil getPerfectSizeByText:_coinIntroEntity.desc andFontSize:12.0f andWidth:SCREEN_WIDTH - 30];
        size.height = MAX(17, size.height);
        return self.descCellHeight + (size.height - 17);
    }
    return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *baseInfoCellIdentifier = @"CQDCoinBaseInfoCellIdentifier";
    static NSString *descCellIdentifier = @"CQDCoinDescCellIdentifier";
    UITableViewCell *cell = nil;
    if(indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:baseInfoCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CQDCoinBaseInfoCell" owner:nil options:nil] lastObject];
        }
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
        UILabel *issueDateLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *issueAmount = (UILabel *)[cell viewWithTag:102];
        UILabel *circulateAmount = (UILabel *)[cell viewWithTag:103];
        UILabel *crowdFundPriceLabel = (UILabel *)[cell viewWithTag:104];
        UILabel *whitePaperLabel = (UILabel *)[cell viewWithTag:105];
        UILabel *officialWebLabel = (UILabel *)[cell viewWithTag:106];
        UILabel *blockLabel = (UILabel *)[cell viewWithTag:107];
        
        titleLabel.text = _coinIntroEntity.name;
        issueDateLabel.text = _coinIntroEntity.issueDate;
        issueAmount.text = _coinIntroEntity.issueAmount;
        circulateAmount.text = _coinIntroEntity.circulateAmount;
        crowdFundPriceLabel.text = _coinIntroEntity.crowdfundPrice;
        whitePaperLabel.text = _coinIntroEntity.whitePaperUrl;
        officialWebLabel.text = _coinIntroEntity.officialWebUrl;
        blockLabel.text = _coinIntroEntity.blockUrl;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:descCellIdentifier];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CQDCoinDescCell" owner:nil options:nil] lastObject];
        }
        UILabel *descLabel = (UILabel *)[cell viewWithTag:100];
        descLabel.text = _coinIntroEntity.desc;
    }
   
    return cell;
}
@end
