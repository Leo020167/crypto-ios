//
//  TJROptionsBar.h
//  TJRtaojinroad
//
//  Created by Hay on 13-3-20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

/*
 组件选项按钮功能类
 */
#import <UIKit/UIKit.h>

@protocol TJROptionsBarDelegate <NSObject>

@required
//------------------功能文字的索引从0开始类推
- (void)optionButtonClickEvent:(NSInteger) index;
@end




@interface TJROptionsBar : UIView
{
    BOOL bIsOptsBarHorizontal;                        //选项栏是否水平排列，yes为是，no为竖直排列
    BOOL bRefreshScrollView;                          //是否需要刷新scrollView
    
    CGFloat nextOptionX;                              //下一个选项的X坐标
    CGFloat nextOptionY;                              //下一个选项的Y坐标
    UIImageView *backgroundView;                      //背景图片
    UIScrollView *backgroundScrollView;               //背景scrollView
    UIImageView *btnGuideImageView;                   //点击按钮提示图片视图
    UILabel *previousLabel;                           //记录之前label文本
    UIImage *buttonImage;                             //按钮背景图片
    
    CGFloat GuideImagePosXGap;                        //指示图片的X坐标偏差
    CGFloat GuideImagePosYGap;                        //指示图片的Y坐标偏差
    CGFloat GuideImageWidthGap;                       //指示图片的宽度偏差
    CGFloat GuideImageHeightGap;                      //指示图片的高度偏差
}       


@property (readonly, nonatomic) CGFloat OriginOptsPosYCenter;            //在选项水平排序情况下，选项居中的Y坐标，竖直排序此参数为0

@property (readonly, nonatomic) CGFloat OriginOptsPosXCenter;            //在选项竖直排序情况下，选项居中的X坐标，水平排序此参数为0
@property (assign, nonatomic) BOOL bIsClick;            //是否能被点击

@property (assign, nonatomic) CGPoint originOptsPos;                              //选项项目的初始位置

@property (assign, nonatomic) NSInteger nextBtnDistance;        //按钮之间的距离差

@property (assign, nonatomic) id<TJROptionsBarDelegate> optionsBarDelegate;          //按钮点击事件委托
@property (retain, nonatomic) NSArray *optionsData;                                  //选项卡列表

@property (nonatomic,readonly) UIImageView *btnGuideImageView;                        //点击按钮提示图片视图（只读）

@property (assign, nonatomic) CGFloat fontSize;                     //label文本字体的大小
@property (retain, nonatomic) UIColor *unSelectOptTextColor;    //未选中选项的字体颜色

@property (retain, nonatomic) UIColor *selectOptTextColor;      //设置选中选项的字体颜色

#pragma mark - 设置选项栏的文字数据,有字体大小设置，有起始位置设置
- (void)setOptionsData:(NSArray *)_optionsData;          //选项设置
- (void)setOriginOptsPos:(CGPoint)_originOptsPos;        //选项初始位置设置

#pragma mark - 重置选项烂文字颜色和光标位置回到初始位置
- (void)resetOptionsBar;
#pragma mark - 设置背景颜色
- (void)setOptionsBarBackgroundColor:(UIColor *)rgb;
#pragma mark - 通过设置索引使选项栏选指定某个选项
- (void)optionFromIndexInOptionsBar:(NSInteger)optionIndex;
#pragma mark - 设置背景图片
- (void)setOptionsBarBackgroundImage:(UIImage *)image;
#pragma mark - 设置指示图片
- (void)setOptionsBarGuideImage:(UIImage *)image;
#pragma mark - 设置指示图片的整体便宜差
- (void)setOptionBarGuideFrameGap:(CGFloat)posXGap posYGap:(CGFloat)posYGap widthGap:(CGFloat)widthGap heightGap:(CGFloat)heightGap;
#pragma mark - 设置文字按钮背景图片
- (void)setOptionsBarButtonImage:(UIImage *)image;

@end

