//
//  ChatPopView.h
//  taojinroad
//
//  Created by road taojin on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol ChatEditPopViewDelegate <NSObject>
@optional
- (void)backgroundDoubleClick:(NSInteger)tag;
@end

@interface ChatEditPopView : UIView<UITextViewDelegate> {
    UIImageView *popBackground;
    UILabel     *contentLabel;
    CGSize bgImageSize;
    id <ChatEditPopViewDelegate>delegate;
}

@property (nonatomic,retain) UIImageView *popBackground;
@property (nonatomic,retain) UILabel  *contentLabel;
@property (nonatomic,assign) id delegate;
-(id)initWithBgImageName:(NSString*) bgImageName;

-(void)setText:(NSString *)str;
@end
