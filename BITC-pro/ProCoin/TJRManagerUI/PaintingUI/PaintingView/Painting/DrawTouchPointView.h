//
//  DrawTouchPointView.h
//  DrawTouchPointTest
//
//  Created by ethan on 11-10-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DrawTouchPointView : UIView {
	NSMutableArray *stroks;
	//weak
	CGMutablePathRef currentPath;
    UIColor *brushColor;

}
@property (retain , nonatomic) UIColor *brushColor;
@end
