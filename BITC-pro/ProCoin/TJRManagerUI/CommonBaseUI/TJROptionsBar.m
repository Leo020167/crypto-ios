//
//  TJROptionsBar.m
//  TJRtaojinroad
//
//  Created by Hay on 13-3-20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJROptionsBar.h"
#import "TJRScrollView.h"
#import "CommonUtil.h"

@implementation TJROptionsBar

@synthesize OriginOptsPosXCenter;
@synthesize OriginOptsPosYCenter;
@synthesize bIsClick;
@synthesize originOptsPos;
@synthesize nextBtnDistance;
@synthesize optionsBarDelegate;
@synthesize optionsData;
@synthesize btnGuideImageView;
@synthesize fontSize;
@synthesize unSelectOptTextColor;
@synthesize selectOptTextColor;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder])){
        //选项栏是否水平排列，yes为是，no为竖直排列
        if(self.frame.size.width > self.frame.size.height){
            bIsOptsBarHorizontal = YES;
        }else{
            bIsOptsBarHorizontal = NO;
        }
        [self initScrollViewAndImageView];
        [self initLabelComponent];
        [self setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //选项栏是否水平排列，yes为是，no为竖直排列
        if(self.frame.size.width > self.frame.size.height) bIsOptsBarHorizontal = YES;
        else bIsOptsBarHorizontal = NO;
        [self initScrollViewAndImageView];
        [self initLabelComponent];
        [self setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
    }
    return self;
}

- (void)dealloc
{
    [backgroundView release];
    [backgroundScrollView release];
    [buttonImage release];
    [btnGuideImageView release];
    [optionsData release];
    [unSelectOptTextColor release];
    [selectOptTextColor release];
    [super dealloc];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)initScrollViewAndImageView                      //初始化scrollView和提示图片视图
{
    CGRect frame = self.frame;              //父类frame
    backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
    [backgroundView setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
    
    backgroundScrollView = [[TJRScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
    [backgroundScrollView setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth];
    
    self.backgroundColor = [UIColor colorWithRed:188.0f/255.0f green:188.0f/255.0f blue:188.0f/255.0f alpha:1.0f];
    backgroundScrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:backgroundView];
    [self addSubview:backgroundScrollView];
    btnGuideImageView = [[UIImageView alloc] init];
    [backgroundScrollView addSubview:btnGuideImageView];
    
}

#pragma mark - 初始化选项栏默认文字字体和初始位置
- (void)initLabelComponent
{
    bIsClick = YES;                         //能点击
    bRefreshScrollView = YES;               //需要刷新scrollView
    nextBtnDistance = 50;                   //按钮之间的距离差默认为50
    fontSize = 17;                          //默认字体大小为17
    if(bIsOptsBarHorizontal){
        OriginOptsPosXCenter = 0;
        OriginOptsPosYCenter = (self.frame.size.height / 2.0f) - ((fontSize + 2) / 2.0f);
        originOptsPos.x= 13;                      //文字选项的初始x位置为13
        originOptsPos.y = OriginOptsPosYCenter;   //文字选项的初始y位置为居中位置
        nextOptionX = originOptsPos.x;            //最初的选项位置x坐标跟起始位置Y坐标一样
        GuideImagePosXGap = 10;                          //指示图片的X坐标偏差
        GuideImagePosYGap = 5;                          //指示图片的Y坐标偏差
        GuideImageWidthGap = 20;                        //指示图片的宽度偏差
        GuideImageHeightGap = 10;                      //指示图片的高度偏差
        
    }else{
        OriginOptsPosXCenter = (self.frame.size.width / 2.0f) - (fontSize /2.0f);
        OriginOptsPosYCenter = 0;
        originOptsPos.x= OriginOptsPosXCenter;     //文字选项的初始X位置为居中位置
        originOptsPos.y = 13;                      //文字选项的初始Y位置为13
        nextOptionY = originOptsPos.y;             //最初的选项位置Y坐标跟起始位置Y坐标一样
        GuideImagePosXGap = 5;                        //指示图片的X坐标偏差
        GuideImagePosYGap = 10;                        //指示图片的Y坐标偏差
        GuideImageWidthGap = 10;                       //指示图片的宽度偏差
        GuideImageHeightGap = 20;                      //指示图片的高度偏差
    }
    if(selectOptTextColor == nil){
        selectOptTextColor = [[UIColor colorWithRed:89.0f/255.0f green:184.0f/255.0f blue:228.0f/255.0f alpha:1.0f] retain];     //选中选项的默认颜色
    }
    if(unSelectOptTextColor == nil){
        unSelectOptTextColor = [[UIColor colorWithRed:83.0f/255.0f green:83.0f/255.0f blue:83.0f/255.0f alpha:1.0f] retain];      //未选中选项的默认颜色
    }
}

#pragma mark - 设置每个按钮的默认宽度或者高度
- (void)setNextBtnDistance:(NSInteger)_nextBtnDistance
{
    nextBtnDistance = _nextBtnDistance;
    [self removeAllViewsFromScrollView];
    [self addOptionsToScrollView];
}

#pragma mark - 设置背景颜色
- (void)setOptionsBarBackgroundColor:(UIColor *)rgb
{
    self.backgroundColor = rgb;
}

#pragma mark - 设置背景图片
- (void)setOptionsBarBackgroundImage:(UIImage *)image
{
    backgroundView.image = image;
}

#pragma mark - 设置指示图片
- (void)setOptionsBarGuideImage:(UIImage *)image
{
    btnGuideImageView.image = image;
}

#pragma mark - 设置指示图片的整体便宜差
- (void)setOptionBarGuideFrameGap:(CGFloat)posXGap posYGap:(CGFloat)posYGap widthGap:(CGFloat)widthGap heightGap:(CGFloat)heightGap
{
    GuideImagePosXGap = posXGap;                        //指示图片的X坐标偏差
    GuideImagePosYGap = posYGap;                        //指示图片的Y坐标偏差
    GuideImageWidthGap = widthGap;                       //指示图片的宽度偏差
    GuideImageHeightGap = heightGap;                      //指示图片的高度偏差
    [self removeAllViewsFromScrollView];
    [self addOptionsToScrollView];
}

#pragma mark - 设置文字按钮背景图片
- (void)setOptionsBarButtonImage:(UIImage *)image
{
    if(buttonImage){
        [buttonImage release];
        buttonImage = nil;
    }
    buttonImage = [image retain];
    [self removeAllViewsFromScrollView];
    [self addOptionsToScrollView];
}

#pragma mark - 文字大小
- (void)setFontSize:(CGFloat)_fontSize
{
    fontSize = _fontSize;
    [self removeAllViewsFromScrollView];
    [self addOptionsToScrollView];           //添加选项操作
}

#pragma mark - 未选中选项的字体颜色
- (void)setUnSelectOptTextColor:(UIColor *)textColor
{
    if(unSelectOptTextColor){
        [unSelectOptTextColor release];
        unSelectOptTextColor = nil;
    }
    [textColor retain];
    unSelectOptTextColor = textColor;
    [self removeAllViewsFromScrollView];
    [self addOptionsToScrollView];                   //添加选项操作
}

#pragma mark - 设置选中选项的字体颜色
- (void)setSelectOptTextColor:(UIColor *)textColor
{
    if(selectOptTextColor){
        [selectOptTextColor release];
        selectOptTextColor = nil;
    }
    [textColor retain];
    selectOptTextColor = textColor;
    [self removeAllViewsFromScrollView];
    [self addOptionsToScrollView];                   //添加选项操作
}


#pragma mark - 设置选项栏的文字数据
- (void)setOptionsData:(NSArray *)_optionsData
{
    if(optionsData){
        [optionsData release];
        optionsData = nil;
    }
    [_optionsData retain];
    optionsData = _optionsData;
    [self removeAllViewsFromScrollView];
    [self addOptionsToScrollView];                   //添加选项操作
}
#pragma mark - 设置选项栏的第一个选项初始位置
- (void)setOriginOptsPos:(CGPoint)_originOptsPos;        //选项初始位置设置
{
    originOptsPos = _originOptsPos;
    [self removeAllViewsFromScrollView];
    [self addOptionsToScrollView];
}


#pragma mark - 添加文字选项和按钮到scrollView里面
- (void)addOptionsToScrollView
{
    if(bRefreshScrollView){          //当需要刷新scrollView时再刷新
        if([optionsData count] > 0){                          //选项底部提示图片初始化
            bRefreshScrollView = NO;     //不再需要刷新scrollView
            NSString *firstStr = [NSString stringWithFormat:@"%@",[optionsData objectAtIndex:0]];
            
            CGSize firstLabelSize;            //第一个字体label的大小, 主要用来设置图片的宽高度
            UIImage *btnGuideImage;           //btnGuideImageView的image
            if(bIsOptsBarHorizontal){         //按钮水平方向排序
                //计算当高度一定时，宽度的大小
                CGSize constraint = CGSizeMake(2000.0f, fontSize);
                firstLabelSize = [firstStr boundingRectWithSize:constraint options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
                if(btnGuideImageView.image == nil){
                    btnGuideImage = [UIImage imageNamed:@"options_horizontal_button"];
                    btnGuideImage = [btnGuideImage stretchableImageWithLeftCapWidth:20 topCapHeight:20];
                    btnGuideImageView.image = btnGuideImage;
                }
                btnGuideImageView.frame = CGRectMake(nextOptionX - GuideImagePosXGap, originOptsPos.y - GuideImagePosYGap, firstLabelSize.width + GuideImageWidthGap, fontSize + GuideImageHeightGap);
            }else{                            //按钮竖直方向排序
                //计算当宽度一定时，高度的大小
                firstLabelSize = [CommonUtil getPerfectSizeByText:firstStr andFontSize:fontSize andWidth:fontSize];
                if(btnGuideImageView.image == nil){
                    btnGuideImage = [UIImage imageNamed:@"Kandapan_optionButton"];
                    btnGuideImage = [btnGuideImage stretchableImageWithLeftCapWidth:13 topCapHeight:30];
                    btnGuideImageView.image = btnGuideImage;
                }
                btnGuideImageView.frame = CGRectMake(originOptsPos.x - GuideImagePosXGap, nextOptionY - GuideImagePosYGap, firstLabelSize.width + GuideImageWidthGap, firstLabelSize.height + GuideImageHeightGap);
            }
            
            for(int i = 0 ; i < [optionsData count] ; i++){
                NSString *str = [NSString stringWithFormat:@"%@",[optionsData objectAtIndex:i]];
                CGSize size;                           //每个选项的字体大小
                UILabel *titleLabel = nil;             //选项label文本
                UIButton *titleButton = nil;           //选项按钮
                UIImageView *buttonImageView = nil;    //按钮背景图片
                
                if(bIsOptsBarHorizontal){              //按钮水平方向排序
                    CGSize constraint = CGSizeMake(2000.0f, fontSize);
                    size = [str boundingRectWithSize:constraint options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
                    titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(nextOptionX,originOptsPos.y, size.width , fontSize)] autorelease];
                    nextOptionX = titleLabel.frame.origin.x + size.width + nextBtnDistance;               //下一个选项的X坐标
                    
                    titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    titleButton.frame = CGRectMake(titleLabel.frame.origin.x - nextBtnDistance / 2, 0, titleLabel.frame.size.width + nextBtnDistance, self.frame.size.height);              //因为每个按钮相间50，所以X坐标和宽度做出调整保证按钮的点击范围
                    
                }else{                                 //按钮竖直方向排序
                    size = [CommonUtil getPerfectSizeByText:str andFontSize:fontSize andWidth:fontSize];
                    titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(originOptsPos.x,nextOptionY, size.width , size.height)] autorelease];
                    nextOptionY = titleLabel.frame.origin.y + size.height + nextBtnDistance;               //下一个选项的Y坐标
                    
                    titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    titleButton.frame = CGRectMake(0, titleLabel.frame.origin.y - nextBtnDistance / 2, self.frame.size.width, titleLabel.frame.size.height + nextBtnDistance);          //因为每个按钮相间50，所以Y坐标和高度做出调整保证按钮的点击范围
                }
                
                
                if(buttonImage != nil){                         //假如buttonImage不为空
                    if(GuideImageWidthGap){
                        buttonImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x - GuideImagePosXGap, titleLabel.frame.origin.y - GuideImagePosYGap,titleLabel.frame.size.width + GuideImageWidthGap, titleLabel.frame.size.height + GuideImageHeightGap)] autorelease];
                    }else{
                        buttonImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x - GuideImagePosXGap, titleLabel.frame.origin.y - GuideImagePosYGap,titleLabel.frame.size.width + GuideImageWidthGap, titleLabel.frame.size.height + GuideImageHeightGap)] autorelease];
                    }
                    
                    buttonImageView.image = buttonImage;
                    buttonImageView.tag = 3000 + i;
                    [backgroundScrollView addSubview:buttonImageView];
                    [backgroundScrollView sendSubviewToBack:buttonImageView];
                }
                
                
                
                //文本和按钮的具体设置
                titleLabel.font = [UIFont systemFontOfSize:fontSize];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                titleLabel.numberOfLines = 0;
                titleLabel.backgroundColor = [UIColor clearColor];
                if(i == 0){
                    titleLabel.textColor = selectOptTextColor;
                    previousLabel = titleLabel;                         //记录当前的文本作为点击下一个时候重置该文本颜色
                }else
                    titleLabel.textColor = unSelectOptTextColor;
                titleLabel.tag = i + 1;
                titleLabel.text = str;
                titleButton.tag = i + [optionsData count] + 1;
                [titleButton addTarget:self action:@selector(optionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                [backgroundScrollView addSubview:titleButton];
                [backgroundScrollView addSubview:titleLabel];
            }
            //--------如果摆放选项的位置超过了scrollView的高度或宽度，则设置scrollView可滚动
            if(nextOptionY > self.frame.size.height){
                backgroundScrollView.contentSize = CGSizeMake(backgroundScrollView.frame.size.width, nextOptionY);
            }else if(nextOptionX - nextBtnDistance > self.frame.size.width){
                backgroundScrollView.contentSize = CGSizeMake(nextOptionX, backgroundScrollView.frame.size.height);
            }
            
        }
    }
}


