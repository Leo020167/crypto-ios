//
//  CircleChatTextCell.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12/3/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "CircleChatTextCell.h"
#import "TJRHeadView.h"
#import "CircleChatBubbleView.h"
#import "MLEmojiLabel.h"
#import "CircleChatExtendEntity.h"
#import "VeDateUtil.h"
#import "CommonUtil.h"

@interface CircleChatTextCell ()<MLEmojiLabelDelegate,TJRImageClickDelegate>{
    BOOL bCheck;
}
@property (retain, nonatomic) IBOutlet TJRHeadView *headView;
@property (retain, nonatomic) IBOutlet UILabel *lbTime;
@property (retain, nonatomic) IBOutlet MLEmojiLabel *content;
@property (retain, nonatomic) IBOutlet UILabel *lbName;
@property (retain, nonatomic) IBOutlet UILabel *lbRoleName;
@property (retain, nonatomic) IBOutlet UIView *warningView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorWarning;
@property (retain, nonatomic) IBOutlet UIButton *btnWarning;
@property (retain, nonatomic) IBOutlet UIView *cellView;
@end

@implementation CircleChatTextCell


- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initilization];
    }
    return self;
}

- (void)dealloc {

    [_headView release];
    [_lbTime release];
    [_bubbleView release];
    [_content release];
    [_lbName release];
    [_lbRoleName release];
    [_warningView release];
    [_indicatorWarning release];
    [_btnWarning release];
    [_cellView release];
    [super dealloc];
}

- (void)initilization{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView* bubbleView = (UIView*)[self viewWithTag:99];
    TJRHeadView* headView = (TJRHeadView*)[self viewWithTag:100];
    
    UILongPressGestureRecognizer *longPressGR = [[ UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressed:)];
    longPressGR.minimumPressDuration = 0.7;
    [bubbleView addGestureRecognizer:longPressGR];
    [longPressGR release];
    
    longPressGR = [[ UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressed:)];
    longPressGR.minimumPressDuration = 0.7;
    [headView addGestureRecognizer:longPressGR];
    [longPressGR release];

}

+ (float)getHeightOfCell:(NSString*)content isMine:(BOOL)isMine timeFormat:(NSString*)timeFormat{

    MLEmojiLabel *textLabel = [[MLEmojiLabel alloc]initWithFrame:CGRectMake(0, 0, 205, 3500)];
    NSDictionary* componentsDictionary = [textLabel extractEmojiText:content textFont:[UIFont systemFontOfSize:16] isNeedUrl:YES isNeedPhoneNumber:YES isNeedEmail:YES isNeedAt:NO isNeedPoundSign:NO isNeedFullcode:YES isNeedTjrAt:YES];
    [textLabel setEmojiTextWithDictionary:componentsDictionary];
    [textLabel sizeToFit];
    CGSize size = textLabel.frame.size;
    
    CGFloat textHeight = size.height;
    
    UITableViewCell* cell;
    if (isMine){
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CircleChatTextRightCell" owner:nil options:nil]lastObject];
        
    }
    else {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CircleChatTextLeftCell" owner:nil options:nil]lastObject];
    }
    [textLabel release];
    
    textHeight =  textHeight - 23;
    
    float height = timeFormat.length>0?textHeight + cell.frame.size.height:(textHeight + cell.frame.size.height - 20);
    
    return height;
}

- (void)willDispayTableViewCell:(BOOL)isMine{
    
    if (isMine) {
        //在右边
        [_content setCommonLinkColor:[UIColor whiteColor]];
    }else {
        //在左边
        [_content setCommonLinkColor:RGBA(64, 181, 255, 1)];
    }
}

