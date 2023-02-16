//
//  RCLabel.m
//  RCLabelProject
//

/**
 * Copyright (c) 2012 Hang Chen
 * Created by hangchen on 21/7/12.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject
 * to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 * IN CONNECTION WITH THE SOFTWARE OR
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * @author      Hang Chen <cyndibaby905@yahoo.com.cn>
 * @copyright	2012	Hang Chen
 * @version
 *
 */

#import "RCLabel.h"
#define LINK_PADDING				2
#define IMAGE_PADDING				2
#define IMAGE_USER_WIDTH			180.0	// 180.0 (改完后的表情大小为36*34)
#define IMAGE_MAX_WIDTH				((IMAGE_USER_WIDTH)-4 * (IMAGE_PADDING))
#define IMAGE_USER_HEIGHT			80.0	// 80.0
#define IMAGE_LINK_BOUND_MIN_HEIGHT 30
#define IMAGE_USER_DESCENT			((IMAGE_USER_HEIGHT) / 20.0)
#define IMAGE_MAX_HEIGHT			((IMAGE_USER_HEIGHT + IMAGE_USER_DESCENT) - 2 * (IMAGE_PADDING))

#define BG_COLOR					0xDDDDDD
#define IMAGE_MIN_WIDTH				5
#define IMAGE_MIN_HEIGHT			5

#define TYPE_WIDTH					@"width"
#define TYPE_HEIGHT					@"height"
#define TYPE_XPADDING				@"xPadding"
#define TYPE_YPADDING				@"yPadding"
#define TYPE_SELF_NAMEANDADDRESS	@"self_name_and_Address"

#define TYPE_TJRFACE_DELIMITER		@","
#define HeaderForTJRFace(url) [url hasPrefix : @"TJRFace_"]

static NSMutableDictionary *imgSizeDict = NULL;

@implementation RTLabelComponent

@synthesize text = _text;
@synthesize tagLabel = _tagLabel;
@synthesize attributes = _attributes;
@synthesize position = _position;
@synthesize componentIndex = _componentIndex;
@synthesize isClosure = _isClosure;
// @synthesize img = img_;

- (id)initWithString:(NSString *)aText tag:(NSString *)aTagLabel attributes:(NSMutableDictionary *)theAttributes; {
	self = [super init];

	if (self) {
		self.text = aText;
		self.tagLabel = aTagLabel;
		self.attributes = theAttributes;
		self.isClosure = NO;
	}

	return self;
}

+ (id)componentWithString:(NSString *)aText tag:(NSString *)aTagLabel attributes:(NSMutableDictionary *)theAttributes {
	return [[[self alloc] initWithString:aText tag:aTagLabel attributes:theAttributes] autorelease];
}

- (id)initWithTag:(NSString *)aTagLabel position:(int)aPosition attributes:(NSMutableDictionary *)theAttributes {
	self = [super init];

	if (self) {
		self.tagLabel = aTagLabel;
		self.position = aPosition;
		self.attributes = theAttributes;
		self.isClosure = NO;
	}

	return self;
}

+ (id)componentWithTag:(NSString *)aTagLabel position:(int)aPosition attributes:(NSMutableDictionary *)theAttributes {
	return [[[self alloc] initWithTag:aTagLabel position:aPosition attributes:theAttributes] autorelease];
}

- (NSString *)description {
	NSMutableString *desc = [NSMutableString string];

	[desc appendFormat:@"text: %@", self.text];
	[desc appendFormat:@", position: %i", self.position];

	if (self.tagLabel) {
		[desc appendFormat:@", tag: %@", self.tagLabel];
	}

	if (self.attributes) {
		[desc appendFormat:@", attributes: %@", self.attributes];
	}

	return desc;
}

- (void)dealloc {
	self.text = nil;
	self.tagLabel = nil;
	self.attributes = nil;
	//	self.img = nil;
	[super dealloc];
}

@end

@implementation RTLabelComponentsStructure
@synthesize components = components_;
@synthesize plainTextData = plainTextData_;
@synthesize linkComponents = linkComponents_;
@synthesize imgComponents = imgComponents_;

- (void)dealloc {
	self.plainTextData = nil;
	self.components = nil;
	self.linkComponents = nil;
	self.imgComponents = nil;
	[super dealloc];
}

@end

static NSInteger totalCount = 0;

@interface RCLabel ()
@property (nonatomic, assign) CGSize optimumSize;

// - (NSArray *)components;
// - (void)parse:(NSString *)data valid_tags:(NSArray *)valid_tags;
- (NSArray *)colorForHex:(NSString *)hexColor;
- (void)render;
- (CGRect)BoundingRectForLink:(RTLabelComponent *)linkComponent withRun:(CTRunRef)run;
- (CGRect)BoundingRectFroImage:(RTLabelComponent *)imgComponent withRun:(CTRunRef)run;

- (void)genAttributedString;

- (CGPathRef)newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius;

- (void)dismissBoundRectForTouch;
#pragma mark -
#pragma mark styling

- (void)applyItalicStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length;
- (void)applyBoldStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length;
- (void)applyColor:(NSString *)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length;
- (void)applySingleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length;
- (void)applyDoubleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length;
- (void)applyUnderlineColor:(NSString *)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length;
- (void)applyFontAttributes:(NSDictionary *)attributes toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length;
- (void)applyParagraphStyleToText:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary *)attributes atPosition:(int)position withLength:(NSInteger)length;
- (void)applyImageAttributes:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary *)attributes atPosition:(int)position withLength:(NSUInteger)length;
- (void)applyLinkAttributes:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary *)attributes atPosition:(int)position withLength:(NSUInteger)length;
@end
NSString *const RCLabelLinkForUrl      = @"href";
NSString *const RCLabelLinkForFullcode = @"fullcode";
NSString *const RCLabelLinkForUser     = @"tjrUserId";
NSString *const RCLabelLinkForTopic    = @"tjrTopic";
NSString *const RCLabelLinkForImage    = @"src";
@implementation RCLabel

@synthesize optimumSize = _optimumSize;
@synthesize sizeDelegate = _sizeDelegate;
@synthesize delegate = _delegate;
@synthesize paragraphReplacement = _paragraphReplacement;
@synthesize currentImgComponent = _currentImgComponent;
@synthesize currentLinkComponent = _currentLinkComponent;

- (id)initWithCoder:(NSCoder *)aDecoder {
	totalCount++;
	self = [super initWithCoder:aDecoder];

	if (self) {
		[self initRCLabel];
	}

	return self;
}

- (id)initWithFrame:(CGRect)_frame {
	totalCount++;
	self = [super initWithFrame:_frame];

	if (self) {
		[self initRCLabel];
	}

	return self;
}

- (void)initRCLabel {
	[self setBackgroundColor:[UIColor clearColor]];
	self.font = [UIFont systemFontOfSize:14];
	RELEASE(_originalColor);
	_originalColor = [[UIColor colorWithRed:0x2e / 255.0 green:0x2e / 255.0 blue:0x2e / 255.0 alpha:1.0] retain];
	self.textColor = _originalColor;
	self.currentLinkComponent = nil;
	self.currentImgComponent = nil;
    _textAlignment = CURRENT_DEVICE_VERSION>=7.0?RTTextAlignmentJustify:RTTextAlignmentLeft;
	_lineBreakMode = RTTextLineBreakModeCharWrapping;
	_attrString = NULL;
	_ctFrame = NULL;
	_framesetter = NULL;
	_optimumSize = self.frame.size;
	_paragraphReplacement = @"\n";
	_thisFont = CTFontCreateWithName((CFStringRef)[self.font fontName], [self.font pointSize], NULL);
}

- (void)setSaveDataWithObject:(id)object forKey:(id)key {
	if (!self.labelSaveData) {
		NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
		self.labelSaveData = dic;
		RELEASE(dic);
	}
    if (object) {
        [self.labelSaveData setObject:object forKey:key];
    }
}

- (void)removeSaveDataObjectForKey:(id)key {
	[self.labelSaveData removeObjectForKey:key];
}

- (void)removeAllSaveData {
	[self.labelSaveData removeAllObjects];
}

- (void)setFrame:(CGRect)frame {
	if (CGRectEqualToRect(frame, self.frame)) {
		return;
	}
	[super setFrame:frame];
	[self setNeedsDisplay];
}

