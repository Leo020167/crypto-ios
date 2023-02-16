//
//  SelectCoinController.m
//  BYY
//
//  Created by Hay on 2019/9/23.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "SelectCoinController.h"
#import "ExtractCoinDataEntity.h"
#import "UIView+General.h"
@interface SelectCoinController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *tableData;                  //数据信息
    NSMutableDictionary *coinDataDic;           //字母字典
}

@property (assign, nonatomic) NSInteger index;

/**懒加载*/
@property (assign, nonatomic) CGFloat cellHeight;

@property (retain, nonatomic) IBOutlet UIView *bottomView;
@property (retain, nonatomic) IBOutlet UIButton *okBtn;
@property (retain, nonatomic) IBOutlet UITableView *dataTableView;

@end

@implementation SelectCoinController
- (void)viewDidLayoutSubviews {
    
    [_bottomView applyRadiusMask:10 bottomLeft:0 bottomRight:0 topRight:10];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dataTableView.delegate = self;
    _dataTableView.dataSource = self;
    self.view.backgroundColor = UIColor.clearColor;
    _index = 0;
    tableData = [[NSMutableArray alloc] init];
    coinDataDic = [[NSMutableDictionary alloc] init];
}

- (void)dealloc
{
    //[tableData release];
    //[coinDataDic release];
    [_dataTableView release];
    [_bottomView release];
    [_okBtn release];
    [super dealloc];
}

#pragma mark - 懒加载
- (CGFloat)cellHeight
{
    if(_cellHeight == 0){
        UITableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"SelectCoinCell" owner:nil options:nil] lastObject];
        _cellHeight = cell.frame.size.height;
    }
    return _cellHeight;
}

#pragma mark - 更新数据
- (void)reloadSelectCoinData:(NSArray *)data
{
    tableData = data;
    [_dataTableView reloadData];
}

//- (void)reloadSelectCoinData2:(NSArray *)data
//{
//    [tableData removeAllObjects];
//    [coinDataDic removeAllObjects];
//    for(int i = 0 ; i < [data count] ; i++){
//        ExtractCoinDataEntity *entity = [data objectAtIndex:i];
//        NSString *firstLetter = [self firstCharactor:entity.symbol];
//        if([[coinDataDic allKeys] containsObject:firstLetter]){
//            NSMutableArray *arr = [NSMutableArray arrayWithArray:[coinDataDic objectForKey:firstLetter]];
//            [arr addObject:entity.symbol];
//            [coinDataDic setObject:arr forKey:firstLetter];
//        }else{
//            NSMutableArray *arr = [NSMutableArray array];
//            [arr addObject:entity.symbol];
//            [coinDataDic setObject:arr forKey:firstLetter];
//        }
//
//    }
//    [tableData addObjectsFromArray:[[coinDataDic allKeys] sortedArrayUsingSelector:@selector(compare:)]];
//    [_dataTableView reloadData];
//}

- (NSString *)firstCharactor:(NSString *)aString
{
    NSString *firstLetter = [aString substringToIndex:1];
    return [firstLetter uppercaseString];
}

#pragma mark - 按钮点击事件
- (IBAction)closeButtonPressed:(id)sender
{
    [self dismissModalFromParentViewController];
}

- (IBAction)submitButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(selectCoinDidSelctedWithSymol:)]){
        NSString *symbol = [tableData objectAtIndex:self.index];
        [_delegate selectCoinDidSelctedWithSymol:symbol];
    }
    [self dismissModalFromParentViewController];
}


#pragma mark - table view delegate and data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return [[coinDataDic objectForKey:[tableData objectAtIndex:section]] count];
    return tableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;//return self.cellHeight;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [tableData objectAtIndex:section];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SelectCoinCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SelectCoinCell" owner:nil options:nil] lastObject];
    }
//    NSString *symbol = [[coinDataDic objectForKey:[tableData objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    UIView *cview = (UIView *)[cell viewWithTag:99];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    titleLabel.backgroundColor = UIColor.clearColor;
    titleLabel.text = [[tableData objectAtIndex:indexPath.row] stringValue];
    
    [cview.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    if (_index == indexPath.row) {
        titleLabel.textColor = UIColorMakeWithHex(@"#3E4660");
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = cview.bounds;
        gl.startPoint = CGPointMake(0, 0.5);
        gl.endPoint = CGPointMake(1, 0.5);
        gl.colors = @[(__bridge id)[UIColorMakeWithHex(@"#FFFFFF") colorWithAlphaComponent:0.3].CGColor,
                      (__bridge id)UIColorMakeWithHex(@"#eeeeee").CGColor,
                      (__bridge id)[UIColorMakeWithHex(@"#FFFFFF") colorWithAlphaComponent:0.3].CGColor];
        gl.locations = @[@(0.0),@(0.5f),@(1.0f)];
        [cview.layer insertSublayer:gl atIndex:0];
    } else {
        titleLabel.textColor = UIColorMakeWithHex(@"#A2A9BC");
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.index = indexPath.row;
    [tableView reloadData];
    
//    if([_delegate respondsToSelector:@selector(selectCoinDidSelctedWithSymol:)]){
//        NSString *symbol = [[coinDataDic objectForKey:[tableData objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
//        [_delegate selectCoinDidSelctedWithSymol:symbol];
//
//        [self dismissModalFromParentViewController];
//    }
}

//- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return tableData;
//}
//
//- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return index;
//}


@end