#pragma mark - 按钮点击事件
- (void)optionButtonPressed:(id)sender
{
    if(!bIsClick) return;
    UIButton *opButton = (UIButton *)sender;
    UILabel *opLabel = (UILabel *)[backgroundScrollView viewWithTag:(opButton.tag - [optionsData count])];
    if(opLabel == previousLabel) return;
    
    previousLabel.textColor = unSelectOptTextColor;
    if(bIsOptsBarHorizontal){
        [UIView animateWithDuration:0.2 animations:^{
            btnGuideImageView.frame = CGRectMake(opLabel.frame.origin.x - GuideImagePosXGap, opLabel.frame.origin.y - GuideImagePosYGap,  opLabel.frame.size.width + GuideImageWidthGap, opLabel.frame.size.height + GuideImageHeightGap);
        } completion:^(BOOL finish){
            opLabel.textColor = selectOptTextColor;
            previousLabel = opLabel;
            if([optionsBarDelegate respondsToSelector:@selector(optionButtonClickEvent:)]){
                [optionsBarDelegate optionButtonClickEvent:opLabel.tag - 1];
            }
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            btnGuideImageView.frame = CGRectMake(opLabel.frame.origin.x - GuideImagePosXGap, opLabel.frame.origin.y - GuideImagePosYGap,  opLabel.frame.size.width + GuideImageWidthGap, opLabel.frame.size.height + GuideImageHeightGap);
        } completion:^(BOOL finish){
            opLabel.textColor = selectOptTextColor;
            previousLabel = opLabel;
            if([optionsBarDelegate respondsToSelector:@selector(optionButtonClickEvent:)]){
                [optionsBarDelegate optionButtonClickEvent:opLabel.tag - 1];
            }
        }];
    }
    
}