- (void)setTextAlignment:(RTTextAlignment)textAlignment {
	_textAlignment = textAlignment;
	[self genAttributedString];
	[self setNeedsDisplay];
}

- (RTTextAlignment)textAlignment {
	return _textAlignment;
}

- (void)setLineBreakMode:(RTTextLineBreakMode)lineBreakMode {
	_lineBreakMode = lineBreakMode;
	[self genAttributedString];
	[self setNeedsDisplay];
}

- (RTTextLineBreakMode)lineBreakMode {
	return _lineBreakMode;
}

- (void)setTextColor:(UIColor *)textColor {
	if (!textColor) return;

	if (_textColor) {
		if (_textColor != textColor) {
			[_textColor release];
			_textColor = nil;
		} else {
			return;
		}
	}

	_textColor = [textColor retain];
	[self genAttributedString];
	[self setNeedsDisplay];
}

- (UIColor *)textColor {
	return _textColor;
}

- (void)setFont:(UIFont *)font {
	if (!font) return;

	if (_font) {
		if (_font != font) {
			[_font release];
			_font = nil;
		} else {
			return;
		}
	}

	_font = [font retain];

	if (_font) {
		if (_thisFont) {
			CFRelease(_thisFont);
		}

		_thisFont = CTFontCreateWithName((CFStringRef)[self.font fontName], [self.font pointSize], NULL);
	}
}

- (UIFont *)font {
	return _font;
}

- (void)setComponentsAndPlainText:(RTLabelComponentsStructure *)componnetsDS {
	if (!componnetsDS) return;

	if (componentsAndPlainText_) {
		if (componentsAndPlainText_ != componnetsDS) {
			[componentsAndPlainText_ release];
			componentsAndPlainText_ = nil;
		} else {
			return;
		}
	}

	componentsAndPlainText_ = [componnetsDS retain];
	[self genAttributedString];
	[self setNeedsDisplay];
}

- (RTLabelComponentsStructure *)componentsAndPlainText {
	return componentsAndPlainText_;
}

CGSize MyGetSize(void *refCon) {
	NSString *src = (NSString *)refCon;
	CGSize size = CGSizeMake(100.0, IMAGE_MAX_HEIGHT);

	if (src) {
		if (!imgSizeDict) {
			imgSizeDict = [[NSMutableDictionary dictionary] retain];
		}

		NSValue *nsv = [imgSizeDict objectForKey:src];

		if (nsv) {
			[nsv getValue:&size];
			return size;
		}
		NSString *imageName = src;
		NSArray *array = [src componentsSeparatedByString:TYPE_TJRFACE_DELIMITER];

		if (array && (array.count == 2)) imageName = [array objectAtIndex:0];
		UIImage *image = [UIImage imageNamed:imageName];

		if (image) {
			CGSize imageSize = image.size;
			CGFloat ratio = imageSize.width / imageSize.height;

			if (imageSize.width > IMAGE_MAX_WIDTH) {
				size.width = IMAGE_MAX_WIDTH;
				size.height = IMAGE_MAX_WIDTH / ratio;
			} else {
				size.width = imageSize.width;
				size.height = imageSize.height;
			}

			if (size.height > IMAGE_MAX_HEIGHT) {
				size.height = IMAGE_MAX_HEIGHT;
				size.width = size.height * ratio;
			}

			if (size.height < 1.0) {
				size.height = 1.0;
			}

			if (size.width < 1.0) {
				size.width = 1.0;
			}

			nsv = [NSValue valueWithBytes:&size objCType:@encode(CGSize)];
			[imgSizeDict setObject:nsv forKey:src];
			return size;
		}
	}

	return size;
}

void MyDeallocationCallback(void *refCon) {}

#pragma mark - 图片上调高度
CGFloat MyGetAscentCallback(void *refCon) {
	NSString *imgParameter = (NSString *)refCon;

	if (imgParameter) {
		return 0;
	}

	return IMAGE_USER_HEIGHT;
}

#pragma mark - 图片下调高度
CGFloat MyGetDescentCallback(void *refCon) {
	NSString *imgParameter = (NSString *)refCon;

	if (imgParameter) {
		return 0;
	}

	return IMAGE_USER_DESCENT;
}

CGFloat MyGetWidthCallback(void *refCon) {
	CGSize size = MyGetSize(refCon);

	return size.width;
}

- (void)drawRect:(CGRect)rect {
	[self render];
}

- (CGPathRef)newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius {
	CGMutablePathRef retPath = CGPathCreateMutable();

	CGRect innerRect = CGRectInset(rect, radius, radius);

	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;

	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;

	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);

	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_bottom, inside_right, outside_bottom, radius);

	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL, outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_left, outside_top, innerRect.origin.x, outside_top, radius);

	CGPathCloseSubpath(retPath);
	return retPath;
}

- (CGRect)BoundingRectForLink:(RTLabelComponent *)linkComponent withRun:(CTRunRef)run {
	CGRect runBounds = CGRectZero;
	CFRange runRange = CTRunGetStringRange(run);
	BOOL runStartAfterLink = ((runRange.location >= linkComponent.position) && (runRange.location < linkComponent.position + [linkComponent.text length]));
	BOOL runStartBeforeLink = ((runRange.location < linkComponent.position) && (runRange.location + runRange.length) > linkComponent.position);

	// if the range of the glyph run falls within the range of the link to be highlighted
	if (runStartAfterLink || runStartBeforeLink) {
		// runRange is within the link range
		CFIndex rangePosition;
		CFIndex rangeLength;
		NSString *linkComponentString;

		if (runStartAfterLink) {
			rangePosition = 0;

			if (linkComponent.position + [linkComponent.text length] > runRange.location + runRange.length) {
				rangeLength = runRange.length;
			} else {
				rangeLength = linkComponent.position + [linkComponent.text length] - runRange.location;
			}

			linkComponentString = [self.componentsAndPlainText.plainTextData substringWithRange:NSMakeRange(runRange.location, rangeLength)];
		} else {
			rangePosition = linkComponent.position - runRange.location;

			if (linkComponent.position + [linkComponent.text length] > runRange.location + runRange.length) {
				rangeLength = runRange.location + runRange.length - linkComponent.position;
			} else {
				rangeLength = [linkComponent.text length];
			}

			linkComponentString = [self.componentsAndPlainText.plainTextData substringWithRange:NSMakeRange(linkComponent.position, rangeLength)];
		}

		if ([[linkComponentString substringToIndex:1] isEqualToString:@"\n"]) {
			rangePosition += 1;
		}

		if ([[linkComponentString substringFromIndex:[linkComponentString length] - 1] isEqualToString:@"\n"]) {
			rangeLength -= 1;
		}

		if (rangeLength <= 0) {
			return runBounds;
		}

		CFIndex glyphCount = CTRunGetGlyphCount(run);

		if (rangePosition >= glyphCount) {
			rangePosition = 0;
		}

		if (rangeLength == runRange.length) {
			rangeLength = 0;
		}

		// work out the bounding rect for the glyph run (this doesn't include the origin)
		CGFloat ascent, descent, leading;
		CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(rangePosition, rangeLength), &ascent, &descent, &leading);

		/*if (![[linkComponentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] && ascent != MyGetAscentCallback(NULL)) {
		 *    return runBounds;
		 *   }*/

		runBounds.size.width = width;
		runBounds.size.height = ascent + fabs(descent) + leading;

		// get the origin of the glyph run (this is relative to the origin of the line)
		const CGPoint *positions = CTRunGetPositionsPtr(run);
		runBounds.origin.x = positions[rangePosition].x;
		runBounds.origin.y -= ascent;
	}

	return runBounds;
}

- (CGRect)BoundingRectFroImage:(RTLabelComponent *)imgComponent withRun:(CTRunRef)run {
	CGRect runBounds = CGRectZero;
	CFRange runRange = CTRunGetStringRange(run);

	if ((runRange.location <= imgComponent.position) && (runRange.location + runRange.length >= imgComponent.position + [imgComponent.text length])) {
		// work out the bounding rect for the glyph run (this doesn't include the origin)
		NSInteger index = imgComponent.position - runRange.location;

		CGSize imageSize = MyGetSize([imgComponent.attributes objectForKey:RCLabelLinkForImage]);
		runBounds.size.width = imageSize.width;
		runBounds.size.height = imageSize.height;

		// get the origin of the glyph run (this is relative to the origin of the line)

		const CGPoint *positions = CTRunGetPositionsPtr(run);
		runBounds.origin.x = positions[index].x;
	}

	return runBounds;
}

