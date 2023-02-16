//
//  CircleChatBubbleView.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-19.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum Orientation{
    leftOrientation = 0,
    rightOrientation
}Orientation;

typedef enum BubbleType {
    bubbleText = 1,            // 文本
    bubbleImage,               // 图片
    bubbleContent              // 股票，新闻等等
} BubbleType;

@interface CircleChatBubbleView : UIView{

}

@property (nonatomic, retain) UIButton *bubbleContentView;            //用于显示内容的view
@property (nonatomic, assign) Orientation orientation;                //方向
@property (nonatomic, assign) BubbleType bubbleType;                  //背景图片类型

/**
	设置回调委托和气泡方向
	@param bubbleDelegate 委托
	@param side 方向
 */
- (void)setBubbleDelegate:(id)bubbleDelegate Side:(Orientation)side;

- (void)unCheckBubbleView;
- (void)checkBubbleView;
@end
