//
//  UIPlaceHolderTextView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 15/11/16.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

- (void)textChanged:(NSNotification *)notification;
- (void)addObserver;
- (void)removeObserver;
@end