- (CGFloat)heightForAttributedString:(NSAttributedString *)attrString forWidth:(CGFloat)inWidth {
	CGFloat H = 0;

	// Create the framesetter with the attributed string.
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)attrString);

	CGRect box = CGRectMake(0, 0, inWidth, CGFLOAT_MAX);

	CFIndex startIndex = 0;

	CGMutablePathRef path = CGPathCreateMutable();

	CGPathAddRect(path, NULL, box);

	// Create a frame for this column and draw it.
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), path, NULL);

	// Start the next frame at the first character not visible in this frame.
	// CFRange frameRange = CTFrameGetVisibleStringRange(frame);
	// startIndex += frameRange.length;

	CFArrayRef lineArray = CTFrameGetLines(frame);
	CFIndex j = 0, lineCount = CFArrayGetCount(lineArray);
	CGFloat h, ascent, descent, leading;

	for (j = 0; j < lineCount; j++) {
		CTLineRef currentLine = (CTLineRef)CFArrayGetValueAtIndex(lineArray, j);
		CTLineGetTypographicBounds(currentLine, &ascent, &descent, &leading);
		h = ascent + descent + leading;
		//NSLog(@"%f", h);
		H += h;
	}

	CFRelease(frame);
	CFRelease(path);
	CFRelease(framesetter);

	return H;
}

- (void)render {
	if (!self.componentsAndPlainText || !self.componentsAndPlainText.plainTextData) {
		return;
	}

	// context will be nil if we are not in the call stack of drawRect, however we can calculate the height without the context
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Create the framesetter with the attributed string.
	if (_framesetter) {
		CFRelease(_framesetter);
		_framesetter = NULL;
	}

	_framesetter = CTFramesetterCreateWithAttributedString(_attrString);
	// Initialize a rectangular path.
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect bounds = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	CGPathAddRect(path, NULL, bounds);

	// Create the frame and draw it into the graphics context
	if (_ctFrame) {
		CFRelease(_ctFrame);
		_ctFrame = NULL;
	}

	_ctFrame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), path, NULL);
	CFRange range;
	CGSize constraint = CGSizeMake(self.frame.size.width, 1000000);
    //NSLog(@"%@",self.componentsAndPlainText.plainTextData);
	CGSize sizeAfterRender = CTFramesetterSuggestFrameSizeWithConstraints(_framesetter, CFRangeMake(0, [self.componentsAndPlainText.plainTextData length]), nil, constraint, &range);
	//	self.optimumSize = CGSizeMake(self.frame.size.width, [self heightForAttributedString:(NSAttributedString *)_attrString forWidth:self.frame.size.width]);
	self.optimumSize = sizeAfterRender;

	if (context) {
		CFArrayRef lines = CTFrameGetLines(_ctFrame);
		CGPoint lineOrigins[CFArrayGetCount(lines)];
		CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), lineOrigins);

		// Calculate the bounding rect for link
		if (self.currentLinkComponent) {
			// get the lines

			CGContextSetTextMatrix(context, CGAffineTransformIdentity);

			CGRect rect = CGPathGetBoundingBox(path);

			// for each line
			for (int i = 0; i < CFArrayGetCount(lines); i++) {
				CTLineRef line = CFArrayGetValueAtIndex(lines, i);
				CFArrayRef runs = CTLineGetGlyphRuns(line);
				CGFloat lineAscent;
				CGFloat lineDescent;
				CGFloat lineLeading;
				CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
				CGPoint origin = lineOrigins[i];

				// fo each glyph run in the line
				for (int j = 0; j < CFArrayGetCount(runs); j++) {
					CTRunRef run = CFArrayGetValueAtIndex(runs, j);

					if (!self.currentLinkComponent) {
						return;
					}

					CGRect runBounds = [self BoundingRectForLink:self.currentLinkComponent withRun:run];

					if ((runBounds.size.width != 0) && (runBounds.size.height != 0)) {
						// runBounds.size.height = lineAscent + fabsf(lineDescent) + lineLeading;
						runBounds.origin.x += origin.x;
						// this is more favourable
						runBounds.origin.x -= LINK_PADDING;
						runBounds.size.width += LINK_PADDING * 2;
						runBounds.origin.y -= LINK_PADDING;
						runBounds.size.height += LINK_PADDING * 2;

						CGFloat y = rect.origin.y + rect.size.height - origin.y;
						runBounds.origin.y += y;
						// Adjust the runBounds according to the line original position

						// Finally, create a rounded rect with a nice shadow and fill.

						CGContextSetFillColorWithColor(context, [[UIColor grayColor] CGColor]);
						CGPathRef highlightPath = [self newPathForRoundedRect:runBounds radius:(runBounds.size.height / 10.0)];
						CGContextSetShadow(context, CGSizeMake(2, 2), 1.0);
						CGContextAddPath(context, highlightPath);
						CGContextFillPath(context);
						CGPathRelease(highlightPath);
						CGContextSetShadowWithColor(context, CGSizeZero, 0.0, NULL);
					}
				}
			}
		}

		CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height);
		CGContextConcatCTM(context, flipVertical);

		// Calculate the bounding for image
		for (int i = 0; i < CFArrayGetCount(lines); i++) {
			CTLineRef line = CFArrayGetValueAtIndex(lines, i);
			CGFloat lineAscent;
			CGFloat lineDescent;
			CGFloat lineLeading;
			CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
			CFArrayRef runs = CTLineGetGlyphRuns(line);

			for (int j = 0; j < CFArrayGetCount(runs); j++) {
				CGFloat ascent;
				CGFloat descent;
				CGPoint origin = lineOrigins[i];
				CTRunRef run = CFArrayGetValueAtIndex(runs, j);
				NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
				CGRect runBounds;
				runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);

				runBounds = CGRectMake(origin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), origin.y - descent, bounds.size.width, ascent + descent);

				if ([attributes objectForKey:@"imageSrc"]) {
					CGPoint origin = lineOrigins[i];
					runBounds.origin.x += origin.x;
					runBounds.origin.y = origin.y;
					// 图片设置有padding时
					CGFloat xPadding = [[attributes objectForKey:TYPE_XPADDING] floatValue];
					CGFloat yPadding = [[attributes objectForKey:TYPE_YPADDING] floatValue];

					if (fabs(xPadding) < 320) {
						runBounds.origin.x -= xPadding;
					}

					if (fabs(yPadding) < 320) {
						runBounds.origin.y -= yPadding;
					} else {
						runBounds.origin.y -= IMAGE_PADDING;
					}

					NSString *url = [attributes objectForKey:@"imageSrc"];
					UIImage *image = [UIImage imageNamed:url];

					if (image) {
						runBounds.size = MyGetSize([attributes objectForKey:TYPE_SELF_NAMEANDADDRESS]);
						CGContextDrawImage(context, runBounds, image.CGImage);
					} else {
						CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:(BG_COLOR & 0xFF0000 >> 16) / 255.f green:(BG_COLOR & 0x00FF00 >> 8) / 255.f blue:(BG_COLOR & 0x0000FF) / 255.f alpha:1.0f] CGColor]);
						CGContextFillRect(context, runBounds);
					}
				}
			}
		}

		CTFrameDraw(_ctFrame, context);
	}

	_visibleRange = CTFrameGetVisibleStringRange(_ctFrame);
	CGPathRelease(path);
}

