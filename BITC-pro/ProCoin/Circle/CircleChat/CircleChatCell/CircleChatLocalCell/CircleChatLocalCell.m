//
//  CircleChatLocalCell.m
//  TJRtaojinroad
//
//  Created by taojinroad on 4/20/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "CircleChatLocalCell.h"
#import "CircleChatExtendEntity.h"
#import "CommonUtil.h"

@interface CircleChatLocalCell (){
    
}

@property (retain, nonatomic) IBOutlet UILabel *lbContent;
@end

@implementation CircleChatLocalCell

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initilization];
    }
    return self;
}

- (void)dealloc {
    [_lbContent release];
    [super dealloc];
}

- (void)initilization{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (float)getHeightOfCell{
    
    UITableViewCell* cell = [[[NSBundle mainBundle]loadNibNamed:@"CircleChatLocalCell" owner:nil options:nil]lastObject];

    return cell.frame.size.height;
}

#pragma mark - 设置文本cell
- (void)setLocalCell:(CircleChatExtendEntity*)entity{

    _lbContent.text = [NSString stringWithFormat:@" %@ ",entity.say];
    
    CGRect frame = _lbContent.frame;
    CGSize tsize = [_lbContent sizeThatFits:CGSizeMake(200, frame.size.height)];
    frame.size.width = tsize.width + 20;
    frame.origin.x = (SCREEN_WIDTH - frame.size.width)/2;
    _lbContent.frame = frame;

}


@end
