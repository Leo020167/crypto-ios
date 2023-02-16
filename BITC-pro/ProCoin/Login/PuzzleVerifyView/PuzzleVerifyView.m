//
//  PuzzleVerifyView.m
//  Redz
//
//  Created by taojinroad on 2018/10/9.
//  Copyright © 2018 淘金路. All rights reserved.
//

#import "PuzzleVerifyView.h"
#import "TJRImageAndDownFile.h"
#import "PuzzleSlider.h"
#import "TJRBaseParserJson.h"
#import "NetWorkManage+Security.h"

@interface PuzzleVerifyView (){
    BOOL bReqFinished;
}
@property (retain, nonatomic) IBOutlet TJRImageAndDownFile *imageBG;
@property (retain, nonatomic) IBOutlet UIView *baseView;
@property (retain, nonatomic) IBOutlet TJRImageAndDownFile *imgaePuzzle;
@property (retain, nonatomic) IBOutlet UIView *viewBG;
@property (retain, nonatomic) IBOutlet PuzzleSlider *slider;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (retain, nonatomic) IBOutlet UILabel *lbMsg;
@property (retain, nonatomic) IBOutlet UILabel *lbTips;

@property (copy, nonatomic) NSString *bigImgName;
@property (copy, nonatomic) NSString *dragImgKey;
@property (copy, nonatomic) NSString *smallImgName;
@property (copy, nonatomic) NSString *sourceImgName;

@property (assign, nonatomic) NSInteger locationy;
@property (assign, nonatomic) NSInteger maxValue;
@end

@implementation PuzzleVerifyView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initView];
    }
    
    return self;
}


- (void)initView {
    
    [[NSBundle mainBundle] loadNibNamed:@"PuzzleVerifyView" owner:self options:nil];
    CGRect frame = self.baseView.frame;
    frame.origin = CGPointZero;
    frame.size = self.frame.size;
    self.baseView.frame = frame;
    
    [self addSubview:self.baseView];
    
    self.alpha = 0;
    _viewBG.alpha = 0;
    bReqFinished = YES;
    _imgaePuzzle.backgroundColor = [UIColor clearColor];
}
- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
    
    CGRect rect = _imgaePuzzle.frame;
    rect.origin.x = slider.value - slider.minimumValue;
    _imgaePuzzle.frame = rect;

}

- (IBAction)sliderDidEndOnExit:(id)sender {
    
    CGFloat x = _imgaePuzzle.frame.origin.x;
    if (x>0 && TTIsStringWithAnyText(_dragImgKey)) {
        [self requestCheckData:_dragImgKey locationx:x];
    }
}

- (IBAction)closeButtonClicked:(id)sender {
    [self hide];
}

- (IBAction)refreshButtonClicked:(id)sender {
    [self requestData];
}

- (void)setTips:(NSString*)tips{
    _lbTips.text = tips;
}

- (void)show:(UIView*)superView{
    
    [superView addSubview:self];
    
    [self requestData];
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            _viewBG.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)hide{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0;
        _viewBG.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)startAnimating{
    [_indicatorView startAnimating];
}

- (void)stopAnimating{
    [_indicatorView stopAnimating];
}

#pragma mark - 获取验证图片
- (void)requestData{
    
    if (bReqFinished) {
        bReqFinished = NO;
        [self startAnimating];
        [_slider setValue:0 animated:YES];
        _lbMsg.text = @"";
        [_slider start];
        [[NetWorkManage shareSingleNetWork] reqGetPuzzlePic:self finishedCallback:@selector(reqPuzzlePicFinished:) failedCallback:@selector(reqPuzzlePicFailed:)];
        
    }
}

- (void)reqPuzzlePicFinished:(id)result{
    bReqFinished = YES;
    [self stopAnimating];
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    NSDictionary* json = [result objectForKey:@"data"];
    if ([parser parseBaseIsOk:result]) {
        self.bigImgName = [parser stringParser:json name:@"bigImgName"];
        self.dragImgKey = [parser stringParser:json name:@"dragImgKey"];
        self.smallImgName = [parser stringParser:json name:@"smallImgName"];
        self.sourceImgName = [parser stringParser:json name:@"sourceImgName"];
        self.locationy = [parser intParser:json name:@"locationy"];
        self.maxValue = [parser intParser:json name:@"sourceImgWidth"];
        
        CGFloat width = [parser floatParser:json name:@"smallImgWidth"];
        CGFloat height = [parser floatParser:json name:@"smallImgHeight"];
        
        CGFloat sourceImgHeight = [parser floatParser:json name:@"sourceImgHeight"];
        CGFloat y = _imageBG.frame.size.height/sourceImgHeight*_locationy;
        _imgaePuzzle.frame = CGRectMake(0, y, width, height);
        NSLog(@"%@",[parser stringParser:json name:@"testX"]);
    }
    
    [_imageBG showImageViewWithURL:_bigImgName defaultImage:RectangleDefault userId:@""];
    [_imgaePuzzle showImageViewWithURL:_smallImgName];
}

- (void)reqPuzzlePicFailed:(id)result{
    bReqFinished = YES;
    [self stopAnimating];
}

#pragma mark - 验证验证码
- (void)requestCheckData:(NSString*)dragImgKey locationx:(NSInteger)locationx{
    
    if (bReqFinished) {
        bReqFinished = NO;
        [self startAnimating];
        [[NetWorkManage shareSingleNetWork] reqCheckPuzzlePic:self dragImgKey:dragImgKey locationx:locationx  finishedCallback:@selector(reqCheckFinished:) failedCallback:@selector(reqCheckFailed:)];
        
    }
}

- (void)reqCheckFinished:(id)result{
    bReqFinished = YES;
    [self stopAnimating];
    TJRBaseParserJson* parser = [[[TJRBaseParserJson alloc]init]autorelease];
    NSString* msg = [parser stringParser:result name:@"msg"];
    _lbMsg.text = msg;
    
    if ([parser parseBaseIsOk:result]) {
        [_slider end];
        [self performSelector:@selector(sendData) withObject:nil afterDelay:1];
    }else{
        _lbMsg.text = NSLocalizedStringForKey(@"验证错误，重新获取图片！");
        [self performSelector:@selector(requestData) withObject:nil afterDelay:1];
    }
    
}

- (void)reqCheckFailed:(id)result{
    bReqFinished = YES;
    [self stopAnimating];
    
}

- (void)sendData{
    
    if (_delegate && [_delegate respondsToSelector:@selector(puzzleVerifyView:dragImgKey:puzzleOriginX:)]) {
        CGFloat x = _imgaePuzzle.frame.origin.x;
        [_delegate puzzleVerifyView:self dragImgKey:_dragImgKey puzzleOriginX:x];
    }
    [self hide];
}

- (void)dealloc {
    [_bigImgName release];
    [_dragImgKey release];
    [_smallImgName release];
    [_sourceImgName release];
    [_baseView release];
    [_imageBG release];
    [_imgaePuzzle release];
    [_viewBG release];
    [_slider release];
    [_indicatorView release];
    [_lbMsg release];
    [_lbTips release];
    [super dealloc];
}
@end