#pragma mark -
#pragma mark styling
- (void)applyParagraphStyleToText:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary *)attributes atPosition:(int)position withLength:(NSInteger)length {
	// NSLog(@"%@", attributes);

	CFMutableDictionaryRef styleDict = (CFDictionaryCreateMutable((0), 0, (0), (0)));
	// direction
	CTWritingDirection direction = kCTWritingDirectionLeftToRight;
	// leading
	CGFloat firstLineIndent = 0.0;
	CGFloat headIndent = 0.0;
	CGFloat tailIndent = 0.0;
	CGFloat lineHeightMultiple = 1.5;
	CGFloat maxLineHeight = 0;
	CGFloat minLineHeight = 0;
	CGFloat paragraphSpacing = 0.0;
	CGFloat paragraphSpacingBefore = 0.0;
	int textAlignment = _textAlignment;
	int lineBreakMode = _lineBreakMode;
	CGFloat lineSpacing = 0.0;

	for (NSString *key in attributes) {
		id value = [attributes objectForKey:key];

		if ([key isEqualToString:@"align"]) {
			if ([value isEqualToString:@"left"]) {
				textAlignment = kCTLeftTextAlignment;
			} else if ([value isEqualToString:@"right"]) {
				textAlignment = kCTRightTextAlignment;
			} else if ([value isEqualToString:@"justify"]) {
				textAlignment = kCTJustifiedTextAlignment;
			} else if ([value isEqualToString:@"center"]) {
				textAlignment = kCTCenterTextAlignment;
			}
		} else if ([key isEqualToString:@"indent"]) {
			firstLineIndent = [value floatValue];
		} else if ([key isEqualToString:@"linebreakmode"]) {
			if ([value isEqualToString:@"wordwrap"]) {
				lineBreakMode = kCTLineBreakByWordWrapping;
			} else if ([value isEqualToString:@"charwrap"]) {
				lineBreakMode = kCTLineBreakByCharWrapping;
			} else if ([value isEqualToString:@"clipping"]) {
				lineBreakMode = kCTLineBreakByClipping;
			} else if ([value isEqualToString:@"truncatinghead"]) {
				lineBreakMode = kCTLineBreakByTruncatingHead;
			} else if ([value isEqualToString:@"truncatingtail"]) {
				lineBreakMode = kCTLineBreakByTruncatingTail;
			} else if ([value isEqualToString:@"truncatingmiddle"]) {
				lineBreakMode = kCTLineBreakByTruncatingMiddle;
			}
		}
	}

	CTParagraphStyleSetting theSettings[] = {
		{kCTParagraphStyleSpecifierAlignment,			   sizeof(CTTextAlignment),	   &textAlignment		  },
		{kCTParagraphStyleSpecifierLineBreakMode,		   sizeof(CTLineBreakMode),	   &lineBreakMode		  },
		{kCTParagraphStyleSpecifierBaseWritingDirection,   sizeof(CTWritingDirection), &direction			  },
		{kCTParagraphStyleSpecifierMaximumLineSpacing,	   sizeof(CGFloat),		       &lineSpacing			  },
        {kCTParagraphStyleSpecifierMinimumLineSpacing,     sizeof(CGFloat),            &lineSpacing           },
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,  sizeof(CGFloat),            &lineSpacing           },
		{kCTParagraphStyleSpecifierFirstLineHeadIndent,	   sizeof(CGFloat),			   &firstLineIndent		  },
		{kCTParagraphStyleSpecifierHeadIndent,			   sizeof(CGFloat),			   &headIndent			  },
		{kCTParagraphStyleSpecifierTailIndent,			   sizeof(CGFloat),			   &tailIndent			  },
		{kCTParagraphStyleSpecifierLineHeightMultiple,	   sizeof(CGFloat),			   &lineHeightMultiple	  },
		{kCTParagraphStyleSpecifierMaximumLineHeight,	   sizeof(CGFloat),			   &maxLineHeight		  },
		{kCTParagraphStyleSpecifierMinimumLineHeight,	   sizeof(CGFloat),			   &minLineHeight		  },
		{kCTParagraphStyleSpecifierParagraphSpacing,	   sizeof(CGFloat),			   &paragraphSpacing	  },
		{kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat),			   &paragraphSpacingBefore}
	};
    
	CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, sizeof(theSettings) / sizeof(CTParagraphStyleSetting));
	CFDictionaryAddValue(styleDict, kCTParagraphStyleAttributeName, theParagraphRef);

	CFAttributedStringSetAttributes(text, CFRangeMake(position, length), styleDict, 0);
	CFRelease(theParagraphRef);
	CFRelease(styleDict);
}

- (void)applySingleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length {
	CFStringRef keys[] = {kCTUnderlineStyleAttributeName};
	CFTypeRef values[] = {(CFNumberRef)[NSNumber numberWithInt:kCTUnderlineStyleSingle]};

	CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

	CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);
	CFRelease(fontDict);
}

- (void)applyDashedlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length {
	CFStringRef keys[] = {kCTUnderlineStyleAttributeName};
	CFTypeRef values[] = {(CFNumberRef)[NSNumber numberWithInt:kCTUnderlineStyleSingle | kCTUnderlinePatternDot]};

	CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

	CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);
	CFRelease(fontDict);
}

- (void)applyDoubleUnderlineText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length {
	CFStringRef keys[] = {kCTUnderlineStyleAttributeName};
	CFTypeRef values[] = {(CFNumberRef)[NSNumber numberWithInt:kCTUnderlineStyleDouble]};

	CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

	CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);
	CFRelease(fontDict);
}

- (void)applyItalicStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length {
	UIFont *font = [UIFont italicSystemFontOfSize:self.font.pointSize];
	CTFontRef italicFont = CTFontCreateWithName((CFStringRef)[font fontName], [font pointSize], NULL);

	CFStringRef keys[] = {kCTFontAttributeName};
	CFTypeRef values[] = {italicFont};

	CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

	CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);

	CFRelease(italicFont);
	CFRelease(fontDict);
}

- (void)applyFontAttributes:(NSDictionary *)attributes toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length {
	for (NSString *key in attributes) {
		NSString *value = [attributes objectForKey:key];
		value = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];

		if ([key isEqualToString:@"color"]) {
			[self applyColor:value toText:text atPosition:position withLength:length];
		} else if ([key isEqualToString:@"stroke"]) {
			CFStringRef keys[] = {kCTStrokeWidthAttributeName};
			CFTypeRef values[] = {[NSNumber numberWithFloat:[[attributes objectForKey:@"stroke"] intValue]]};

			CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

			CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);

			CFRelease(fontDict);
		} else if ([key isEqualToString:@"kern"]) {
			CFStringRef keys[] = {kCTKernAttributeName};
			CFTypeRef values[] = {[NSNumber numberWithFloat:[[attributes objectForKey:@"kern"] intValue]]};

			CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

			CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);

			CFRelease(fontDict);
		} else if ([key isEqualToString:@"underline"]) {
			int numberOfLines = [value intValue];

			if (numberOfLines == 1) {
				// single underline
				[self applySingleUnderlineText:text atPosition:position withLength:length];
			} else if (numberOfLines == 2) {
				// double underline
				[self applyDoubleUnderlineText:text atPosition:position withLength:length];
			} else if (numberOfLines == 3) {
				// dashed line
				[self applyDashedlineText:text atPosition:position withLength:length];
			}
		} else if ([key isEqualToString:@"style"]) {
			if ([value isEqualToString:@"bold"]) {
				[self applyBoldStyleToText:text atPosition:position withLength:length];
			} else if ([value isEqualToString:@"italic"]) {
				[self applyItalicStyleToText:text atPosition:position withLength:length];
			}
		}
	}

	UIFont *font = nil;

	if ([attributes objectForKey:@"face"] && [attributes objectForKey:@"size"]) {
		NSString *fontName = [attributes objectForKey:@"face"];
		fontName = [fontName stringByReplacingOccurrencesOfString:@"'" withString:@""];
		font = [UIFont fontWithName:fontName size:[[attributes objectForKey:@"size"] intValue]];
	} else if ([attributes objectForKey:@"face"] && ![attributes objectForKey:@"size"]) {
		NSString *fontName = [attributes objectForKey:@"face"];
		fontName = [fontName stringByReplacingOccurrencesOfString:@"'" withString:@""];
		font = [UIFont fontWithName:fontName size:self.font.pointSize];
	} else if (![attributes objectForKey:@"face"] && [attributes objectForKey:@"size"]) {
		font = [UIFont fontWithName:[self.font fontName] size:[[attributes objectForKey:@"size"] intValue]];
	}

	if (font) {
		CTFontRef customFont = CTFontCreateWithName((CFStringRef)[font fontName], [font pointSize], NULL);

		CFStringRef keys[] = {kCTFontAttributeName};
		CFTypeRef values[] = {customFont};

		CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

		CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);

		CFRelease(customFont);
		CFRelease(fontDict);
	}
}

