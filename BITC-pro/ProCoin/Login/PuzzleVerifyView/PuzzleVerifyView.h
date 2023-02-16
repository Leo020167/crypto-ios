//
//  PuzzleVerifyView.h
//  Redz
//
//  Created by taojinroad on 2018/10/9.
//  Copyright © 2018 淘金路. All rights reserved.
//

#import "TJRBaseView.h"

NS_ASSUME_NONNULL_BEGIN
@class PuzzleVerifyView;

@protocol PuzzleVerifyViewDelegate <NSObject>

@optional
- (void)puzzleVerifyView:(PuzzleVerifyView*)puzzleVerifyView dragImgKey:(NSString*)dragImgKey puzzleOriginX:(CGFloat)puzzleOriginX;
@end

@interface PuzzleVerifyView : TJRBaseView{
    
}
@property (assign, nonatomic) id <PuzzleVerifyViewDelegate>delegate;

- (void)show:(UIView*)superView;
- (void)hide;
- (void)setTips:(NSString*)tips;

@end

NS_ASSUME_NONNULL_END
