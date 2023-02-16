//
//  TJRCheckBox.h
//  taojinroad
//
//  Created by mac on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TJRCheckBoxDelegate <NSObject>
@optional
- (void)checkBoxControlClicked:(id)sender;
@end

@interface TJRCheckBox : UIView
{
    BOOL bChecked;
    id<TJRCheckBoxDelegate> delegate;
    UIImageView *checkboxIcon;
    UILabel *textLabel;
    UIImage *checkedImg;
    UIImage *uncheckedImg;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) BOOL bChecked;
@property (nonatomic, retain) UIImageView *checkboxIcon;
@property (nonatomic, retain) UILabel *textLabel;

@end
