//
//  HomeMainSecondView.m
//  ProCoin
//
//  Created by 祥翔李 on 2021/11/4.
//  Copyright © 2021 Toka. All rights reserved.
//

#import "HomeMainQuotationsCell.h"

@interface HomeMainSecondCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *rateLabel;

@property (nonatomic, strong) UILabel *moneyLabel;

@property (nonatomic, strong) UILabel *approximateLabel;

@property (nonatomic, strong) HomeQuoteModel *model;

@end

@implementation HomeMainSecondCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.rateLabel];
    [self.contentView addSubview:self.moneyLabel];
    [self.contentView addSubview:self.approximateLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(15);
    }];
    [self.rateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self);
    }];
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.rateLabel.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self);
    }];
    [self.approximateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.moneyLabel.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self);
    }];
}

- (void)setModel:(HomeQuoteModel *)model{
    self.nameLabel.text = [NSString stringWithFormat:@"%@/%@", model.symbol, model.currency];
    self.rateLabel.text = [NSString stringWithFormat:@"%@%@", model.rate, @"%"];
    self.moneyLabel.text = model.price;
    self.moneyLabel.textColor = [TradeUtil textColorWithQuotationNumber:model.rate.doubleValue];
    self.rateLabel.textColor = [TradeUtil textColorWithQuotationNumber:model.rate.doubleValue];
    self.approximateLabel.text = model.priceCny;
}

#pragma mark =========================== 懒加载 ===========================
- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = UIFontBoldMake(13);
        _nameLabel.textColor = UIColor.blackColor;
    }
    return _nameLabel;
}

- (UILabel *)rateLabel{
    if (!_rateLabel) {
        _rateLabel = [[UILabel alloc] init];
        _rateLabel.font = UIFontBoldMake(15);
        _rateLabel.textColor = UIColor.redColor;
    }
    return _rateLabel;
}

- (UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] init];
        _moneyLabel.font = UIFontBoldMake(14);
        _moneyLabel.textColor = UIColor.redColor;
    }
    return _moneyLabel;
}

- (UILabel *)approximateLabel{
    if (!_approximateLabel) {
        _approximateLabel = [[UILabel alloc] init];
        _approximateLabel.font = UIFontMake(11);
        _approximateLabel.textColor = UIColorMakeWithHex(@"#888888");
    }
    return _approximateLabel;
}

@end

@interface HomeMainQuotationsCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation HomeMainQuotationsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(5, 0, 0, 0));
    }];
}

- (void)setDataArray:(NSMutableArray *)dataArray{
    self.dataSource = [NSMutableArray arrayWithArray:dataArray];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    HomeMainSecondCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HomeMainSecondCell class]) forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.clickDataBlock) {
        self.clickDataBlock(self.dataSource[indexPath.row]);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((SCREEN_WIDTH - 20) / 3.0, 100);
}

#pragma mark =========================== 懒加载 ===========================
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.sectionInset = UIEdgeInsetsZero;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        _collectionView.layer.cornerRadius = 10;
        _collectionView.layer.masksToBounds = YES;
        _collectionView.backgroundColor = UIColor.whiteColor;
        [_collectionView registerClass:[HomeMainSecondCell class] forCellWithReuseIdentifier:NSStringFromClass([HomeMainSecondCell class])];
    }
    return _collectionView;
}

@end
