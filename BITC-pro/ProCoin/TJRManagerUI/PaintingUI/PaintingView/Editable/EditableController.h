//
//  EditableController.h
//  TJRtaojinroad
//
//  Created by road taojin on 12-9-24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@protocol EditableDelegate <NSObject>
@optional
- (void)editableControllerSetText:(NSString*)text;
@end

@interface EditableController : UIViewController
{
    id<EditableDelegate>delegate;
}
@property (assign, nonatomic) id delegate;
@property (retain, nonatomic) IBOutlet UILabel *countHintLbl;
@property (retain, nonatomic) IBOutlet HPGrowingTextView *growingTextView;
@end
