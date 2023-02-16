//
//  TYAccountFinancialSymbolHeaderView.m
//  ProCoin
//
//  Created by Luo Chun on 2022/12/4.
//  Copyright © 2022 Toka. All rights reserved.
//

#import "TYAccountFinancialSymbolHeaderView.h"

@interface TYAccountFinancialSymbolHeaderView () <UITextFieldDelegate>

@end

@implementation TYAccountFinancialSymbolHeaderView


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.contentView.backgroundColor = UIColorWhite;
    [self.contentView addSubview:self.filterSwitch];
    [self.contentView addSubview:self.desLabel];
    //[self.contentView addSubview:self.searchField];
    
    [self.filterSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self);
    }];
    
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_filterSwitch.mas_right).offset(4);
        make.centerY.mas_equalTo(self);
    }];

//    [self.searchField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-15);
//        make.centerY.mas_equalTo(self);
//        make.width.mas_equalTo(150);
//        make.height.mas_equalTo(34);
//    }];
}

- (void)filterZero: (UISwitch *)sender {
    _filterActionBlock(sender.isOn);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (checkIsStringWithAnyText(textField.text)) {
        _searchActionBlock(textField.text);
    }
}

#pragma mark =========================== 懒加载 ===========================
- (UISwitch *)filterSwitch{
    if (!_filterSwitch) {
        _filterSwitch = [[UISwitch alloc] init];
        [_filterSwitch setOnTintColor: UIColorMakeWithHex(@"#6175AE")];
        [_filterSwitch addTarget:self action:@selector(filterZero:) forControlEvents:UIControlEventValueChanged];
    }
    return _filterSwitch;
}

- (UILabel *)desLabel{
    if (!_desLabel) {
        _desLabel = [[UILabel alloc] init];
        _desLabel.text  = NSLocalizedStringForKey(@"隐藏小金额");
        _desLabel.textColor = UIColorMakeWithHex(@"#3E4660");
        _desLabel.font = UIFontMake(12);
    }
    return _desLabel;
}


//- (UITextField *)searchField{
//    if (!_searchField) {
//        _searchField = [[UITextField alloc] init];
//        _searchField.placeholder = NSLocalizedStringForKey(@"搜索");
//        _searchField.font = UIFontMake(15);
//        _searchField.textColor = UIColorMakeWithHex(@"#333333");
//        _searchField.delegate = self;
//        _searchField.keyboardType = UIKeyboardTypeDefault;
//        _searchField.returnKeyType = UIReturnKeySearch;
//        _searchField.layer.cornerRadius = 5;
//        _searchField.backgroundColor = UIColorMakeWithHex(@"#F6F7F9");
//        _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        _searchField.leftViewMode = UITextFieldViewModeAlways;
//
//        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 34)];
//        _searchField.leftView = leftView;
//
//    }
//    return _searchField;
//}


@end