#pragma mark - 重置选项烂文字颜色和光标位置回到初始位置
- (void)resetOptionsBar
{
    [self optionFromIndexInOptionsBar:0];
    [backgroundScrollView setContentOffset:CGPointZero];
}

#pragma mark - 删除scrollView里面所有的控件
- (void)removeAllViewsFromScrollView
{
    bRefreshScrollView = YES;       //需要重新刷新一遍scrollView
    backgroundScrollView.contentSize = CGSizeMake(backgroundScrollView.frame.size.width, backgroundScrollView.frame.size.height);
    if(bIsOptsBarHorizontal){       //重新设置起始坐标
        nextOptionX = originOptsPos.x;
    }else{
        nextOptionY = originOptsPos.y;
    }
    NSArray *allViews = [backgroundScrollView subviews];
    for(int i = 0; i < [allViews count]; i++){
        if(btnGuideImageView != [allViews objectAtIndex:i]){
            [[allViews objectAtIndex:i] removeFromSuperview];
        }
    }
}

#pragma mark - 通过设置索引使选项栏选指定某个选项
- (void)optionFromIndexInOptionsBar:(NSInteger)optionIndex
{
    previousLabel.textColor = unSelectOptTextColor;
    UILabel *opLabel = (UILabel *)[backgroundScrollView viewWithTag:(optionIndex+ 1)];
    if(bIsOptsBarHorizontal){
        [UIView animateWithDuration:0.2 animations:^{
            btnGuideImageView.frame = CGRectMake(opLabel.frame.origin.x - GuideImagePosXGap, opLabel.frame.origin.y - GuideImagePosYGap,  opLabel.frame.size.width + GuideImageWidthGap, opLabel.frame.size.height + GuideImageHeightGap);
        } completion:^(BOOL finish){
            opLabel.textColor = selectOptTextColor;
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            btnGuideImageView.frame = CGRectMake(opLabel.frame.origin.x - GuideImagePosXGap, opLabel.frame.origin.y - GuideImagePosYGap,  opLabel.frame.size.width + GuideImageWidthGap, opLabel.frame.size.height + GuideImageHeightGap);
        } completion:^(BOOL finish){
            opLabel.textColor = selectOptTextColor;
        }];
    }
    previousLabel = opLabel;
    
    
}

@end

