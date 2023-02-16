//
//  UIView+Effect.m
//  Redz
//
//  Created by Taojin on 2018/5/15.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import "UIView+Effect.h"

@implementation UIView (Effect)

// 毛玻璃效果
- (void)addLightEffect {
    
    if (CURRENT_DEVICE_VERSION >= 8.0) {
        // iOS8.0后的毛玻璃效果
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[[UIVisualEffectView alloc] initWithEffect:effect] autorelease];
        effectView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:effectView];
    } else {
        UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:self.bounds] autorelease];
        toolbar.barStyle = UIBarStyleDefault;
        [self addSubview:toolbar];
    }
}


@end