#pragma mark - 设置文本cell
- (void)setTextCell:(CircleChatExtendEntity*)entity{

    //设置颜色需放在前面
    if ([entity.userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
        [_content setCommonLinkColor:[UIColor whiteColor]];
    }else {
        [_content setCommonLinkColor:RGBA(64, 181, 255, 1)];
    }
    
    [_headView showImageViewWithURL:entity.headUrl canTouch:YES userid:entity.userId isCornerRadius:YES userLevel:0];
    _headView.imageView.clickDelegate = self;
    
    [CommonUtil viewMasksToBounds:_headView cornerRadius:21 borderColor:RGBA(242, 242, 242, 1) borderWidth:1];
    
    _lbTime.text = entity.timeFormat;
    
    _bubbleView.bubbleType = bubbleText;
    
    _lbName.text = entity.userName;
    
    if (entity.roleName.length>0) {
        _lbRoleName.text = [NSString stringWithFormat:@" %@ ",entity.roleName];
    }else{
        _lbRoleName.text = @"";
    }
    
    _content.emojiDelegate = self;
    _content.frame = CGRectMake(_content.frame.origin.x, _content.frame.origin.y , 205, 3500);
    NSDictionary* componentsDictionary = [_content extractEmojiText:entity.say textFont:[UIFont systemFontOfSize:16] isNeedUrl:YES isNeedPhoneNumber:YES isNeedEmail:YES isNeedAt:NO isNeedPoundSign:NO isNeedFullcode:YES isNeedTjrAt:YES];
    [_content setEmojiTextWithDictionary:componentsDictionary];
    
    [_content sizeToFit];
    CGSize size = _content.frame.size;
    CGRect bubbleRect = _bubbleView.frame;
    bubbleRect.size.width = 21 + size.width + 12;
    bubbleRect.size.height = 8 + size.height + 10;
    
    CGRect frame = _lbName.frame;
    CGSize nsize = [_lbName sizeThatFits:CGSizeMake(200, frame.size.height)];
    

    frame = _lbRoleName.frame;
    CGSize rsize = [_lbRoleName sizeThatFits:CGSizeMake(200, frame.size.height)];
    
    //调整气泡坐标和大小
    if ([entity.userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
        //在右边
        bubbleRect.origin.x = self.frame.size.width - 15 - bubbleRect.size.width ;

        _content.frame = CGRectMake(10, 10, _content.frame.size.width, size.height + 2);
        
        [_content setCommonLinkColor:[UIColor whiteColor]];
        [_bubbleView setBubbleDelegate:self Side:rightOrientation];
        
        CGRect frame = _warningView.frame;
        frame.origin.x = bubbleRect.origin.x - 20 - frame.size.width;
        _warningView.frame = frame;
        
        _lbName.frame = CGRectMake(bubbleRect.origin.x + bubbleRect.size.width - nsize.width, _lbName.frame.origin.y, nsize.width, nsize.height);
        _lbRoleName.frame = CGRectMake(_lbName.frame.origin.x - rsize.width - 3, _lbName.frame.origin.y + 1, rsize.width, nsize.height - 2);
        
    }else {
        //在左边
        _content.frame = CGRectMake(16, 10, _content.frame.size.width, size.height + 2);
        [_content setCommonLinkColor:RGBA(64, 181, 255, 1)];
        [_bubbleView setBubbleDelegate:self Side:leftOrientation];
        
        _lbName.frame = CGRectMake(_lbName.frame.origin.x, _lbName.frame.origin.y, nsize.width, nsize.height);
        _lbRoleName.frame = CGRectMake(_lbName.frame.origin.x + _lbName.frame.size.width + 5, _lbName.frame.origin.y + 1, rsize.width, nsize.height - 2);
    }
    [self showCellActivityIndicator:entity.isUploading];
    [self showCellError:entity.isUploadFailed];
    
    _bubbleView.frame = bubbleRect;
    
    if (entity.isClicked) {
        [_bubbleView checkBubbleView];
    }else{
        [_bubbleView unCheckBubbleView];
    }
    
    frame = _lbTime.frame;
    
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
    
    frame = _cellView.frame;
    frame.origin.y = _lbTime.frame.origin.y + _lbTime.frame.size.height;
    frame.size.height = _bubbleView.frame.origin.y + _bubbleView.frame.size.height + 5;
    _cellView.frame = frame;
    
}


- (void)showCellActivityIndicator:(BOOL)show{
    
    _indicatorWarning.hidden = YES;
    show?[_indicatorWarning startAnimating]:[_indicatorWarning stopAnimating];
}

- (void)showCellError:(BOOL)show{

    _btnWarning.hidden = !show;
}

- (IBAction)buttonErrorClicked:(id)sender{
    if ([_delegate respondsToSelector:@selector(circleChatTextCell:buttonErrorClicked:)])
        [_delegate circleChatTextCell:self buttonErrorClicked:sender];
}

- (void)handleLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        if ([recognizer.view isKindOfClass:[TJRHeadView class]]) {
            if ([_delegate respondsToSelector:@selector(circleChatTextCell:headViewLongPressed:name:)]){
                NSString* userId = _headView.imageView.userId;
                NSString* userName = _lbName.text;
                [_delegate circleChatTextCell:self headViewLongPressed:userId name:userName];
            }
        }else{
            if ([_delegate respondsToSelector:@selector(circleChatTextCell:handleLongPressed:)])
                [_delegate circleChatTextCell:self handleLongPressed:recognizer];
        }
    }
}

#pragma mark - 链接单击事件总方法
- (void)mlEmojiLabel:(MLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link detail:(NSDictionary *)detail {
    if (detail) {
        MLEmojiLabelLinkType type = [[detail objectForKey:ClickLinkType] integerValue];
        
        switch (type) {
            case MLEmojiLabelLinkTypeURL:	/* 网址点击 */
            {
                NSString *url = [detail objectForKey:ClickDetail];
                if ([_delegate respondsToSelector:@selector(circleChatTextCell:linkClicked:)]){
                    [_delegate circleChatTextCell:self linkClicked:url];
                }
                
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
                if ([_delegate respondsToSelector:@selector(circleChatTextCell:fullcodeClicked:)]){
                    [_delegate circleChatTextCell:self fullcodeClicked:fdm];
                }
                break;
            }
                
            case MLEmojiLabelLinkTypeTjrAt:	/* 名字点击跳转 */
            {
                NSString *str = [detail objectForKey:ClickDetail];
                if ([_delegate respondsToSelector:@selector(circleChatTextCell:paramsClicked:)]){
                    [_delegate circleChatTextCell:self paramsClicked:str];
                }
                break;
            }
                
            case MLEmojiLabelLongPress:	/* 长按 */
            {
                if ([_delegate respondsToSelector:@selector(circleChatTextCell:handleLongPressed:)]){
                    [_delegate circleChatTextCell:self handleLongPressed:nil];
                }
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - head 单击事件
- (void)imageHeadClicked:(id)imageView userId:(NSString*)userId{
    
    if ([_delegate respondsToSelector:@selector(circleChatTextCell:headViewClicked:name:)]){
        NSString* userName = _lbName.text;
        [_delegate circleChatTextCell:self headViewClicked:userId name:userName];
    }
}

@end
