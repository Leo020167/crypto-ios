//
//  CircleChatVoiceCell.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12/8/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "CircleChatVoiceCell.h"
#import "TJRHeadView.h"
#import "CircleChatExtendEntity.h"
#import "VeDateUtil.h"
#import "TJRVoicePlayView.h"
#import "CommonUtil.h"

@interface CircleChatVoiceCell ()<TJRImageAndDownFileDelegate,TJRImageClickDelegate>{
    
}
@property (retain, nonatomic) IBOutlet TJRHeadView *headView;
@property (retain, nonatomic) IBOutlet UILabel *lbTime;
@property (retain, nonatomic) IBOutlet UILabel *lbName;
@property (retain, nonatomic) IBOutlet UILabel *lbRoleName;
@property (retain, nonatomic) IBOutlet UIView *warningView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorWarning;
@property (retain, nonatomic) IBOutlet UIButton *btnWarning;
@property (retain, nonatomic) IBOutlet UILabel *lbSecond;

@property (retain, nonatomic) IBOutlet UIView *cellView;
@property (retain, nonatomic) IBOutlet UIImageView *ivNews;

@property (copy, nonatomic) NSString *voiceUrl;
@end

@implementation CircleChatVoiceCell


- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initilization];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_voiceUrl release];
    [_headView release];
    [_lbTime release];
    [_lbName release];
    [_lbRoleName release];
    [_warningView release];
    [_indicatorWarning release];
    [_btnWarning release];
    [_lbSecond release];
    [_voicePlayView release];
    [_cellView release];
    [_ivNews release];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceViewNotification:) name:TJRVoicePlayViewPlayKey object:nil];
}

+ (float)getHeightOfCell:(NSString*)content isMine:(BOOL)isMine timeFormat:(NSString*)timeFormat{
    
    UITableViewCell* cell;
    if (isMine)
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CircleChatVoiceRightCell" owner:nil options:nil]lastObject];
    else
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CircleChatVoiceLeftCell" owner:nil options:nil]lastObject];
    
    float h = timeFormat.length>0?cell.frame.size.height:(cell.frame.size.height - 20);
    
    return h;
}

#pragma mark - 设置Voice cell
- (void)setPlayView:(CircleChatExtendEntity*)entity{
    _voicePlayView.direction = [entity.userId isEqualToString:ROOTCONTROLLER_USER.userId];
    [_voicePlayView setVoiceViewShowType:TJRVoicePlayViewShowType_Image_Circle];
    _voicePlayView.viewMaxWidth = self.frame.size.width - 160;
    _voicePlayView.viewMinWidth = 80;
}

