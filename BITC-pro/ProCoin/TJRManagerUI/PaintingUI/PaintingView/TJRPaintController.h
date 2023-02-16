//
//  TJRPaintController.h
//  TJRtaojinroad
//
//  Created by road taojin on 12-9-20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRPaintView.h"
#import "TJRBaseViewController.h"


typedef enum PaintType {
    PaintFriend,				    //选中了分享给好友
    PaintCircle,				    //选中了分享到圈子
} PaintType;

@protocol TJRPaintDelegate <NSObject>
@optional
//返回是否发送数据
- (BOOL)TJRPaintNeedSend:(NSData*)dataObj;
@end

@interface TJRPaintController : TJRBaseViewController
{
    NSInteger dragSubTag;

    float bottomY;
    
    BOOL bReqFinished;
    
    id<TJRPaintDelegate>delegate;
}
@property (retain, nonatomic) IBOutlet TJRPaintView *paintView;
@property (retain, nonatomic) IBOutlet UIButton *leftBtn;
@property (retain, nonatomic) IBOutlet UIButton *rightBtn;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) id delegate;

@property (assign, nonatomic) PaintType type;

- (void)setFinalImage:(UIImage *)finalImage;
- (void)setPaintSuperView;
- (void)setImageContentMode:(UIViewContentMode)mode;
- (void)finish;
@end
