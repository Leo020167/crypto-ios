//
//  CoinPickerView.m
//  Cropyme
//
//  Created by Hay on 2019/9/10.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CoinPickerView.h"
#import "ExtractCoinDataEntity.h"

@interface CoinPickerView()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSInteger selectIndex;
}

@property (copy, nonatomic) NSArray *pickerDataArr;

@property (retain, nonatomic) IBOutlet UIPickerView *coinPickerView;
@property (retain, nonatomic) IBOutlet UIView *bottomView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *bottomViewLayoutConstraintBottom;
@end

@implementation CoinPickerView



- (void)awakeFromNib
{
    selectIndex = 0;
    _coinPickerView.delegate = self;
    _coinPickerView.dataSource = self;
    _bottomViewLayoutConstraintBottom.constant = -_bottomView.frame.size.height;
    [self layoutIfNeeded];
    [super awakeFromNib];
}

- (void)dealloc
{
    [_pickerDataArr release];
    [_bottomViewLayoutConstraintBottom release];
    [_bottomView release];
    [_coinPickerView release];
    [super dealloc];
}

- (void)showCoinPickerViewWithView:(UIView *)view
{

    [view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        _bottomViewLayoutConstraintBottom.constant = 0;
        [self layoutIfNeeded];
    }];
}

- (void)dismissCoinPickerView
{
    [UIView animateWithDuration:0.3 animations:^{
        _bottomViewLayoutConstraintBottom.constant = -_bottomView.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)reloadCoinPickerViewSelectRow:(NSInteger)selectRow
{
    selectIndex = selectRow;
    [_coinPickerView selectRow:selectRow inComponent:0 animated:YES];

}

- (void)reloadCoinPickerView:(NSArray *)dataArr
{
    self.pickerDataArr = dataArr;
    [_coinPickerView reloadAllComponents];
}


#pragma mark - 按钮点击事件
- (IBAction)doneButtonPressed:(id)sender
{
    if([_delegate respondsToSelector:@selector(coinPickerViewDidSelectedIndex:)]){
        [_delegate coinPickerViewDidSelectedIndex:selectIndex];
    }
    [self dismissCoinPickerView];
}

- (IBAction)backgroundViewTouchDown:(id)sender
{
    [self dismissCoinPickerView];
}

#pragma mark pickerview delegate
- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView
{
    return 1;
}

//返回指定列的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_pickerDataArr count];
    
}


//返回指定列，行的高度，就是自定义行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 35.0f;
    
}

//显示的标题
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    ExtractCoinDataEntity *entity = [self.pickerDataArr objectAtIndex:row];
    return entity.symbol;
    
}

//被选择的行

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectIndex = row;
    
}


@end
