//
//  UIButton+SGAdd.m
//  Xueche
//
//  Created by BotherBox on 16/6/1.
//  Copyright © 2016年 harry. All rights reserved.
//

#import "UIButton+SGAdd.h"
#import <objc/runtime.h>

static const char kTargetKey;

@interface _SGButtonBlockTarget : NSObject
@property (copy, nonatomic) void(^block)(id sender);
- (id)initWithBlock:(void(^)(id))aBlock;
- (void)invoke:(id)sender;
@end

@implementation _SGButtonBlockTarget

- (instancetype)initWithBlock:(void (^)(id))aBlock
{
    self = [super init];
    if (self) {
        _block = [aBlock copy];
    }
    return self;
}

- (void)invoke:(id)sender
{
    if (self.block) {
        self.block(sender);
    }
}

@end

@implementation UIButton (SGAdd)
- (void)sg_addTouchUpInsideActionBlock:(void (^)(UIButton *))actionBlock
{
    _SGButtonBlockTarget *target = [[_SGButtonBlockTarget alloc] initWithBlock:actionBlock];
    objc_setAssociatedObject(self, &kTargetKey, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addTarget:target action:@selector(invoke:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)sg_exchangeImageAndTitlePositionWithPadding:(CGFloat)padding
{
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -(self.imageView.frame.size.width + + padding * 0.5), 0, self.imageView.frame.size.width);
    self.imageEdgeInsets = UIEdgeInsetsMake(0, self.titleLabel.frame.size.width + padding * 0.5, 0, -(self.titleLabel.frame.size.width));
}

- (void)sg_exchangeImageAndTitlePosition
{
    const CGFloat padding = 6.0;
    [self sg_exchangeImageAndTitlePositionWithPadding:padding];
}

@end
