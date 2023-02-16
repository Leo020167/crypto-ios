//
//  CircleChatExpandView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 11/13/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum CircleExpandType {
    CETpicture = 1,             // 图片
    CETcamera,                  // 拍照
    CETpaper                    // 文章
} CircleExpandType;

@class CircleChatExpandView;

@protocol CircleExpandDelegate <NSObject>

- (void)expandView:(CircleChatExpandView *)expandView image:(UIImage*)image;
- (void)expandViewOnPaper:(CircleChatExpandView *)expandView;
@end

@interface CircleChatExpandView : UIView{

}

@property (assign, nonatomic) id <CircleExpandDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIView *allView;
@property (assign, nonatomic) BOOL bAdmin;
@property (assign, nonatomic) BOOL bPrivate;
@end
