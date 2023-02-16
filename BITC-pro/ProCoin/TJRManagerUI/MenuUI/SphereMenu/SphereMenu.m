//
//  SphereMenu.m
//  SphereMenu
//
//  Created by Tu You on 14-8-24.
//  Copyright (c) 2014年 TU YOU. All rights reserved.
//

#import "SphereMenu.h"

static const int kItemInitTag = 9298;
static const CGFloat kAngleOffset = M_PI / 3.0;
static const float kSphereDamping = 0.3;

NSUInteger const MaxCount = 8;

@implementation SphereMenu

- (instancetype)initWithStartPoint:(CGPoint)_startPoint startImage:(UIImage *)startImage
                     submenuImages:(NSArray *)submenuImages {
    self = [super init];
    if (self) {
        CGSize startSize = startImage.size;
        CGRect bounds = CGRectZero;
        bounds.size = startSize;
        self.bounds = bounds;
        startPoint = _startPoint;
        self.center = startPoint;
        sphereLength = 80;
        itemSize = CGSizeZero;
        [self initSphereMenuWithStartImage:startImage startSize:startSize submenuImages:submenuImages];
    }
    return self;
}

- (instancetype)initWithStartPoint:(CGPoint)_startPoint startSize:(CGSize)startSize
                      sphereLength:(CGFloat)length
                          itemSize:(CGSize)size startImage:(UIImage *)startImage
                     submenuImages:(NSArray *)submenuImages {
    self = [super init];
    if (self) {
        CGRect bounds = CGRectZero;
        bounds.size = startSize;
        self.bounds = bounds;
        startPoint = _startPoint;
        self.center = startPoint;
        sphereLength = length;
        itemSize = size;
        [self initSphereMenuWithStartImage:startImage startSize:startSize submenuImages:submenuImages];
    }
    return self;
}

- (void)initSphereMenuWithStartImage:(UIImage *)startImage
                           startSize:(CGSize)startSize
                       submenuImages:(NSArray *)submenuImages {
    _reduction = YES;
    _enabled = YES;
    movePoint = CGPointZero;
    images = [[NSArray alloc] initWithArray:submenuImages];
    count = images.count;
    start = [[UIImageView alloc] initWithImage:startImage];
    CGRect frame = start.frame;
    frame.size = startSize;
    start.frame = frame;
    start.userInteractionEnabled = YES;
    tapOnStart = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTapped:)];
    [start addGestureRecognizer:tapOnStart];
    [self addSubview:start];
}

- (void)commonSetup {
    items = [NSMutableArray new];
    positions = [NSMutableArray new];
    snaps = [NSMutableArray new];
    
    NSUInteger i = 0;
    for (UIImage *image in images) {
        UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
        [items addObject:item];
        
        [item setImage:image forState:UIControlStateNormal];
        
        if (!CGSizeEqualToSize(itemSize, CGSizeZero)) {
            CGRect frame = item.frame;
            frame.size = itemSize;
            item.frame = frame;
        }
        
        item.tag = kItemInitTag + i;
        [self.superview addSubview:item];
        
        CGPoint position = [self centerForSphereAtIndex:(int)i];
        item.center = self.center;
        [positions addObject:[NSValue valueWithCGPoint:position]];
        
        [item addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        [item addGestureRecognizer:pan];
        RELEASE(pan);
        
        UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:item snapToPoint:self.center];
        snap.damping = kSphereDamping;
        [snaps addObject:snap];
        RELEASE(snap);
        i++;
    }
    
    [self.superview bringSubviewToFront:self];
    
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
    
    collision = [[UICollisionBehavior alloc] initWithItems:items];
    collision.translatesReferenceBoundsIntoBoundary = YES;
    collision.collisionDelegate = self;
    
    itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:items];
    itemBehavior.allowsRotation = YES;//碰撞过程中是否不能旋转
    itemBehavior.density = 0.5;//密度 ： 跟size结合使用，计算物体的总质量。质量越大，物体加速或减速就越困难
    itemBehavior.angularResistance = 5;//角阻力 ：决定旋转运动时的阻力大小
    itemBehavior.resistance = 15;//阻力：决定线性移动的阻力大小，与摩擦系数不同，摩擦系数只作用于滑动运动
    itemBehavior.elasticity = 0.8;//弹性系数 ：决定了碰撞的弹性程度，比如碰撞时物体的弹性
    itemBehavior.friction = 1;//摩擦系数 ：决定了沿接触面滑动时的摩擦力大小
}

- (void)setItemImage:(UIImage *)image index:(int)index {
    if (index < items.count) {
        UIButton *btn = items[index];
        [btn setImage:image forState:UIControlStateNormal];
    }
}

- (NSArray *)sphereMenuItems {
    return items;
}

- (void)didMoveToSuperview {
    [self commonSetup];
}

