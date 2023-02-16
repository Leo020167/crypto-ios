//
//  CircleChatImageCell.m
//  TJRtaojinroad
//
//  Created by taojinroad on 12/8/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "CircleChatImageCell.h"
#import "TJRHeadView.h"
#import "CircleChatBubbleView.h"
#import "CircleChatExtendEntity.h"
#import "VeDateUtil.h"
#import "TJRImageAndDownFile.h"
#import "TTCacheManager.h"
#import "CommonUtil.h"

#define kMaxImageHeightWidth    130.0f       //图片最大宽高

@interface CircleChatImageCell ()<TJRImageAndDownFileDelegate,TJRImageClickDelegate>{
    
}
@property (retain, nonatomic) IBOutlet TJRHeadView *headView;
@property (retain, nonatomic) IBOutlet UILabel *lbTime;

@property (retain, nonatomic) IBOutlet UILabel *lbName;
@property (retain, nonatomic) IBOutlet UILabel *lbRoleName;
@property (retain, nonatomic) IBOutlet UIView *warningView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorWarning;
@property (retain, nonatomic) IBOutlet UIButton *btnWarning;
@property (retain, nonatomic) IBOutlet UIView *cellView;

@property (copy, nonatomic) NSString *imageURL;
@end

@implementation CircleChatImageCell


- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initilization];
    }
    return self;
}

- (void)dealloc {
    [_imageURL release];
    [_headView release];
    [_lbTime release];
    [_bubbleView release];
    [_lbName release];
    [_lbRoleName release];
    [_warningView release];
    [_indicatorWarning release];
    [_btnWarning release];
    [_imageAndDownFile release];
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

+ (float)getHeightOfCell:(BOOL)isMine size:(CGSize)size timeFormat:(NSString*)timeFormat{
    
    UITableViewCell* cell;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    float rate = MIN(width, height)/MAX(width, height);
    if (height > width){
        height =  kMaxImageHeightWidth;
        width = height * rate;
    }else{
        width = kMaxImageHeightWidth;
        height = width * rate;
    }
    
    width += 10;
    height += 5;
    
    if (isMine){
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CircleChatImageRightCell" owner:nil options:nil]lastObject];
    }else {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CircleChatImageLeftCell" owner:nil options:nil]lastObject];
    }
    height =  height - 55;
    
    float h = timeFormat.length>0?height + cell.frame.size.height:(height + cell.frame.size.height - 20);
    
    return h;
}

#pragma mark - 设置文本cell
- (void)setImageCell:(CircleChatExtendEntity*)entity{
    
    [_headView showImageViewWithURL:entity.headUrl canTouch:YES userid:entity.userId isCornerRadius:YES userLevel:0];
    _headView.imageView.clickDelegate = self;
    
    [CommonUtil viewMasksToBounds:_headView cornerRadius:21 borderColor:RGBA(242, 242, 242, 1) borderWidth:1];
    
    _lbTime.text = entity.timeFormat;
    _lbTime.frame = CGRectMake(SCREEN_WIDTH/2 - 40, _lbTime.frame.origin.y, 80, _lbTime.frame.size.height);
    
    _lbName.text = entity.userName;
    self.imageURL = entity.say;
    
    
    if (entity.roleName.length>0) {
        _lbRoleName.text = [NSString stringWithFormat:@" %@ ",entity.roleName];
    }else{
        _lbRoleName.text = @"";
    }
    
    CGRect frame = _lbName.frame;
    CGSize nsize = [_lbName sizeThatFits:CGSizeMake(200, frame.size.height)];
    
    frame = _lbRoleName.frame;
    CGSize rsize = [_lbRoleName sizeThatFits:CGSizeMake(200, frame.size.height)];
    
    _bubbleView.bubbleType = bubbleImage;
    
    _imageAndDownFile.tjrDelegate = self;
    
    if (entity.isUploading) {
        NSString *path = [CommonUtil TTPathForDocumentsResourceEtag:entity.say];
        _imageAndDownFile.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
    }else{
        [_imageAndDownFile showImageViewWithURL:entity.say];
    }

    CGFloat width = entity.imgSize.width;
    CGFloat height = entity.imgSize.height;
    
    float rate = MIN(width, height)/MAX(width, height);
    if (height > width){
        height =  kMaxImageHeightWidth;
        width = height * rate;
    }else{
        width = kMaxImageHeightWidth;
        height = width * rate;
    }
    
    width += 10;
    height += 5;
    
    if ([entity.userId isEqualToString:ROOTCONTROLLER_USER.userId]){
        _bubbleView.frame = CGRectMake(self.frame.size.width - width - 15, _bubbleView.frame.origin.y, width, height);
        
        CGRect frame = _warningView.frame;
        frame.origin.x = _bubbleView.frame.origin.x - 20 - frame.size.width;
        _warningView.frame = frame;
        
        [_bubbleView setBubbleDelegate:self Side:rightOrientation];
        
        _lbName.frame = CGRectMake(_bubbleView.frame.origin.x + _bubbleView.frame.size.width - nsize.width, _lbName.frame.origin.y, nsize.width, nsize.height);
        _lbRoleName.frame = CGRectMake(_lbName.frame.origin.x - rsize.width - 3, _lbName.frame.origin.y + 1, rsize.width, nsize.height - 2);
    }else{
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
    if ([_delegate respondsToSelector:@selector(circleChatImageCell:buttonErrorClicked:)])
        [_delegate circleChatImageCell:self buttonErrorClicked:sender];
}


#pragma mark - TJRImageAndDownFile  Delegate  Methods
- (void)TJRDownloadFileStartLoad:(NSString*)url{
    
    NSString *path = [CommonUtil TTPathForDocumentsResourceEtag:url];
    _imageAndDownFile.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
}

- (void)TJRDownloadFileFinish{
    
    UITableView *superView = nil;
    if (CURRENT_DEVICE_VERSION>=7.0) {
        superView = (UITableView*)self.superview.superview;
    }else{
        superView = (UITableView*)self.superview;
    }
    if ([(UITableView*)superView isKindOfClass:[UITableView class]] &&[superView indexPathForCell:self]){
        [((UITableView*)superView) reloadData];
    }
}

#pragma mark - clicked  Delegate  Methods
- (void)imageHeadClicked:(id)imageView userId:(NSString*)userId{
    if ([_delegate respondsToSelector:@selector(circleChatImageCell:headViewClicked:name:)]){
        NSString* userName = _lbName.text;
        [_delegate circleChatImageCell:self headViewClicked:userId name:userName];
    }
}

- (void)handleLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        if ([recognizer.view isKindOfClass:[TJRHeadView class]]) {
            if ([_delegate respondsToSelector:@selector(circleChatImageCell:headViewLongPressed:name:)]){
                NSString* userId = _headView.imageView.userId;
                NSString* userName = _lbName.text;
                [_delegate circleChatImageCell:self headViewLongPressed:userId name:userName];
            }
        }else{
            if ([_delegate respondsToSelector:@selector(circleChatImageCell:handleLongPressed:)])
                [_delegate circleChatImageCell:self handleLongPressed:recognizer];
        }
    }
}


- (IBAction)imageViewBtnClicked:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(circleChatImageCell:imageViewTouched:url:)])
        [_delegate circleChatImageCell:self imageViewTouched:_imageAndDownFile url:_imageURL];
}

@end
