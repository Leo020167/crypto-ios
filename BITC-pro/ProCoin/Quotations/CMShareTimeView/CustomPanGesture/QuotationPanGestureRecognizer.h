//
//  QuotationPanGestureRecognizer.h
//  Cropyme
//
//  Created by Hay on 2019/7/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>


typedef enum {
    QuotationPanGestureRecognizerVertical,
    QuotationPanGestureRecognizerHorizontal
} QuotationPanGestureRecognizerDirection;

@interface QuotationPanGestureRecognizer : UIPanGestureRecognizer
{
    BOOL _drag;
    int _moveX;
    int _moveY;
    QuotationPanGestureRecognizerDirection _direction;
}

@property (nonatomic, assign) QuotationPanGestureRecognizerDirection direction;



@end


