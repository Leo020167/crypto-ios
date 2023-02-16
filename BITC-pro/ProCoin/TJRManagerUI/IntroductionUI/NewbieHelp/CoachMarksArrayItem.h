//
//  CoachMarksArrayItem.h
//  TJRtaojinroad
//
//  Created by Hay on 14-10-24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum NHType
{
    NH_HomeViewController = 0,          //首页
    NH_IndexViewController_HotPage,     //热点
    NH_IndexViewController_TimePage,    //分时
    NH_StockKeyboard,                   //股票键盘
    NH_MyHomeViewController,            //个人资料页
    NH_SetUpViewController,             //我的自选股
    NH_StockViewController_KLinePage,   //K线
    NH_StockViewController_ShareTime,   //分时
    NH_KLineLandScape,                  //横屏K线
    NH_CircleMainViewController         //我的圈子
    
}NHType;//按顺序添加，不能中间插入,就算没了某新手指南也不能删除


typedef enum NHCutoutShape
{
    NHCutoutShape_RoundedRect = 0,     //圆角矩形
    NHCutoutShape_OvalInRect            //内切圆
}NHCutoutShape;



@interface CoachMarksArrayItem : NSObject

+ (instancetype)coachMarksArrayItem;

@property (retain, nonatomic) UIImage *guideImage;      //指导图片
@property (assign, nonatomic) CGPoint guideImagePos;    //指导图片坐标

@property (assign, nonatomic) NHCutoutShape cutoutShape;    //高亮框形状
@property (assign, nonatomic) CGRect cutoutFrame;           //高亮坐标与大小

@property (retain, nonatomic) NSString *captionText;    //指导文字
@property (assign, nonatomic) CGRect captionTextFrame;  //指导文字坐标与大小


@end
