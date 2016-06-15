//
//  UIButton+SGAdd.h
//  Xueche
//
//  Created by BotherBox on 16/6/1.
//  Copyright © 2016年 harry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (SGAdd)
- (void)sg_addTouchUpInsideActionBlock:(void (^)(UIButton *button))actionBlock;

- (void)sg_exchangeImageAndTitlePosition;
- (void)sg_exchangeImageAndTitlePositionWithPadding:(CGFloat)padding;
@end
