//
//  EditCustomQuotationsController.m
//  BYY
//
//  Created by Hay on 2019/10/24.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "EditCustomQuotationsController.h"
#import "NetWorkManage+Home.h"
#import "QuotationSocket.h"
#import "NetWorkManage+Quotation.h"
#import "QuotationCoinBaseEntity.h"

//

@interface EditCustomQuotationsController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *symbolsArr;             //数字货币数组
}

@property (copy, nonatomic) NSString *myCustomSymbols;          //我的自选字段

/** 懒加载 */
@property (retain, nonatomic) UIView *titleHeaderView;
@property (assign, nonatomic) CGFloat symbolDataCellHeight;
@property (retain, nonatomic) UIView *noDataView;

@property (retain, nonatomic) IBOutlet UITableView *dataTableView;
@property (retain, nonatomic) IBOutlet UIButton *selectAllButton;
@property (retain, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation EditCustomQuotationsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    symbolsArr = [[NSMutableArray alloc] init];
    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    _dataTableView.tableHeaderView = self.titleHeaderView;
    _dataTableView.backgroundColor = [UIColor whiteColor];
    self.noDataView.hidden = YES;
    [self.view addSubview:self.noDataView];
    [_dataTableView setEditing:YES animated:YES];
    [self reqCustomSymbolData];           //获取自选股
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)dealloc
{
    [symbolsArr release];
    [_myCustomSymbols release];
    [_titleHeaderView release];
    [_noDataView release];
    [_dataTableView release];
    [_selectAllButton release];
    [_deleteButton release];
    [super dealloc];
}

#pragma mark - 懒加载
- (UIView *)titleHeaderView
{
    if(!_titleHeaderView){
        _titleHeaderView = [[[[NSBundle mainBundle] loadNibNamed:@"EditCustomHeaderView" owner:nil options:nil] lastObject] retain];
    }
    return _titleHeaderView;
}

- (CGFloat)symbolDataCellHeight
{
    if(_symbolDataCellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"EditCustomSymbolCell" owner:nil options:nil] lastObject];
        _symbolDataCellHeight = cell.frame.size.height;
    }
    return _symbolDataCellHeight;
}

- (UIView *)noDataView
{
    if(!_noDataView){
        CGFloat noDataViewWidth = 240;
        CGFloat noDataViewHeight = 220;
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - noDataViewWidth)/2.0f, (SCREEN_HEIGHT - noDataViewHeight)/2.0f, noDataViewWidth, noDataViewHeight)];
        _noDataView.backgroundColor = [UIColor clearColor];
        UIImageView *logoIV = [[[UIImageView alloc] initWithFrame:CGRectMake((noDataViewWidth - 176)/2.0f, 0.0, 179, 176)] autorelease];
        logoIV.contentMode = UIViewContentModeScaleAspectFill;
        logoIV.image = [UIImage imageNamed:@"home_follow_bg_no_data"];
        UILabel *tipsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, logoIV.frame.size.height + 10, noDataViewWidth, 21)] autorelease];
        tipsLabel.text = NSLocalizedStringForKey(@"暂无关注的数字货币");
        tipsLabel.textColor = RGBA(29, 49, 85, 0.4);
        tipsLabel.font = [UIFont systemFontOfSize:14.0f];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:logoIV];
        [_noDataView addSubview:tipsLabel];
    }
    return _noDataView;
}

#pragma mark - 按钮点击事件
- (IBAction)backButtonPressed:(id)sender
{
    [self goBack];
}

/** 全选按钮点击 */
- (IBAction)allSymbolButtonPressed:(id)sender
{
    if([symbolsArr  count] == 0)
        return;
    _selectAllButton.selected = !_selectAllButton.isSelected;
    if(_selectAllButton.selected){
        [symbolsArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_dataTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }else{
        [[_dataTableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_dataTableView deselectRowAtIndexPath:obj animated:NO];
        }];
    }
    if([[_dataTableView indexPathsForSelectedRows] count] > 0){
        _deleteButton.selected = YES;
    }else{
        _deleteButton.selected = NO;
    }
    
}