- (void)setVoiceCell:(CircleChatExtendEntity*)entity{
    
    [_headView showImageViewWithURL:entity.headUrl canTouch:YES userid:entity.userId isCornerRadius:YES userLevel:0];
    _headView.imageView.clickDelegate = self;
    
    [CommonUtil viewMasksToBounds:_headView cornerRadius:21 borderColor:RGBA(242, 242, 242, 1) borderWidth:1];
    
    _lbTime.text = entity.timeFormat;
    _lbTime.frame = CGRectMake(SCREEN_WIDTH/2 - 40, _lbTime.frame.origin.y, 80, _lbTime.frame.size.height);
    
    _lbName.text = entity.userName;
    
    if (entity.roleName.length>0) {
        _lbRoleName.text = [NSString stringWithFormat:@" %@ ",entity.roleName];
    }else{
        _lbRoleName.text = @"";
    }

    self.voiceUrl = entity.say;
    [_voicePlayView setVoiceFileUrl:entity.say voiceLength:entity.voiceLength];
    _voicePlayView.lbTimeLength.textColor = [UIColor clearColor];
    
    
    _ivNews.hidden = entity.isRead;
    
    CGRect frame = _lbName.frame;
    CGSize nsize = [_lbName sizeThatFits:CGSizeMake(200, frame.size.height)];
    
    frame = _lbRoleName.frame;
    CGSize rsize = [_lbRoleName sizeThatFits:CGSizeMake(200, frame.size.height)];
    
    if ([entity.userId isEqualToString:ROOTCONTROLLER_USER.userId]) {
        //在右边
        float originX = _voicePlayView.frame.origin.x - 15 - _lbSecond.frame.size.width;
        _lbSecond.frame = CGRectMake(originX , _lbSecond.frame.origin.y, _lbSecond.frame.size.width, _lbSecond.frame.size.height);
        
        CGRect frame = _warningView.frame;
        frame.origin.x = _voicePlayView.frame.origin.x - 30 - frame.size.width;
        _warningView.frame = frame;
        
        _lbName.frame = CGRectMake(_voicePlayView.frame.origin.x + _voicePlayView.frame.size.width - nsize.width, _lbName.frame.origin.y, nsize.width, nsize.height);
        _lbRoleName.frame = CGRectMake(_lbName.frame.origin.x - rsize.width - 3, _lbName.frame.origin.y + 1, rsize.width, nsize.height - 2);
        
        if (entity.isClicked) {
            _voicePlayView.backgroundImage = [UIImage imageNamed:@"circleChat_bubble_bg_right_b"];
        }else{
            _voicePlayView.backgroundImage = [UIImage imageNamed:@"circleChat_bubble_bg_right"];
        }
        
        _ivNews.hidden = YES;
        
    }else {
        //在左边
        float originX = _voicePlayView.frame.origin.x + _voicePlayView.frame.size.width + 7;
        _lbSecond.frame = CGRectMake(originX , _lbSecond.frame.origin.y, _lbSecond.frame.size.width, _lbSecond.frame.size.height);
        _ivNews.frame = CGRectMake(originX - 4 , _ivNews.frame.origin.y, _ivNews.frame.size.width, _ivNews.frame.size.height);
        if (entity.isClicked) {
            _voicePlayView.backgroundImage = [UIImage imageNamed:@"circleChat_bubble_bg_left_b"];
        }else{
            _voicePlayView.backgroundImage = [UIImage imageNamed:@"circleChat_bubble_bg_left"];
        }
        
        _lbName.frame = CGRectMake(_lbName.frame.origin.x, _lbName.frame.origin.y, nsize.width, nsize.height);
        _lbRoleName.frame = CGRectMake(_lbName.frame.origin.x + _lbName.frame.size.width + 5, _lbName.frame.origin.y + 1, rsize.width, nsize.height - 2);
    }
    _lbSecond.text = [NSString stringWithFormat:@"%@\"",entity.voiceLength];
    

    
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
    frame.size.height = _voicePlayView.frame.origin.y + _voicePlayView.frame.size.height + 5;
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
    if ([_delegate respondsToSelector:@selector(circleChatVoiceCell:buttonErrorClicked:)])
        [_delegate circleChatVoiceCell:self buttonErrorClicked:sender];
}

- (void)playVoice:(NSString*)url voiceLength:(NSString *)voiceLength{
    [_voicePlayView downloadVoiceFileWithUrl:url voiceLength:voiceLength autoPlay:YES];
}

#pragma mark - TJRImageAndDownFile  Delegate  Methods
- (void)TJRVoiceShowHud{

}
- (void)TJRVoiceHideHud{

}
- (void)TJRDownloadFileFinish{
    
    UITableView *superView = nil;
    if (CURRENT_DEVICE_VERSION>=7.0) {
        superView = (UITableView*)self.superview.superview;
    }else{
        superView = (UITableView*)self.superview;
    }
    if ([(UITableView*)superView isKindOfClass:[UITableView class]] &&[superView indexPathForCell:self])
        [((UITableView*)superView) reloadData];
}

#pragma mark - clicked  Delegate  Methods
- (void)imageHeadClicked:(id)imageView userId:(NSString*)userId{
    
    if ([_delegate respondsToSelector:@selector(circleChatVoiceCell:headViewClicked:name:)]){
        NSString* userName = _lbName.text;
        [_delegate circleChatVoiceCell:self headViewClicked:userId name:userName];
    }
}


- (void)handleLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        if ([recognizer.view isKindOfClass:[TJRHeadView class]]) {
            if ([_delegate respondsToSelector:@selector(circleChatVoiceCell:headViewLongPressed:name:)]){
                NSString* userId = _headView.imageView.userId;
                NSString* userName = _lbName.text;
                [_delegate circleChatVoiceCell:self headViewLongPressed:userId name:userName];
            }
        }else{
            if ([_delegate respondsToSelector:@selector(circleChatVoiceCell:handleLongPressed:)])
                [_delegate circleChatVoiceCell:self handleLongPressed:recognizer];
        }
    }
}

- (void)voiceViewNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *url = [userInfo objectForKey:TJRVoicePlayViewVoiceUrlKey];
    if ([self.voiceUrl isEqualToString:url]) {
        if ([_delegate respondsToSelector:@selector(circleChatVoiceCell:voiceClicked:)])
            [_delegate circleChatVoiceCell:self voiceClicked:url];
    }
    
}


@end
