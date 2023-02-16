//
//  CircleChatJsonCell.m
//  TJRtaojinroad
//
//  Created by taojinroad on 4/21/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "CircleChatJsonCell.h"
#import "TJRHeadView.h"
#import "CircleChatBubbleView.h"
#import "MLEmojiLabel.h"
#import "CircleChatExtendEntity.h"
#import "VeDateUtil.h"
#import "CommonUtil.h"

@interface CircleChatJsonCell ()<TJRImageClickDelegate>{
    
}

@property (retain, nonatomic) IBOutlet TJRHeadView *headView;
@property (retain, nonatomic) IBOutlet UILabel *lbTime;
@property (retain, nonatomic) IBOutlet UILabel *lbName;
@property (retain, nonatomic) IBOutlet UILabel *lbRoleName;
@property (retain, nonatomic) IBOutlet UIView *warningView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorWarning;
@property (retain, nonatomic) IBOutlet UIButton *btnWarning;
@property (retain, nonatomic) IBOutlet UIView *cellView;

@property (retain, nonatomic) IBOutlet UILabel *lbTitle;
@property (retain, nonatomic) IBOutlet UIView *contentBubbleView;
@property (retain, nonatomic) IBOutlet TJRImageAndDownFile *logoView;
@property (retain, nonatomic) IBOutlet UILabel *lbContent;
@property (retain, nonatomic) IBOutlet UILabel *lbContentTime;

@property (copy, nonatomic) NSString *params;
@property (copy, nonatomic) NSString *pview;
@end

@implementation CircleChatJsonCell

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initilization];
    }
    return self;
}

