//
//  MLEmojiLabelClickView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14/10/29.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "MLEmojiLabelClickView.h"

@implementation MLEmojiLabelClickView
- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		/* UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
		[self addGestureRecognizer:longPress];
		RELEASE(longPress); */
	}
	return self;
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)press {
	if (press.state == UIGestureRecognizerStateEnded) {
		if (_delegate && [_delegate respondsToSelector:@selector(MLEmojiLabelClickViewOnClick:)]) {
			[_delegate MLEmojiLabelClickViewOnClick:self];
		}
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	self.backgroundColor = [UIColor grayColor];
    if (!_delegate || ![_delegate respondsToSelector:@selector(MLEmojiLabelClickViewOnClick:)]) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self performSelector:@selector(setBackgroundColor:) withObject:[UIColor clearColor] afterDelay:0.25];

    if (_delegate && [_delegate respondsToSelector:@selector(MLEmojiLabelClickViewOnClick:)]) {
		[_delegate MLEmojiLabelClickViewOnClick:self];
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self performSelector:@selector(setBackgroundColor:) withObject:[UIColor clearColor] afterDelay:0.25];
	[super touchesCancelled:touches withEvent:event];
}

- (void)setSaveDataWithObject:(id)object forKey:(id)key {
	if (!labelSaveData) {
		labelSaveData = [[NSMutableDictionary alloc] init];
	}

	if (object) {
		[labelSaveData setObject:object forKey:key];
	}
}

- (id)getSaveDataWithKey:(id)key {
	if (TTIsStringWithAnyText(key) && labelSaveData) {
		return [labelSaveData objectForKey:key];
	}
    return nil;
}

- (void)removeSaveDataObjectForKey:(id)key {
	if (!labelSaveData) return;

	[labelSaveData removeObjectForKey:key];
}

- (void)removeAllSaveData {
	if (!labelSaveData) return;

	[labelSaveData removeAllObjects];
}

- (void)dealloc {
	[labelSaveData removeAllObjects];
	RELEASE(labelSaveData);
	[super dealloc];
}

@end

