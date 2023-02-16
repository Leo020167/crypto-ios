//
//  LanguageTableViewCell.m
//  Encropy
//
//  Created by taojinroad on 2019/4/17.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "LanguageTableViewCell.h"

@interface LanguageTableViewCell (){
    
}
@property (retain, nonatomic) IBOutlet UILabel *languageNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *countryView;

@end

@implementation LanguageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setLanguageName:(NSString *)name image: (NSString *)image andIsSelected:(BOOL)selected {
    self.languageNameLabel.text = name;
    self.countryView.image = [UIImage imageNamed:image];
    self.accessoryType = selected?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
}

- (void)dealloc{
    [_languageNameLabel release];
    [_countryView release];
    [super dealloc];
}

@end