#pragma mark - 调用解析链接
// This method will be called when parsing a link
- (void)applyBoldStyleToText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length {
	// If the font size is very large(bigger than 30), core text will invoke a memory
	// warning, and may cause crash.
	UIFont *font = [UIFont boldSystemFontOfSize:self.font.pointSize + 1];
	CTFontRef boldFont = CTFontCreateWithName((CFStringRef)[font fontName], [font pointSize], NULL);
	CFStringRef keys[] = {kCTFontAttributeName};
	CFTypeRef values[] = {boldFont};

	CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

	CFAttributedStringSetAttributes(text, CFRangeMake(position, length), fontDict, 0);

	// CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTFontAttributeName, boldFont);

	// CFAttributedStringSetAttribute(text, CFRangeMake(position, length), kCTFontAttributeName, _thisFont);
	CFRelease(boldFont);
	CFRelease(fontDict);
}

- (void)applyColor:(NSString *)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length {
	if (!value) {
		CGColorRef color = [self.textColor CGColor];

		CFStringRef keys[] = {kCTForegroundColorAttributeName};
		CFTypeRef values[] = {color};

		CFDictionaryRef colorDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

		CFAttributedStringSetAttributes(text, CFRangeMake(position, length), colorDict, 0);
		CFRelease(colorDict);
	} else if ([value rangeOfString:@"#"].location == 0) {
		CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
		value = [value stringByReplacingOccurrencesOfString:@"#" withString:@""];
		NSArray *colorComponents = [self colorForHex:value];
		CGFloat components[] = {[[colorComponents objectAtIndex:0] floatValue], [[colorComponents objectAtIndex:1] floatValue], [[colorComponents objectAtIndex:2] floatValue], [[colorComponents objectAtIndex:3] floatValue]};
		CGColorRef color = CGColorCreate(rgbColorSpace, components);

		CFStringRef keys[] = {kCTForegroundColorAttributeName};
		CFTypeRef values[] = {color};

		CFDictionaryRef colorDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

		CFAttributedStringSetAttributes(text, CFRangeMake(position, length), colorDict, 0);

		CGColorRelease(color);
		CFRelease(colorDict);
		CGColorSpaceRelease(rgbColorSpace);
	} else {
		value = [value stringByAppendingString:@"Color"];
		SEL colorSel = NSSelectorFromString(value);
		UIColor *_color = nil;

		if ([UIColor respondsToSelector:colorSel]) {
			_color = [UIColor performSelector:colorSel];
			CGColorRef color = [_color CGColor];

			CFStringRef keys[] = {kCTForegroundColorAttributeName};
			CFTypeRef values[]		  = {color							};

			CFDictionaryRef colorDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

			CFAttributedStringSetAttributes(text, CFRangeMake(position, length), colorDict, 0);

			CFRelease(colorDict);
		}
	}
}

- (void)applyUnderlineColor:(NSString *)value toText:(CFMutableAttributedStringRef)text atPosition:(int)position withLength:(NSUInteger)length {
	value = [value stringByReplacingOccurrencesOfString:@"'" withString:@""];

	if ([value rangeOfString:@"#"].location == 0) {
		CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
		value = [value stringByReplacingOccurrencesOfString:@"#" withString:@""];
		NSArray *colorComponents = [self colorForHex:value];
		CGFloat components[] = {[[colorComponents objectAtIndex:0] floatValue], [[colorComponents objectAtIndex:1] floatValue], [[colorComponents objectAtIndex:2] floatValue], [[colorComponents objectAtIndex:3] floatValue]};
		CGColorRef color = CGColorCreate(rgbColorSpace, components);

		CFStringRef keys[] = {kCTUnderlineColorAttributeName};
		CFTypeRef values[] = {color};

		CFDictionaryRef colorDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

		CFAttributedStringSetAttributes(text, CFRangeMake(position, length), colorDict, 0);

		CGColorRelease(color);
		CFRelease(colorDict);
		CGColorSpaceRelease(rgbColorSpace);
	} else {
		value = [value stringByAppendingString:@"Color"];
		SEL colorSel = NSSelectorFromString(value);
		UIColor *_color = nil;

		if ([UIColor respondsToSelector:colorSel]) {
			_color = [UIColor performSelector:colorSel];
			CGColorRef color = [_color CGColor];

			CFStringRef keys[] = {kCTUnderlineColorAttributeName};
			CFTypeRef values[]		  = {color						   };

			CFDictionaryRef colorDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

			CFAttributedStringSetAttributes(text, CFRangeMake(position, length), colorDict, 0);

			CFRelease(colorDict);
		}
	}
}

- (void)applyImageAttributes:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary *)attributes atPosition:(int)position withLength:(NSUInteger)length {
	// create the delegate
	CTRunDelegateCallbacks callbacks;

	callbacks.version = kCTRunDelegateVersion1;
	callbacks.dealloc = MyDeallocationCallback;
	callbacks.getAscent = MyGetAscentCallback;
	callbacks.getDescent = MyGetDescentCallback;
	callbacks.getWidth = MyGetWidthCallback;

	CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, [attributes objectForKey:TYPE_SELF_NAMEANDADDRESS]);

	CFStringRef keys[] = {kCTRunDelegateAttributeName, (CFStringRef)@"imageSrc", (CFStringRef)TYPE_SELF_NAMEANDADDRESS, (CFStringRef)TYPE_XPADDING, (CFStringRef)TYPE_YPADDING};
	CFTypeRef values[] = {delegate, [attributes objectForKey:RCLabelLinkForImage], [attributes objectForKey:TYPE_SELF_NAMEANDADDRESS], [attributes objectForKey:TYPE_XPADDING], [attributes objectForKey:TYPE_YPADDING]};

	CFDictionaryRef imgDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

	CFAttributedStringSetAttributes(text, CFRangeMake(position, length), imgDict, 0);

	CFRelease(delegate);
	CFRelease(imgDict);
}

- (void)applyLinkAttributes:(CFMutableAttributedStringRef)text attributes:(NSMutableDictionary *)attributes atPosition:(int)position withLength:(NSUInteger)length {
	[self applyBoldStyleToText:text atPosition:position withLength:length];
	[self applyColor:@"#16387C" toText:text atPosition:position withLength:length];
}

- (CGSize)optimumSize {
	[self render];

	if (CURRENT_DEVICE_VERSION >= 7.0) {
		// ios7在xcode打包时出现问题，+5后正常.
        // This seems to me like an iOS7 bug. I have been working, and under iOS6, CTFramesetterSuggestFrameSizeWithConstraints returns a size with height larger than 0. Same code under iOS7 returns a height of 0.
		return CGSizeMake(_optimumSize.width + 5, _optimumSize.height + 5);
	} else {
		return _optimumSize;
	}
}

- (void)dealloc {
	RELEASE(longPress);
	RELEASE(_labelSaveData);
	totalCount--;
	self.componentsAndPlainText = nil;
	RELEASE(_textColor);
	self.textColor = nil;
	self.font = nil;
	self.paragraphReplacement = nil;
	self.currentLinkComponent = nil;
	self.currentImgComponent = nil;
	[_originalColor release];
	CFRelease(_thisFont);
	_thisFont = NULL;

	if (_ctFrame) {
		CFRelease(_ctFrame);
		_ctFrame = NULL;
	}

	if (_framesetter) {
		CFRelease(_framesetter);
		_framesetter = NULL;
	}

	if (_attrString) {
		CFRelease(_attrString);
		_attrString = NULL;
	}

	[super dealloc];
}

