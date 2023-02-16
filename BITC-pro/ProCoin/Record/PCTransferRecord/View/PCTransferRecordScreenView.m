//
//  PCTransferRecordScreenView.m
//  ProCoin
//
//  Created by Hay on 2020/3/6.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCTransferRecordScreenView.h"
#import "PCTransferRecordModel.h"
#import "CommonUtil.h"

#define CollectionViewContentTopBottomMargin    5.0f
#define CollectionMinLineSpacing                10.0
#define CollectionMinItemSpacing                15.0f
#define CollectionViewItemHeight                30
#define CollectionViewExtractWidth              15

@interface PCTransferRecordScreenView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

/** 变量*/
@property (copy, nonatomic) NSArray <PCTransferAccountModel *>*fromAccountArr;        //转出账户类型数组
@property (copy, nonatomic) NSArray <PCTransferAccountModel *>*toAccountArr;          //转入账户类型数组
@property (copy, nonatomic) NSString *fromAccountType;      //转出账户类型
@property (copy, nonatomic) NSString *toAccountType;        //转入账户类型

/** UI*/
@property (retain, nonatomic) IBOutlet UICollectionView *transferOutCollectionView; //转出collectionView
@property (retain, nonatomic) IBOutlet UICollectionView *transferInCollectionView;  //转入collectionView
@property (retain, nonatomic) IBOutlet UIView *coreView;    //核心view
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *coreViewLayoutConstraintTop; //核心view顶部约束
@property (retain, nonatomic) IBOutlet UICollectionViewFlowLayout *transferOutCollectionLayout; //转出collectionViewlayout
@property (retain, nonatomic) IBOutlet UICollectionViewFlowLayout *transferInCollectionLayout;  //转collectionViewlayout

@end

@implementation PCTransferRecordScreenView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _transferOutCollectionLayout.itemSize = CGSizeZero;
    _transferOutCollectionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _transferOutCollectionLayout.minimumLineSpacing = CollectionMinLineSpacing;
    _transferOutCollectionLayout.minimumInteritemSpacing = CollectionMinItemSpacing;
    _transferOutCollectionView.backgroundColor = [UIColor whiteColor];
    _transferOutCollectionView.contentInset = UIEdgeInsetsMake(CollectionViewContentTopBottomMargin, 0, CollectionViewContentTopBottomMargin, 0);
    _transferOutCollectionView.delegate = self;
    _transferOutCollectionView.dataSource = self;
    [_transferOutCollectionView registerNib:[UINib nibWithNibName:@"PCTransferRecordScreenCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PCTransferRecordScreenCellIdentifier"];
    
    
    _transferInCollectionLayout.itemSize = CGSizeZero;
    _transferInCollectionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _transferInCollectionLayout.minimumLineSpacing = CollectionMinLineSpacing;
    _transferInCollectionLayout.minimumInteritemSpacing = CollectionMinItemSpacing;
    _transferInCollectionView.backgroundColor = [UIColor whiteColor];
    _transferInCollectionView.contentInset = UIEdgeInsetsMake(CollectionViewContentTopBottomMargin, 0, CollectionViewContentTopBottomMargin, 0);
    _transferInCollectionView.delegate = self;
    _transferInCollectionView.dataSource = self;
    [_transferInCollectionView registerNib:[UINib nibWithNibName:@"PCTransferRecordScreenCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"PCTransferRecordScreenCellIdentifier"];
    
}


- (void)dealloc
{
    [_fromAccountArr release];
    [_toAccountArr release];
    [_fromAccountType release];
    [_toAccountType release];
    [_transferOutCollectionView release];
    [_transferInCollectionView release];
    [_coreView release];
    [_coreViewLayoutConstraintTop release];
    [_transferOutCollectionLayout release];
    [_transferInCollectionLayout release];
    [super dealloc];
}

#pragma mark -  显示与消失
- (void)addSelfToParentViewController:(UIViewController *)controller fromAcountArr:(NSArray *)fromAccountArr toAccountArr:(NSArray *)toAccountArr fromAccountType:(NSString *)fromAccountType toAccountType:(NSString *)toAccountType
{
    self.fromAccountArr = fromAccountArr;
    self.toAccountArr = toAccountArr;
    self.fromAccountType = fromAccountType;
    self.toAccountType = toAccountType;
    //更新ui
    [self reloadCoreViewUI];
    
    
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        _coreViewLayoutConstraintTop.constant = 0;
        [self.view layoutIfNeeded];
    }];
    
}