- (void)dealloc {
    [_pview release];
    [_params release];
    [_headView release];
    [_lbTime release];
    [_bubbleView release];
    [_lbName release];
    [_lbRoleName release];
    [_warningView release];
    [_indicatorWarning release];
    [_btnWarning release];
    [_cellView release];
    [_lbTitle release];
    [_contentBubbleView release];
    [_logoView release];
    [_lbContent release];
    [_lbContentTime release];
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

+ (float)getHeightOfCell:(BOOL)isMine timeFormat:(NSString*)timeFormat say:(NSString*)say{
    
    UITableViewCell* cell;
    
    if (isMine){
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CircleChatJsonRightCell" owner:nil options:nil]lastObject];
    }else {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CircleChatJsonLeftCell" owner:nil options:nil]lastObject];
    }
    UILabel* lbTitle = (UILabel*)[cell viewWithTag:100];
    
    NSDictionary *json = [CommonUtil jsonValue:say];
    NSString* title = [json objectForKey:@"title"];
    
    lbTitle.text = title;
    CGSize titleSize = [CommonUtil getPerfectSizeByText:title andFontSize:16 andWidth:205];
    titleSize = [lbTitle sizeThatFits:CGSizeMake(205, titleSize.height)];
    float height = cell.frame.size.height + titleSize.height - 21;

    float h = timeFormat.length>0?height:(height - 20);
    
    return h;
}


#pragma mark - 设置文本cell
- (void)setJsonCell:(CircleChatExtendEntity*)entity{
    
    [_headView showImageViewWithURL:entity.headUrl canTouch:YES userid:entity.userId isCornerRadius:YES userLevel:0];
    _headView.imageView.clickDelegate = self;
    
    [CommonUtil viewMasksToBounds:_headView cornerRadius:21 borderColor:RGBA(242, 242, 242, 1) borderWidth:1];
    
    _lbTime.text = entity.timeFormat;
    
    _bubbleView.bubbleType = bubbleContent;
    
    _lbName.text = entity.userName;
    
    if (entity.roleName.length>0) {
        _lbRoleName.text = [NSString stringWithFormat:@" %@ ",entity.roleName];
    }else{
        _lbRoleName.text = @"";
    }
    
    CGRect frame = _lbName.frame;
    CGSize nsize = [_lbName sizeThatFits:CGSizeMake(200, frame.size.height)];
    
    frame = _lbRoleName.frame;
    CGSize rsize = [_lbRoleName sizeThatFits:CGSizeMake(200, frame.size.height)];
    
    
    NSDictionary *json = [CommonUtil jsonValue:entity.say];
    self.pview = [json objectForKey:@"pview"];
    self.params = [json objectForKey:@"params"];
    
    
    NSString* title = [json objectForKey:@"title"];
    _lbTitle.text = title;
    CGSize titleSize = [CommonUtil getPerfectSizeByText:title andFontSize:16 andWidth:205];
    titleSize = [_lbTitle sizeThatFits:CGSizeMake(205, titleSize.height)];
    _lbTitle.frame = CGRectMake(_lbTitle.frame.origin.x, _lbTitle.frame.origin.y, _lbTitle.frame.size.width, titleSize.height);
    _contentBubbleView.frame = CGRectMake(_contentBubbleView.frame.origin.x, _lbTitle.frame.origin.y + titleSize.height, _contentBubbleView.frame.size.width, _contentBubbleView.frame.size.height);
    
    
    NSString* content = [json objectForKey:@"content"];

    _lbContent.text = content;
    CGSize contentSize = [CommonUtil getPerfectSizeByText:content andFontSize:13 andWidth:130];
    contentSize = [_lbContent sizeThatFits:contentSize];
    _lbContent.frame = CGRectMake(_lbContent.frame.origin.x, _lbContent.frame.origin.y, _lbContent.frame.size.width, contentSize.height);
    
    [_logoView showImageViewWithURL:[json objectForKey:@"logo"]];
    _lbContentTime.text = [VeDateUtil dateFormatterToCircleGame:[NSString stringWithFormat:@"%@",[json objectForKey:@"time"]]];
    
    CGFloat width = _bubbleView.frame.size.width;
    CGFloat height = titleSize.height + _contentBubbleView.frame.size.height + 8;
   
    //调整气泡坐标和大小
    if ([entity.userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
        //在右边
        _bubbleView.frame = CGRectMake(self.frame.size.width - width - 15, _bubbleView.frame.origin.y, width, height);
        
        CGRect frame = _warningView.frame;
        frame.origin.x = _bubbleView.frame.origin.x - 20 - frame.size.width;
        _warningView.frame = frame;
        
        [_bubbleView setBubbleDelegate:self Side:rightOrientation];
        
        _lbName.frame = CGRectMake(_bubbleView.frame.origin.x + _bubbleView.frame.size.width - nsize.width, _lbName.frame.origin.y, nsize.width, nsize.height);
        _lbRoleName.frame = CGRectMake(_lbName.frame.origin.x - rsize.width - 3, _lbName.frame.origin.y + 1, rsize.width, nsize.height - 2);
        
    }else {
        //在左边
        _bubbleView.frame = CGRectMake(_headView.frame.origin.x + _headView.frame.size.width + 12, _lbName.frame.origin.y + _lbName.frame.size.height + 5, width, height);
        [_bubbleView setBubbleDelegate:self Side:leftOrientation];
        
        _lbName.frame = CGRectMake(_lbName.frame.origin.x, _lbName.frame.origin.y, nsize.width, nsize.height);
        _lbRoleName.frame = CGRectMake(_lbName.frame.origin.x + _lbName.frame.size.width + 5, _lbName.frame.origin.y + 1, rsize.width, nsize.height - 2);
    }
    if (entity.isClicked) {
        [_bubbleView checkBubbleView];
    }else{
        [_bubbleView unCheckBubbleView];
    }
    
    [self showCellActivityIndicator:entity.isUploading];
    [self showCellError:entity.isUploadFailed];
    
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
    if ([_delegate respondsToSelector:@selector(circleChatJsonCell:buttonErrorClicked:)])
        [_delegate circleChatJsonCell:self buttonErrorClicked:sender];
}

- (void)handleLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        if ([recognizer.view isKindOfClass:[TJRHeadView class]]) {
            if ([_delegate respondsToSelector:@selector(circleChatJsonCell:headViewLongPressed:name:)]){
                NSString* userId = _headView.imageView.userId;
                NSString* userName = _lbName.text;
                [_delegate circleChatJsonCell:self headViewLongPressed:userId name:userName];
            }
        }else{
            if ([_delegate respondsToSelector:@selector(circleChatJsonCell:handleLongPressed:)])
                [_delegate circleChatJsonCell:self handleLongPressed:recognizer];
        }
    }
}

- (IBAction)contentViewBtnClicked:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(circleChatJsonCell:contentCellTouched:pview:params:)])
        [_delegate circleChatJsonCell:self contentCellTouched:sender pview:self.pview params:self.params];
}

#pragma mark - head 单击事件
- (void)imageHeadClicked:(id)imageView userId:(NSString*)userId{
    
    if ([_delegate respondsToSelector:@selector(circleChatJsonCell:headViewClicked:name:)]){
        NSString* userName = _lbName.text;
        [_delegate circleChatJsonCell:self headViewClicked:userId name:userName];
    }
}

@end