+ (RTLabelComponentsStructure *)extractTextStyle:(NSString *)data {
	NSScanner *scanner = nil;
	NSString *text = nil;
	NSString *tag = nil;
	// These two variable are used to handle the unclosed tags.
	BOOL isBeginTag = NO;
	NSInteger beginTagCount = 0;
	// plainData is used to store the current plain result during the parse process,
	// such as <a>link to yahoo!</a> </font> (the start tag <font size=30> has
	// been parsed)
	NSString *plainData = @"";
    if (data && data.length > 0) {
        plainData = [NSString stringWithString:data];
    }
    //win:“\r\n”,0x0D0A;  linux:“\n”,0x0A;  mac:"\r",0x0D;
    plainData = [plainData stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\r"];

	NSMutableArray *components = [NSMutableArray array];
	NSMutableArray *linkComponents = [NSMutableArray array];
	NSMutableArray *imgComponents = [NSMutableArray array];

	NSInteger last_position = 0;

	scanner = [NSScanner scannerWithString:plainData];

	while (![scanner isAtEnd]) {
		// Begin element(such as <font size=30>) or end element(such as </font>)
		[scanner scanUpToString:@"<" intoString:&text];

		if ((beginTagCount <= 0) && !isBeginTag && text) {	// This words even can handle the unclosed tags elegancely
			NSRange subRange;

			// Decipher
			do {
				subRange = [plainData rangeOfString:@"&lt;" options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, [text length])];

				if (subRange.location == NSNotFound) {
					break;
				}

				plainData = [plainData stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<" options:NSCaseInsensitiveSearch range:subRange];
				text = [text stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<" options:NSCaseInsensitiveSearch range:NSMakeRange(subRange.location - last_position, subRange.length)];
			} while (true);

			do {
				subRange = [plainData rangeOfString:@"&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, [text length])];

				if (subRange.location == NSNotFound) {
					break;
				}

				plainData = [plainData stringByReplacingOccurrencesOfString:@"&gt;" withString:@">" options:NSCaseInsensitiveSearch range:subRange];
				text = [text stringByReplacingOccurrencesOfString:@"&gt;" withString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(subRange.location - last_position, subRange.length)];
			} while (true);

			RTLabelComponent *component = [RTLabelComponent componentWithString:text tag:@"rawText" attributes:nil];
			component.isClosure = YES;
			component.position = (int)last_position;
			[components addObject:component];
		}

		text = nil;

		[scanner scanUpToString:@">" intoString:&text];

		if (!text || [scanner isAtEnd]) {
			if (text) {
				plainData = [plainData stringByReplacingOccurrencesOfString:text withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange([plainData length] - [text length], [text length])];
			}

			break;
		} else {
			[scanner setScanLocation:[scanner scanLocation] + 1];
		}

		// delimiter now equals to a start tag(such as <font size=30>) or end tag(such as </font>)

		NSString *delimiter = [NSString stringWithFormat:@"%@>", text];
		NSInteger position = [plainData rangeOfString:delimiter options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, [plainData length] - last_position)].location;

		if ((position != NSNotFound) && (position >= last_position)) {
			isBeginTag = YES;
			beginTagCount++;
			// Only replace the string behind the position, so no need to
			// recalculate the position
			plainData = [plainData stringByReplacingOccurrencesOfString:delimiter withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(position, delimiter.length)];
		} else {// NOTE:This will never happen!
			// NSLog(@"Some Error happen in parsing");
			break;
		}

		// Strip the white space in both end
		NSString *tempString = [text substringFromIndex:1];
		text = [tempString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		// That means a end tag, we should store the plain text after parsing the tag
		if ([text rangeOfString:@"/"].location == 0) {
			isBeginTag = NO;
			beginTagCount--;
			// tag name

			// This can handle the awful white space too
			NSArray *textComponents = [[text substringFromIndex:1] componentsSeparatedByString:@" "];

			tag = [textComponents objectAtIndex:0];
			// NSLog(@"end of tag: %@", tag);
			NSRange subRange;

			// Decipher
			do {
				subRange = [plainData rangeOfString:@"&lt;" options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position - last_position)];

				if (subRange.location == NSNotFound) {
					break;
				}

				plainData = [plainData stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<" options:NSCaseInsensitiveSearch range:subRange];
				// Length of @"&lt;" substract length of @"<"
				position -= 3;
			} while (true);

			do {
				subRange = [plainData rangeOfString:@"&gt;" options:NSCaseInsensitiveSearch range:NSMakeRange(last_position, position - last_position)];

				if (subRange.location == NSNotFound) {
					break;
				}

				plainData = [plainData stringByReplacingOccurrencesOfString:@"&gt;" withString:@">" options:NSCaseInsensitiveSearch range:subRange];
				// Length of @"&gt;" substract length of @">"
				position -= 3;
			} while (true);

			// Find the latest tag
			// Do not use stack, because the overlapping tags are meaningful
			// This algrithm can handle the overlapping tags
			for (NSInteger i = [components count] - 1; i >= 0; i--) {
				RTLabelComponent *component = [components objectAtIndex:i];

				if (!component.isClosure && [component.tagLabel isEqualToString:tag]) {
					NSString *text2 = [plainData substringWithRange:NSMakeRange(component.position, position - component.position)];
					component.text = text2;
					component.isClosure = YES;
					break;
				}
			}
		} else {// start tag
			// tag name and tag attributes
			// These words can handle if the tag is a self-closed one
			BOOL isClosure = NO;
			NSRange range = [text rangeOfString:@"/" options:NSBackwardsSearch];

			if (range.location == [text length] - 1) {
				isClosure = YES;
				text = [text substringToIndex:[text length] - 1];
			}

			RTLabelComponent *component = nil;
			// These words can handle if the attribute string are concacted with awful white space
			NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
			NSRange subRange;

			// You can not simply use text = [text stringByReplacingOccurrencesOfString:@"= " withString:@"="]; instead,
			// since this function can not execute incursively
			do {
				subRange = [text rangeOfString:@"= "];

				if (subRange.location == NSNotFound) {
					break;
				}

				text = [text stringByReplacingOccurrencesOfString:@"= " withString:@"=" options:NSCaseInsensitiveSearch range:subRange];
			} while (true);

			do {
				subRange = [text rangeOfString:@" ="];

				if (subRange.location == NSNotFound) {
					break;
				}

				text = [text stringByReplacingOccurrencesOfString:@" =" withString:@"=" options:NSCaseInsensitiveSearch range:subRange];
			} while (true);

			NSArray *textComponents = [text componentsSeparatedByString:@" "];

			tag = [textComponents objectAtIndex:0];

			if ((tag != nil) && [tag length]) {	// That means the tag starts with a white space, ignore it, treat it as a raw text
				for (int i = 1; i < [textComponents count]; i++) {
					// NSLog(@"textComponents %d:%@",i,[textComponents objectAtIndex:i]);
					NSArray *pair = [[textComponents objectAtIndex:i] componentsSeparatedByString:@"="];

					if ([pair count] >= 2) {
						[attributes setObject:[[pair subarrayWithRange:NSMakeRange(1, [pair count] - 1)] componentsJoinedByString:@"="] forKey:[pair objectAtIndex:0]];
					}
				}

				component = [RTLabelComponent componentWithString:nil tag:tag attributes:attributes];
			} else {
				component = [RTLabelComponent componentWithString:nil tag:@"rawText" attributes:attributes];
			}

			// Store the start position, which will be used to calculate
			// the plain text inside of a tag
			component.position = (int)position;
			component.isClosure = isClosure;
			BOOL isSizeTooSmall = NO;

			if ([component.tagLabel isEqualToString:@"img"]) {
				NSString *url = [component.attributes objectForKey:RCLabelLinkForImage];
				NSString *tempURL = [RCLabel stripURL:url];
				NSString *key = [NSString stringWithFormat:@"%@%@%@", tempURL, TYPE_TJRFACE_DELIMITER, [NSString stringWithFormat:@"%p", plainData]];// 图片名称加当前html字符串地址(区分一个页面里同一个表情不同大小)
				[component.attributes setObject:key forKey:TYPE_SELF_NAMEANDADDRESS];
				CGSize size = CGSizeMake([[component.attributes objectForKey:TYPE_WIDTH] floatValue], [[component.attributes objectForKey:TYPE_HEIGHT] floatValue]);

				if ((size.width > 0) && (size.height > 0)) {// 图片有带宽高时,设置图片的宽高
					if (!imgSizeDict) imgSizeDict = [[NSMutableDictionary dictionary] retain];
					NSValue *nsv = [NSValue valueWithBytes:&size objCType:@encode(CGSize)];
					[imgSizeDict setObject:nsv forKey:key];
				}

				if (![component.attributes objectForKey:TYPE_XPADDING]) {	// 图片没有向左padding值时,-1为默认
					[component.attributes setObject:@"320" forKey:TYPE_XPADDING];
				}

				if (![component.attributes objectForKey:TYPE_YPADDING]) {	// 图片没有向下padding值时,-1为默认
					[component.attributes setObject:@"320" forKey:TYPE_YPADDING];
				}

				if (tempURL) {
					[component.attributes setObject:tempURL forKey:RCLabelLinkForImage];
				} else {
					[component.attributes setObject:@"" forKey:RCLabelLinkForImage];
				}

				if (!isSizeTooSmall) {
					NSMutableString *tempString = [NSMutableString stringWithString:plainData];

					if (CURRENT_DEVICE_VERSION >= 7.0) {
						[tempString insertString:@"\b" atIndex:position];			// 将图片替换
					} else {
						[tempString insertString:@"\u2000\u2000" atIndex:position];	// 将图片替换
					}

					plainData = [NSString stringWithString:tempString];
					component.text = [plainData substringWithRange:NSMakeRange(component.position, 1)];
					component.isClosure = YES;

					[components addObject:component];
				}
			} else {
				[components addObject:component];
			}

			if ([component.tagLabel isEqualToString:@"a"]) {
				[linkComponents addObject:component];
			}

			if ([component.tagLabel isEqualToString:@"img"]) {
				[imgComponents addObject:component];
			}
		}

		last_position = position;
		text = nil;
	}

	for (RTLabelComponent *item in components) {
		if (!item.isClosure) {
			NSString *text2 = [plainData substringWithRange:NSMakeRange(item.position, [plainData length] - item.position)];
			item.text = text2;
		}
	}

	RTLabelComponentsStructure *componentsDS = [[RTLabelComponentsStructure alloc] init];
	componentsDS.components = components;
	componentsDS.linkComponents = linkComponents;
	componentsDS.imgComponents = imgComponents;
	componentsDS.plainTextData = plainData;
	return [componentsDS autorelease];
}

- (void)genAttributedString {
	if (!self.componentsAndPlainText || !self.componentsAndPlainText.plainTextData || !self.componentsAndPlainText.components) {
		return;
	}

	CFStringRef string = (CFStringRef)self.componentsAndPlainText.plainTextData;

	if (_attrString) {
		CFRelease(_attrString);
		_attrString = NULL;
	}

	_attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);

	CFAttributedStringReplaceString(_attrString, CFRangeMake(0, 0), string);

	CFMutableDictionaryRef styleDict = CFDictionaryCreateMutable(NULL, 0, 0, 0);

	CFDictionaryAddValue(styleDict, kCTForegroundColorAttributeName, [self.textColor CGColor]);
	CFAttributedStringSetAttributes(_attrString, CFRangeMake(0, CFAttributedStringGetLength(_attrString)), styleDict, 0);

	[self applyParagraphStyleToText:_attrString attributes:nil atPosition:0 withLength:CFAttributedStringGetLength(_attrString)];

	CFStringRef keys[] = {kCTFontAttributeName};
	CFTypeRef values[] = {_thisFont};

	CFDictionaryRef fontDict = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), NULL, NULL);

	CFAttributedStringSetAttributes(_attrString, CFRangeMake(0, CFAttributedStringGetLength(_attrString)), fontDict, 0);

	CFRelease(fontDict);

	for (RTLabelComponent *component in self.componentsAndPlainText.components) {
		NSUInteger index = [self.componentsAndPlainText.components indexOfObject:component];
		component.componentIndex = (int)index;

		if ([component.tagLabel isEqualToString:@"i"]) {
			// make font italic
			[self applyItalicStyleToText:_attrString atPosition:component.position withLength:[component.text length]];
			[self applyColor:nil toText:_attrString atPosition:component.position withLength:[component.text length]];
			// [self applyColor:@"#2e2e2e" toText:_attrString atPosition:component.position withLength:[component.text length]];
		} else if ([component.tagLabel isEqualToString:@"b"]) {
			// make font bold
			[self applyBoldStyleToText:_attrString atPosition:component.position withLength:[component.text length]];
			[self applyColor:nil toText:_attrString atPosition:component.position withLength:[component.text length]];
			// [self applyColor:@"#2e2e2e" toText:_attrString atPosition:component.position withLength:[component.text length]];
		} else if ([component.tagLabel isEqualToString:@"a"]) {
			if ([component.attributes objectForKey:RCLabelLinkForUrl]) {
				NSString *value = [component.attributes objectForKey:RCLabelLinkForUrl];

				if (!value) {
					[component.attributes setObject:@"" forKey:RCLabelLinkForUrl];
				}

				[self applyLinkAttributes:_attrString attributes:component.attributes atPosition:component.position withLength:[component.text length]];
			} else if ([component.attributes objectForKey:RCLabelLinkForTopic]) {
				NSString *value = [component.attributes objectForKey:RCLabelLinkForTopic];

				if (!value) {
					[component.attributes setObject:@"" forKey:RCLabelLinkForTopic];
				}

				[self applyColor:@"#16387C" toText:_attrString atPosition:component.position withLength:[component.text length]];
			} else if ([component.attributes objectForKey:RCLabelLinkForFullcode]) {
				NSString *value = [component.attributes objectForKey:RCLabelLinkForFullcode];

				if (!value) {
					[component.attributes setObject:@"" forKey:RCLabelLinkForFullcode];
				}

				// [self applyBoldStyleToText:_attrString atPosition:component.position withLength:[component.text length]];
				[self applyColor:@"#16387C" toText:_attrString atPosition:component.position withLength:[component.text length]];
			} else if ([component.attributes objectForKey:RCLabelLinkForUser]) {
				NSString *value = [component.attributes objectForKey:RCLabelLinkForUser];

				if (!value) {
					[component.attributes setObject:@"" forKey:RCLabelLinkForUser];
				}
				[self applyLinkAttributes:_attrString attributes:component.attributes atPosition:component.position withLength:[component.text length]];
			}
		} else if ([component.tagLabel isEqualToString:@"u"] || [component.tagLabel isEqualToString:@"underlined"]) {
			// underline
			if ([component.tagLabel isEqualToString:@"u"]) {
				[self applySingleUnderlineText:_attrString atPosition:component.position withLength:[component.text length]];
			}

			if ([component.attributes objectForKey:@"color"]) {
				NSString *value = [component.attributes objectForKey:@"color"];
				[self applyUnderlineColor:value toText:_attrString atPosition:component.position withLength:[component.text length]];
			}
		} else if ([component.tagLabel isEqualToString:@"font"]) {
			[self applyFontAttributes:component.attributes toText:_attrString atPosition:component.position withLength:[component.text length]];
		} else if ([component.tagLabel isEqualToString:@"p"]) {
			[self applyParagraphStyleToText:_attrString attributes:component.attributes atPosition:component.position withLength:[component.text length]];
		} else if ([component.tagLabel isEqualToString:@"img"]) {
			[self applyImageAttributes:_attrString attributes:component.attributes atPosition:component.position withLength:[component.text length]];
		}
	}

	CFRelease(styleDict);
}