- (void)dismissViewController
{
    [UIView animateWithDuration:0.3 animations:^{
        _coreViewLayoutConstraintTop.constant = -_coreView.frame.size.height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

#pragma mark - 更新核心UI
- (void)reloadCoreViewUI
{
    //计算transferOutCollectionView高度
    CGFloat outAccumulateWidth = 0.0;
    CGFloat outAccumulateRows = 1;
    for(int i = 0; i < [_fromAccountArr count]; i++){
        PCTransferAccountModel *entity = [_fromAccountArr objectAtIndex:i];
        CGSize size = [CommonUtil getPerfectLabelTextWidth:entity.accountName andFontSize:14.0f andHeight:20];
        size.width += CollectionViewExtractWidth;
        outAccumulateWidth = outAccumulateWidth + size.width + CollectionMinItemSpacing;
        if(outAccumulateWidth > SCREEN_WIDTH - 24){     //如果超出屏幕,则表示下一行
            outAccumulateWidth = 0.0;
            outAccumulateRows++;
        }
    }
    CGFloat outHeight = CollectionViewItemHeight * outAccumulateRows + CollectionViewContentTopBottomMargin + CollectionViewContentTopBottomMargin + CollectionMinLineSpacing * (outAccumulateRows - 1);
    [CommonUtil viewHeightForAutoLayout:_transferOutCollectionView height:outHeight];
    
    //计算transferInCollectionView高度
    CGFloat inAccumulateWidth = 0.0;
    CGFloat inAccumulateRows = 1;
    for(int i = 0; i < [_toAccountArr count]; i++){
        PCTransferAccountModel *entity = [_toAccountArr objectAtIndex:i];
        CGSize size = [CommonUtil getPerfectLabelTextWidth:entity.accountName andFontSize:14.0f andHeight:20];
        size.width += CollectionViewExtractWidth;
        inAccumulateWidth = inAccumulateWidth + size.width + CollectionMinItemSpacing;
        if(inAccumulateWidth > SCREEN_WIDTH - 24){     //如果超出屏幕,则表示下一行
            inAccumulateWidth = 0.0;
            inAccumulateRows++;
        }
    }
    CGFloat inHeight = CollectionViewItemHeight * inAccumulateRows + CollectionViewContentTopBottomMargin + CollectionViewContentTopBottomMargin + CollectionMinLineSpacing * (inAccumulateRows - 1);
    [CommonUtil viewHeightForAutoLayout:_transferInCollectionView height:inHeight];
    
    _coreViewLayoutConstraintTop.constant = -self.coreView.frame.size.height;
    [_transferOutCollectionView reloadData];
    [_transferInCollectionView reloadData];
    [self.view layoutIfNeeded];
}

#pragma mark - 按钮点击事件

/** 取消页面*/
- (IBAction)dimissViewButtonPressed:(id)sender
{
    [self dismissViewController];
}

- (void)fromAccountTypeButtonPressed:(UIButton *)sender
{
    UICollectionViewCell *cell = [CommonUtil getCollectionViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_transferOutCollectionView indexPathForCell:cell];
    PCTransferAccountModel *entity = [_fromAccountArr objectAtIndex:indexPath.row];
    if([self.fromAccountType isEqualToString:entity.accountType]){      //已经选中了，再点击一次则取消
        self.fromAccountType = @"";
    }else{
        self.fromAccountType = entity.accountType;
    }
    [_transferOutCollectionView reloadData];
}

- (void)toAccountTypeButtonPressed:(UIButton *)sender
{
    UICollectionViewCell *cell = [CommonUtil getCollectionViewCellWithContainView:sender];
    NSIndexPath *indexPath = [_transferInCollectionView indexPathForCell:cell];
    PCTransferAccountModel *entity = [_toAccountArr objectAtIndex:indexPath.row];
    if([self.toAccountType isEqualToString:entity.accountType]){      //已经选中了，再点击一次则取消
        self.toAccountType = @"";
    }else{
        self.toAccountType = entity.accountType;
    }
    [_transferInCollectionView reloadData];
}

/** 提交数据*/
- (IBAction)commitDataButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(transferRecordScreenCommitDataWithFromAccountType:toAccountType:)]){
        [_delegate transferRecordScreenCommitDataWithFromAccountType:self.fromAccountType toAccountType:self.toAccountType];
    }
    [self dismissViewController];
}

