//
//  SGFilterViewUtil.h
//  SGFilterViewDemo
//
//  Created by BotherBox on 16/6/15.
//  Copyright © 2016年 BotherBox. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define RGBHEX(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SGFilterViewUtil : NSObject
// empty
+ (CGFloat)screenScale;
+ (CGSize)screenSize;
+ (CGFloat)fittingPixelLineWidth:(CGFloat)originalWidth;
@end

@interface UIImage (SGAdd)
+ (UIImage *)resizableImageWithColor:(UIColor *)color;
@end