- (NSArray *)colorForHex:(NSString *)hexColor {
	hexColor = [[hexColor stringByTrimmingCharactersInSet:
			[NSCharacterSet whitespaceAndNewlineCharacterSet]
		] uppercaseString];

	NSRange range;
	range.location = 0;
	range.length = 2;

	NSString *rString = [hexColor substringWithRange:range];

	range.location = 2;
	NSString *gString = [hexColor substringWithRange:range];

	range.location = 4;
	NSString *bString = [hexColor substringWithRange:range];

	// Scan values
	unsigned int r, g, b;
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];

	NSArray *components = [NSArray arrayWithObjects:[NSNumber numberWithFloat:((float)r / 255.0f)], [NSNumber numberWithFloat:((float)g / 255.0f)], [NSNumber numberWithFloat:((float)b / 255.0f)], [NSNumber numberWithFloat:1.0], nil];
	return components;
}

// Remove the space and quotation
+ (NSString *)stripURL:(NSString *)url {
	return [[url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\\\'\""]];
}

#pragma mark - touch事件
#pragma mark 长按
- (void)setCanLongClick:(BOOL)canLongClick {
	_canLongClick = canLongClick;

	if (_canLongClick) {
		if (!longPress) {
			longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
			longPress.allowableMovement = NO;
			longPress.minimumPressDuration = 1;
		}
		[self addGestureRecognizer:longPress];
	} else {
		[self removeGestureRecognizer:longPress];
	}
}

- (void)longPressed:(UILongPressGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		CGPoint location = [recognizer locationInView:self];
		[self touchesBeganWithTouchPoint:location];
		isLongPress = YES;

		if (isLongPress && [_delegate respondsToSelector:@selector(rtLabelSelfLongPress:longClickData:)]) {	// 长按
			[_delegate rtLabelSelfLongPress:self longClickData:self.labelSaveData];
		}
		[self dismissBoundRectForTouch];
	} else {
		isLongPress = NO;
		[self dismissBoundRectForTouch];
	}
}

#pragma mark 单击

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];

	if (![self touchesBeganWithTouchPoint:location]) {
		return [super touchesBegan:touches withEvent:event];
	}
}

