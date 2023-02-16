//
//  ChatPictureController.h
//  TJRtaojinroad
//
//  Created by road taojin on 12-10-12.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseView.h"

@class TJRBaseViewController;

@interface CircleChatPictureView : NSObject
{
    NSMutableArray *photos;
    NSMutableDictionary* dic;
    TJRBaseViewController* fatherCtr;
}

- (void)showPicView:(NSMutableArray *)arrUrl pageIndex:(NSUInteger)pageIndex touchViews:(NSMutableDictionary*)touchViews;
@end
