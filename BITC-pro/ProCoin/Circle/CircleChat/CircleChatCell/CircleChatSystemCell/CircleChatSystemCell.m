//
//  CircleChatSystemCell.m
//  TJRtaojinroad
//
//  Created by taojinroad on 4/20/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "CircleChatSystemCell.h"
#import "CircleChatExtendEntity.h"
#import "CommonUtil.h"
#import "MLEmojiLabel.h"

@interface CircleChatSystemCell ()<MLEmojiLabelDelegate>{

}

@property (retain, nonatomic) IBOutlet MLEmojiLabel *lbContent;
@property (retain, nonatomic) IBOutlet UILabel *lbTime;
@property (retain, nonatomic) IBOutlet UIView *cellView;
@end

@implementation CircleChatSystemCell

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initilization];
    }
    return self;
}

- (void)dealloc {
    [_cellView release];
    [_lbTime release];
    [_lbContent release];
    [super dealloc];
}

- (void)initilization{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

+ (float)getHeightOfCell:(NSString*)timeFormat say:(NSString*)say{
    
    UITableViewCell* cell = [[[NSBundle mainBundle]loadNibNamed:@"CircleChatSystemCell" owner:nil options:nil]lastObject];
    
    MLEmojiLabel* lbContent = (MLEmojiLabel*)[cell viewWithTag:100];
    lbContent.frame = CGRectMake(0, 0, 300, 3500);
    
    NSString* content = [NSString stringWithFormat:@" %@ ",say];
    
    NSDictionary* componentsDictionary = [lbContent extractEmojiText:content textFont:[UIFont systemFontOfSize:12] isNeedUrl:YES isNeedPhoneNumber:YES isNeedEmail:YES isNeedAt:NO isNeedPoundSign:NO isNeedFullcode:YES isNeedTjrAt:YES];
    [lbContent setEmojiTextWithDictionary:componentsDictionary];
    [lbContent sizeToFit];
    [lbContent setBackgroundColor:RGBA(217, 217, 217, 1)];
    
    CGSize tsize = lbContent.frame.size;
    CGRect frame = lbContent.frame;
   
    float width = tsize.width + 10;
    if (tsize.height > 16) {
        frame.size.width = 300;
        frame.origin.x = (SCREEN_WIDTH - frame.size.width)/2;
        frame.size.height = tsize.height + 5;
    }else{
        frame.size.width = width;
        frame.origin.x = (SCREEN_WIDTH - frame.size.width)/2;
    }
    
    float height = cell.frame.size.height + frame.size.height - 21;
    
    float h = timeFormat.length>0?height:(height - 20);
    
    return h;
}

#pragma mark - 设置文本cell
- (void)setSystemCell:(CircleChatExtendEntity*)entity{
    
    
    _lbTime.text = entity.timeFormat;
    _lbTime.frame = CGRectMake(SCREEN_WIDTH/2 - 40, _lbTime.frame.origin.y, 80, _lbTime.frame.size.height);
    
    NSString* json = [MLEmojiLabel getTJRAtParams:entity.say];
    if (TTIsStringWithAnyText(json)) {
        NSDictionary* params = [CommonUtil jsonValue:json];
        NSString* color = [params objectForKey:@"color"];
        [_lbContent setCommonLinkColor:[CommonUtil colorWithHexString:color]];
    }
    
    CGRect frame = _lbTime.frame;
    
    if (entity.timeFormat.length>0) {
        frame.size.height = 20;
        _lbTime.hidden = NO;
    }else{
        frame.size.height = 0;
        _lbTime.hidden = YES;
    }
    CGSize tsize = [_lbTime sizeThatFits:CGSizeMake(200, frame.size.height)];
    frame.size.width = tsize.width + 20;
    frame.origin.x = (SCREEN_WIDTH - frame.size.width)/2;
    _lbTime.frame = frame;
    [CommonUtil viewMasksToBounds:_lbTime cornerRadius:3 borderColor:[UIColor clearColor] borderWidth:1];

    NSString* content = [NSString stringWithFormat:@" %@ ",entity.say];

    _lbContent.emojiDelegate = self;
    _lbContent.frame = CGRectMake(_lbContent.frame.origin.x, _lbContent.frame.origin.y , 300, 3500);

    NSDictionary* componentsDictionary = [_lbContent extractEmojiText:content textFont:[UIFont systemFontOfSize:12] isNeedUrl:YES isNeedPhoneNumber:YES isNeedEmail:YES isNeedAt:NO isNeedPoundSign:NO isNeedFullcode:YES isNeedTjrAt:YES];
    [_lbContent setEmojiTextWithDictionary:componentsDictionary];
    [_lbContent sizeToFit];
    tsize = _lbContent.frame.size;
    frame = _lbContent.frame;

    float width = tsize.width + 10;
    frame.size.width = MIN(width, 300);
    frame.origin.x = (SCREEN_WIDTH - frame.size.width)/2;
    frame.size.height = tsize.height + 5;
    
    _lbContent.frame = frame;
    [_lbContent setBackgroundColor:RGBA(217, 217, 217, 1)];
    
    [CommonUtil viewMasksToBounds:_lbContent cornerRadius:6 borderColor:[UIColor clearColor] borderWidth:1];
    
    frame = _cellView.frame;
    frame.origin.y = _lbTime.frame.origin.y + _lbTime.frame.size.height;
    frame.size.height = _lbTime.frame.size.height + _lbContent.frame.size.height + 5;
    _cellView.frame = frame;

}

#pragma mark - 链接单击事件总方法
- (void)mlEmojiLabel:(MLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link detail:(NSDictionary *)detail {
    if (detail) {
        MLEmojiLabelLinkType type = [[detail objectForKey:ClickLinkType] integerValue];
        
        switch (type) {
            case MLEmojiLabelLinkTypeURL:	/* 网址点击 */
            {
                break;
            }
                
            case MLEmojiLabelLinkTypePhoneNumber:
            {
                break;
            }
                
            case MLEmojiLabelLinkTypePoundSign:	/* 点击话题 */
            {
                break;
            }
                
            case MLEmojiLabelLinkTypeFullcode:	/* 点击股票代码 */
            {
                NSString *fdm = [detail objectForKey:ClickDetail];
                if ([_delegate respondsToSelector:@selector(circleChatSystemCell:fullcodeClicked:)]){
                    [_delegate circleChatSystemCell:self fullcodeClicked:fdm];
                }
                break;
            }
                
            case MLEmojiLabelLinkTypeTjrAt:	/* 名字点击跳转 */
            {
                NSString *str = [detail objectForKey:ClickDetail];
                if ([_delegate respondsToSelector:@selector(circleChatSystemCell:paramsClicked:)]){
                    [_delegate circleChatSystemCell:self paramsClicked:str];
                }
                break;
            }
                
            case MLEmojiLabelLongPress:	/* 长按 */
            {
                break;
            }
                
            default:
                break;
        }
    }
}


@end
