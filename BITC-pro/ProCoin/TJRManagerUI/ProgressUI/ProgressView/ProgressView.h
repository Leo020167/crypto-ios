//
//  ProgressView.h
//  taojinroad
//
//  Created by Jeans Huang on 12-8-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView

@property (assign, nonatomic)       CGFloat             leftNum;                    //左边所占数量
@property (assign, nonatomic)       CGFloat             rightNum;                   //右边所占数量
@property (retain, nonatomic)       UIImageView         *leftImageView;             //左边进度条
@property (retain, nonatomic)       UIImageView         *rightImageView;            //右边进度条
@property (retain, nonatomic)       UILabel             *leftLabel;                 //左边比例文本
@property (retain, nonatomic)       UILabel             *rightLabel;                //右边比例文本

//设置左右两边所占数量
- (void)setLeftNum:(CGFloat)_leftNum  andRightNum:(CGFloat)_rightNum andIsAnimated:(BOOL)animated;
//设置左右两边比例图片
- (void)setLeftImage:(UIImage *)leftImage  andRightImage:(UIImage*)rightImage;

@end