/** 重置数据*/
- (IBAction)resetSettingButtonPressed:(id)sender
{
    self.fromAccountType = @"";
    self.toAccountType = @"";
    [_transferOutCollectionView reloadData];
    [_transferInCollectionView reloadData];
}

#pragma mark - collection view delegate and data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == _transferOutCollectionView){
        return [self.fromAccountArr count];
    }else{
        return [self.toAccountArr count];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == _transferOutCollectionView){
        PCTransferAccountModel *entity = [_fromAccountArr objectAtIndex:indexPath.row];
        CGSize size = [CommonUtil getPerfectLabelTextWidth:entity.accountName andFontSize:14.0f andHeight:20];
        size.width += CollectionViewExtractWidth;
        return CGSizeMake(size.width, 30);
    }else{
        PCTransferAccountModel *entity = [_toAccountArr objectAtIndex:indexPath.row];
        CGSize size = [CommonUtil getPerfectLabelTextWidth:entity.accountName andFontSize:14.0f andHeight:20];
        size.width += CollectionViewExtractWidth;
        return CGSizeMake(size.width, 30);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == _transferOutCollectionView){
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PCTransferRecordScreenCellIdentifier" forIndexPath:indexPath];
        PCTransferAccountModel *entity = [_fromAccountArr objectAtIndex:indexPath.row];
        UIButton *button = (UIButton *)[cell viewWithTag:100];
        [button addTarget:self action:@selector(fromAccountTypeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:entity.accountName forState:UIControlStateNormal];
        if(checkIsStringWithAnyText(self.fromAccountType)){
            if([self.fromAccountType isEqualToString:entity.accountType]){
                button.backgroundColor = RGBA(97, 117, 174, 1.0);
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }else{
                button.backgroundColor = RGBA(249, 250, 253, 1.0);
                [button setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
            }
        }else{
            button.backgroundColor = RGBA(249, 250, 253, 1.0);
            [button setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        }
        return cell;
    }else{
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PCTransferRecordScreenCellIdentifier" forIndexPath:indexPath];
        PCTransferAccountModel *entity = [_fromAccountArr objectAtIndex:indexPath.row];
        UIButton *button = (UIButton *)[cell viewWithTag:100];
        [button addTarget:self action:@selector(toAccountTypeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:entity.accountName forState:UIControlStateNormal];
        if(checkIsStringWithAnyText(self.toAccountType)){
            if([self.toAccountType isEqualToString:entity.accountType]){
                button.backgroundColor = RGBA(97, 117, 174, 1.0);
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }else{
                button.backgroundColor = RGBA(249, 250, 253, 1.0);
                [button setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
            }
        }else{
            button.backgroundColor = RGBA(249, 250, 253, 1.0);
            [button setTitleColor:RGBA(61, 58, 80, 1.0) forState:UIControlStateNormal];
        }
        return cell;
    }
}
@end