/** 删除按钮点击 */
- (IBAction)deleteSymbolButtonPressed:(id)sender
{
    if([[_dataTableView indexPathsForSelectedRows] count] == 0){
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringForKey(@"提示") message:NSLocalizedStringForKey(@"确定要删除选中的自选吗?") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"取消") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringForKey(@"确定") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSMutableString *deleteSymbols = [NSMutableString string];
        [[_dataTableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            QuotationCoinBaseEntity *entity = [symbolsArr objectAtIndex:obj.row];
            if(idx == 0 && [[_dataTableView indexPathsForSelectedRows] count] < 2){
                [deleteSymbols appendString:entity.symbol];
            }else{
                if(idx == [[_dataTableView indexPathsForSelectedRows] count] - 1){
                    [deleteSymbols appendString:entity.symbol];
                }else{
                    [deleteSymbols appendString:[NSString stringWithFormat:@"%@,",entity.symbol]];
                }
            }
        }];
        [self reqDeleteMyCustomSymbols:deleteSymbols];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - 请求数据
- (void)reqCustomSymbolData
{
    [[NetWorkManage shareSingleNetWork] reqMarketQuotationData:self tab:HomeQuotationsTabCustom sortField:@"" sortType:@"" finishedCallback:@selector(reqCustomSymbolDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqCustomSymbolDataFinished:(NSDictionary *)json
{
    NSDictionary *dataDic = [json objectForKey:@"data"];
    NSArray *quotesArr = [dataDic objectForKey:@"quotes"];
    [symbolsArr removeAllObjects];
    for(NSDictionary *dic in quotesArr){
        QuotationCoinBaseEntity *entity = [[[QuotationCoinBaseEntity alloc] initWithJson:dic] autorelease];
        [symbolsArr addObject:entity];
    }
    if([symbolsArr count] > 0){
        self.noDataView.hidden = YES;
        _dataTableView.hidden = NO;
    }else{
        self.noDataView.hidden = NO;
        _dataTableView.hidden = YES;
    }
    [_dataTableView reloadData];
}


/** 删除自选股 */
- (void)reqDeleteMyCustomSymbols:(NSString *)symbols
{
    [self showProgressDefaultText];
    [[NetWorkManage shareSingleNetWork] reqDeleteCustomSymbol:self symbol:symbols finishedCallback:@selector(reqDeleteMyCustomSymbolsFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqDeleteMyCustomSymbolsFinished:(NSDictionary *)json
{
    [self dismissProgress];
    if([self checkJsonIsSuccess:json]){
        NSString *msg = [NSString stringWithFormat:@"%@",[json objectForKey:@"msg"]];
        if(!checkIsStringWithAnyText(msg)){
            msg = NSLocalizedStringForKey(@"删除成功");
        }
        NSMutableArray *tempArr = [NSMutableArray array];
        [[_dataTableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            QuotationCoinBaseEntity *entity = [symbolsArr objectAtIndex:obj.row];
            [tempArr addObject:entity];
            
        }];
        [[_dataTableView indexPathsForSelectedRows] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_dataTableView deselectRowAtIndexPath:obj animated:NO];
        }];
        
        for(QuotationCoinBaseEntity *entity in tempArr){
            [symbolsArr removeObject:entity];
        }
        
        if([symbolsArr count] == 0){            //当没数据后
            _selectAllButton.selected = NO;
            _deleteButton.selected = NO;
            _noDataView.hidden = NO;
            _dataTableView.hidden = YES;
        }
        
        [self showToastCenter:msg];
        [_dataTableView reloadData];
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

/** 排序 */
- (void)reqSortCusomSymbolData:(NSString *)symbolAndSort
{
    [[NetWorkManage shareSingleNetWork] reqSortCustomSymbol:self symbolAndSort:symbolAndSort finishedCallback:@selector(reqSortCusomSymbolDataFinished:) failedCallback:@selector(reqHttpRequestFailed:)];
}

- (void)reqSortCusomSymbolDataFinished:(NSDictionary *)json
{
    if([self checkJsonIsSuccess:json]){
        
    }else{
        [self showErrorToastCenter:json defaultErrorMsg:NSLocalizedStringForKey(@"请求失败")];
    }
}

#pragma mark - table view delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [symbolsArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.symbolDataCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *symbolCellIdentifier = @"EditCustomSymbolCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:symbolCellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EditCustomSymbolCell" owner:nil options:nil] lastObject];
        cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
        cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    }
    QuotationCoinBaseEntity *entity = [symbolsArr objectAtIndex:indexPath.row];
    UILabel *symbolLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *amountLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *tipsLabel = (UILabel *)[cell viewWithTag:102];
    
    NSRange symbolRange = [entity.symbol rangeOfString:@"/USDT"];
    NSMutableAttributedString *string = [[[NSMutableAttributedString alloc] initWithString:entity.symbol] autorelease];
    if(symbolRange.location != NSNotFound){
        [string addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0f],NSForegroundColorAttributeName:RGBA(97, 117, 174, 0.4)} range:symbolRange];
    }
    symbolLabel.attributedText = string;
    amountLabel.text = [NSString stringWithFormat:@"24H%@ %@", NSLocalizedStringForKey(@"量"), entity.amount];
    if(checkIsStringWithAnyText(entity.tip)){
        tipsLabel.hidden = NO;
        tipsLabel.text = entity.tip;
    }else{
        tipsLabel.hidden = YES;
    }
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[_dataTableView indexPathsForSelectedRows] count] > 0){
        _deleteButton.selected = YES;
    }else{
        _deleteButton.selected = NO;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[_dataTableView indexPathsForSelectedRows] count] > 0){
        _deleteButton.selected = YES;
    }else{
        _deleteButton.selected = NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSUInteger fromRow = sourceIndexPath.row;
    NSUInteger toRow = destinationIndexPath.row;
    
    if (fromRow == toRow) return;
    
    QuotationCoinBaseEntity *object = [[symbolsArr objectAtIndex:fromRow] retain];
    [symbolsArr removeObjectAtIndex:fromRow];
    [symbolsArr insertObject:object atIndex:toRow];
    [object release];
    [tableView reloadData];
    NSMutableString *sortString = [NSMutableString string];
    for(int i = 0 ; i < [symbolsArr count] ; i++){
        QuotationCoinBaseEntity *object = [symbolsArr objectAtIndex:i];
        if(i == 0 && [symbolsArr count] < 2){
            [sortString appendString:[NSString stringWithFormat:@"%@:%@",object.symbol,@(i)]];
        }else{
            if(i ==  [symbolsArr count] - 1){
                [sortString appendString:[NSString stringWithFormat:@"%@:%@",object.symbol,@(i)]];
            }else{
                [sortString appendString:[NSString stringWithFormat:@"%@:%@,",object.symbol,@(i)]];
            }
        }
    }
    [self reqSortCusomSymbolData:sortString];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
}

@end