- (void)removeFromSuperview {
    [items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [super removeFromSuperview];
}

- (CGPoint)centerForSphereAtIndex:(int)index {
//    CGFloat firstAngle = M_PI_4 * 5 + (M_PI_2 - kAngleOffset) + (index - 1) * kAngleOffset;
    CGFloat firstAngle = M_PI + index * kAngleOffset;
    CGFloat x = startPoint.x + cos(firstAngle) * sphereLength;
    CGFloat y = startPoint.y + sin(firstAngle) * sphereLength;
    CGPoint position = CGPointMake(x, y);
    return position;
}

- (void)moveSpherMenuWithY:(CGFloat)y {
    movePoint.y = y;
    isAutoMove = NO;
    CGPoint center = self.center;
    center.x = startPoint.x + movePoint.x;
    center.y = startPoint.y +movePoint.y;
    self.center = center;
    for (UIButton *btn in items) {
        btn.center = center;
    }
    if (expanded) {
        //        isAutoMove = YES;
        [self expandOrShrinkSubmenu:!expanded];
        return;
    }
}

- (void)tapped:(UIButton *)sender {
    if (!_enabled) return;
    [self expandOrShrinkSubmenu:NO];
    if ([self.delegate respondsToSelector:@selector(sphereDidSelected:)]) {
        int tag = (int)sender.tag;
        tag -= kItemInitTag;
        [self.delegate sphereDidSelected:tag];
    }
}

- (void)startTapped:(UITapGestureRecognizer *)gesture {
    if (!_enabled) return;
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self expandOrShrinkSubmenu:!expanded];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)expandOrShrinkSubmenu:(BOOL)isExpand {
    if (expanded == isExpand) return;
    if (_startCanRotation) {
        [UIView animateWithDuration:0.2 animations:^{
            if (isExpand) {
                start.transform = CGAffineTransformMakeRotation(M_PI_4);
            }else {
                start.transform = CGAffineTransformIdentity;
            }
        }];
    }
    [animator removeBehavior:collision];
    [animator removeBehavior:itemBehavior];
    [self removeSnapBehaviors];
    if (isExpand) {
        [self expandSubmenu];
    } else {
        [self shrinkSubmenu];
    }
}

- (void)shrink {
    [animator removeBehavior:collision];
    [animator removeBehavior:itemBehavior];
    [self removeSnapBehaviors];
    [self shrinkSubmenu];
}

- (void)expandSubmenu {
    expanded = YES;
    for (int i = 0; i < count; i++) {
        [self snapToPostionsWithIndex:i];
    }
}

- (void)shrinkSubmenu {
    expanded = NO;
    for (int i = 0; i < count; i++) {
        [self snapToStartWithIndex:i];
    }
}

- (void)panned:(UIPanGestureRecognizer *)gesture {
    if (!_enabled) return;
    UIView *touchedView = gesture.view;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [animator removeBehavior:itemBehavior];
        [animator removeBehavior:collision];
        [self removeSnapBehaviors];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        touchedView.center = [gesture locationInView:self.superview];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        bumper = touchedView;
        [animator addBehavior:collision];
        NSUInteger index = [items indexOfObject:touchedView];
        
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 {
    [animator addBehavior:itemBehavior];
    
    if (item1 != bumper) {
        NSUInteger index = (int)[items indexOfObject:item1];
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
    
    if (item2 != bumper) {
        NSUInteger index = (int)[items indexOfObject:item2];
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
    if (self.isReduction) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(reductionSubmenu) withObject:nil afterDelay:0.25];
    }
    if (isAutoMove) {
        [self moveSpherMenuWithY:movePoint.y];
    }
}

- (void)reductionSubmenu {
    [animator removeBehavior:collision];
    [animator removeBehavior:itemBehavior];
    [self expandSubmenu];
}

- (void)snapToStartWithIndex:(NSUInteger)index {
    if (index < items.count) {
        UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:items[index] snapToPoint:self.center];
        snap.damping = kSphereDamping;
        UISnapBehavior *snapToRemove = snaps[index];
        [animator removeBehavior:snapToRemove];
        [snaps replaceObjectAtIndex:index withObject:snap];
        [animator addBehavior:snap];
        RELEASE(snap);
    }
}

- (void)snapToPostionsWithIndex:(NSUInteger)index {
    if (index < items.count && index < positions.count) {
        NSValue *positionValue = positions[index];
        CGPoint position = [positionValue CGPointValue];
        position.x += movePoint.x;
        position.y += movePoint.y;
        UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:items[index] snapToPoint:position];
        snap.damping = kSphereDamping;
        UISnapBehavior *snapToRemove = snaps[index];
        [animator removeBehavior:snapToRemove];
        [snaps replaceObjectAtIndex:index withObject:snap];
        [animator addBehavior:snap];
        RELEASE(snap);
    }
}

- (void)removeSnapBehaviors {
    // 迭代处理,和forin在效率上基本一致，有时会快些。主要是因为它们都是基于 NSFastEnumeration 实现的. 快速迭代在处理的过程中需要多一次转换，当然也会消耗掉一些时间
    [snaps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [animator removeBehavior:obj];
    }];
}

- (void)hideSphereMenu:(BOOL)isHide {
    [UIView animateWithDuration:0.25 animations:^{
        start.hidden = isHide;
        for (UIImageView *view in items) {
            view.hidden = isHide;
        }
    }];
}

- (void)dealloc {
    RELEASE(start);
    RELEASE(images);
    [items removeAllObjects];
    RELEASE(items);
    [positions removeAllObjects];
    RELEASE(positions);
    [animator removeAllBehaviors];
    RELEASE(animator);
    RELEASE(collision);
    RELEASE(itemBehavior);
    [snaps removeAllObjects];
    RELEASE(snaps);
    RELEASE(tapOnStart);
    [super dealloc];
}
@end
