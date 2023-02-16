//
//  CircleChatFaceView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 11/13/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRFaceView.h"

@protocol CircleFaceDelegate <NSObject>

- (void)faceOnClickWithName:(NSString *)name;
- (void)faceOnClickBackspace;
- (void)faceOnClickSend;

@optional
- (void)faceOnClickFace1;
- (void)faceOnClickFace2;

@end

@interface CircleChatFaceView : UIView<UIScrollViewDelegate> {
    float VerticalSpacing;
    float HorizontalSpacing;
    int MaxRank;/* 最大列数 */
    int MaxRow;	/* 最大行数 */
    float phoneHeight;
    float phoneWidth;
}

@property (retain, nonatomic) NSDictionary *faceDictionary;
@property (retain, nonatomic) IBOutlet UIScrollView *svFace;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIImageView *allFaceBackgroundImageView;
@property (retain, nonatomic) IBOutlet UIView *allView;
@property (assign, nonatomic) id<CircleFaceDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *btnFace1;
@property (retain, nonatomic) IBOutlet UIButton *btnFace2;
@property (retain, nonatomic) IBOutlet UIButton *btnSend;

- (void)setfaceSendBtnEnable:(BOOL)enable;
@end
