//
//  TJRFaceView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 14-4-3.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TJRFaceViewDefaultFrame    CGRectMake(0, 0, 320, 216)
@protocol TJRFaceClickDelegate <NSObject>
- (void)faceOnClickWithName:(NSString *)name;
- (void)faceOnClickBackspace;
@end
@interface TJRFaceView : UIView<UIScrollViewDelegate> {
    float VerticalSpacing;
	float HorizontalSpacing;
	int MaxRank;/* 最大列数 */
	int MaxRow;	/* 最大行数 */
	float phoneHeight;
	float phoneWidth;
	BOOL isLandscape;
	BOOL isFirst;
	UIInterfaceOrientation statusBarOrientation;
}

@property (retain, nonatomic) NSDictionary *faceDictionary;
@property (retain, nonatomic) IBOutlet UIScrollView *svFace;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIImageView *allFaceBackgroundImageView;
@property (retain, nonatomic) IBOutlet UIView *allView;
@property (assign, nonatomic) id<TJRFaceClickDelegate> delegate;


- (void)interfaceChange;
@end