#pragma mark - 返回值表示当前点击位置是否是可以跳转的
- (BOOL)touchesBeganWithTouchPoint:(CGPoint)location {
	if (!backgroundColor) {
		backgroundColor = self.backgroundColor;
	}

	if (_ctFrame == nil) {
		[self selfSelect];
		return NO;
	}

	CFArrayRef lines = CTFrameGetLines(_ctFrame);
	CGPoint origins[CFArrayGetCount(lines)];

	CTFrameGetLineOrigins(_ctFrame, CFRangeMake(0, 0), origins);

	CTLineRef line = NULL;
	CGPoint lineOrigin = CGPointZero;
	CGPathRef path = CTFrameGetPath(_ctFrame);
	CGRect rect = CGPathGetBoundingBox(path);
	CGFloat nextLineY = 0;

	for (int i = 0; i < CFArrayGetCount(lines); i++) {
		CGPoint origin = origins[i];
		CGFloat y = rect.origin.y + rect.size.height - origin.y;
		CTLineRef tempLine = CFArrayGetValueAtIndex(lines, i);
		CGFloat ascend = 0;
		CGFloat decend = 0;
		CGFloat leading = 0;
		CTLineGetTypographicBounds(tempLine, &ascend, &decend, &leading);
		y -= ascend;

		if ((location.y >= y) && (location.x >= origin.x)) {
			line = CFArrayGetValueAtIndex(lines, i);
			lineOrigin = origin;
		}

		nextLineY = y + ascend + fabs(decend) + leading;
	}

	if (!line || (location.y >= nextLineY)) {
		[self selfSelect];
		return self.canClickTurn;
	}

	location.x -= lineOrigin.x;

	CFArrayRef runs = CTLineGetGlyphRuns(line);
	CGFloat lineAscent;
	CGFloat lineDescent;
	CGFloat lineLeading;
	CTRunRef run = nil;
	CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
	BOOL isClicked = NO;

	for (int j = 0; j < CFArrayGetCount(runs); j++) {
		run = CFArrayGetValueAtIndex(runs, j);
		CGFloat ascent, descent, leading;
		CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
		const CGPoint *positions = CTRunGetPositionsPtr(run);

		if (positions!= NULL && location.x <= width + positions[0].x) {
			isClicked = YES;
			break;
		}
	}

	if (!isClicked) {
		[self selfSelect];
		return self.canClickTurn;
	}

	CFRange runRange = CTRunGetStringRange(run);
	RTLabelComponent *tempComponent = nil;

	for (RTLabelComponent *component in self.componentsAndPlainText.linkComponents) {
		BOOL runStartAfterLink = ((runRange.location >= component.position) && (runRange.location < component.position + component.text.length));
		BOOL runStartBeforeLink = ((runRange.location < component.position) && (runRange.location + runRange.length) > component.position);

		if (runStartAfterLink || runStartBeforeLink) {
			tempComponent = component;
		}
	}

	if (tempComponent) {
		self.currentLinkComponent = tempComponent;
		[self setNeedsDisplay];
		return YES;
	} else {
		for (RTLabelComponent *component in self.componentsAndPlainText.imgComponents) {
			BOOL runStartAfterLink = ((runRange.location >= component.position) && (runRange.location < component.position + component.text.length));
			BOOL runStartBeforeLink = ((runRange.location < component.position) && (runRange.location + runRange.length) > component.position);

			if (runStartAfterLink || runStartBeforeLink) {
				tempComponent = component;
			}
		}

		if (tempComponent) {
			NSString *url = [[tempComponent.attributes objectForKey:RCLabelLinkForImage] stringByReplacingOccurrencesOfString:@"'" withString:@""];

			if ([url rangeOfString:@"TJRFace_"].location != NSNotFound) {	//Redz表情不超链接
				[self selfSelect];
				return NO;
			}

			self.currentImgComponent = tempComponent;
			[self setNeedsDisplay];
			return YES;
		} else if (self.canClickTurn) {
			[self selfSelect];
			return YES;
		} else {
			[self selfSelect];
			return NO;
		}
	}
	return NO;
}

- (void)selfSelect {
	if (self.canClickTurn) {
		isClickDown = YES;
		self.backgroundColor = self.selectColor ? self.selectColor :[UIColor grayColor];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	[self performSelector:@selector(setBackgroundColor:) withObject:backgroundColor afterDelay:0.15];
	[self dismissBoundRectForTouch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!isLongPress) {
		NSString *url = nil;

		if (self.currentLinkComponent && (((NSString *)[self.currentLinkComponent.attributes objectForKey:RCLabelLinkForUrl]).length > 0)) {
			[self performSelector:@selector(dismissBoundRectForTouch) withObject:nil afterDelay:0.1];

			if ([_delegate respondsToSelector:@selector(rtLabel:didSelectLinkWithURL:)]) {	// 单击
				url = [[self.currentLinkComponent.attributes objectForKey:RCLabelLinkForUrl] stringByReplacingOccurrencesOfString:@"'" withString:@""];

				[_delegate rtLabel:self didSelectLinkWithURL:url];
            }
		} else if (self.currentLinkComponent && (((NSString *)[self.currentLinkComponent.attributes objectForKey:RCLabelLinkForTopic]).length > 0)) {
			[self performSelector:@selector(dismissBoundRectForTouch) withObject:nil afterDelay:0.1];

			if ([_delegate respondsToSelector:@selector(rtLabel:didSelectLinKWithTopic:)]) {
				url = [[self.currentLinkComponent.attributes objectForKey:RCLabelLinkForTopic] stringByReplacingOccurrencesOfString:@"'" withString:@""];

				[_delegate rtLabel:self didSelectLinKWithTopic:url];
			}
		} else if (self.currentLinkComponent && (((NSString *)[self.currentLinkComponent.attributes objectForKey:RCLabelLinkForFullcode]).length > 0)) {
			[self performSelector:@selector(dismissBoundRectForTouch) withObject:nil afterDelay:0.1];

			if ([_delegate respondsToSelector:@selector(rtLabel:didSelectLinkWithFullcode:)]) {
				url = [[self.currentLinkComponent.attributes objectForKey:RCLabelLinkForFullcode] stringByReplacingOccurrencesOfString:@"'" withString:@""];

				[_delegate rtLabel:self didSelectLinkWithFullcode:url];
			}
		} else if (self.currentLinkComponent && (((NSString *)[self.currentLinkComponent.attributes objectForKey:RCLabelLinkForUser]).length > 0)) {
			[self performSelector:@selector(dismissBoundRectForTouch) withObject:nil afterDelay:0.1];

			if ([_delegate respondsToSelector:@selector(rtLabel:didSelectLinKWithUserId:)]) {
				url = [[self.currentLinkComponent.attributes objectForKey:RCLabelLinkForUser] stringByReplacingOccurrencesOfString:@"'" withString:@""];

				[_delegate rtLabel:self didSelectLinKWithUserId:url];
			}
		} else if (self.currentImgComponent) {
			[self performSelector:@selector(dismissBoundRectForTouch) withObject:nil afterDelay:0.1];

			if ([_delegate respondsToSelector:@selector(rtLabel:didSelectLinkWithURL:)]) {
				url = [[self.currentImgComponent.attributes objectForKey:RCLabelLinkForImage] stringByReplacingOccurrencesOfString:@"'" withString:@""];

				[_delegate rtLabel:self didSelectLinkWithURL:url];
			}
		} else if (self.canClickTurn) {
			[self performSelector:@selector(setBackgroundColor:) withObject:backgroundColor afterDelay:0.15];

			if (isClickDown) {	// 单击
				if (_delegate && [_delegate respondsToSelector:@selector(rtLabelSelectSelf:clickData:)]) {
					[_delegate rtLabelSelectSelf:self clickData:self.labelSaveData];
				}
			}
		} else {
			[super touchesEnded:touches withEvent:event];
		}
	} else {
		[super touchesEnded:touches withEvent:event];
	}

	[self performSelector:@selector(dismissBoundRectForTouch) withObject:nil afterDelay:0.1];
}

- (void)dismissBoundRectForTouch {
	self.currentImgComponent = nil;
	self.currentLinkComponent = nil;
	isClickDown = NO;
	isLongPress = NO;
	[self setNeedsDisplay];
}

- (NSString *)visibleText {
	[self render];
	NSString *text = [self.componentsAndPlainText.plainTextData substringWithRange:NSMakeRange(_visibleRange.location, _visibleRange.length)];
	return text;
}

@end

