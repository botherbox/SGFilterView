//
//  SGFilterViewUtil.m
//  SGFilterViewDemo
//
//  Created by BotherBox on 16/6/15.
//  Copyright © 2016年 BotherBox. All rights reserved.
//

#import "SGFilterViewUtil.h"

@implementation SGFilterViewUtil
+ (CGFloat)screenScale
{
    static CGFloat screenScale = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        screenScale = [UIScreen mainScreen].scale;
    });
    return screenScale;
}

+ (CGSize)screenSize
{
    static CGSize screenSize = {0, 0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        screenSize = [UIScreen mainScreen].bounds.size;
    });
    return screenSize;
}

+ (CGFloat)fittingPixelLineWidth:(CGFloat)originalWidth
{
    CGFloat scale = [self screenScale];
    scale = MAX(1.0, scale);
    originalWidth = MAX(1.0, originalWidth);
    
    return originalWidth / scale;
}

@end

@implementation UIImage (SGAdd)
+ (UIImage *)resizableImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [theImage resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5)];
}

@end