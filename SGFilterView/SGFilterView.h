//
//  SGFilterView.h
//  SGFilterViewDemo
//
//  Created by BotherBox on 16/6/1.
//  Copyright © 2016年 BotherBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGFilterView;

UIKIT_EXTERN NSInteger const SGFilterViewPreviousRowNone;

@protocol SGFilterViewDataSource <NSObject>
// 每个Tab有几列
- (NSInteger)filterView:(SGFilterView *)filterView numberOfColumnForTab:(NSInteger)tab;
// 第tab里的第column列的数据，previousRow表示该列的前一列选中的row
- (NSArray *)filterView:(SGFilterView *)filterView dataForColumn:(NSInteger)column inTab:(NSInteger)tab previousSelectedRow:(NSInteger)previousRow;

@optional
- (CGFloat)filterView:(SGFilterView *)filterView ratioForMainListInTab:(NSInteger)tab;

@end

@protocol SGFilterViewDelegate <NSObject>

@optional
- (BOOL)filterView:(SGFilterView *)filterView shouldFoldingOnSelectedRow:(NSInteger)row forColumn:(NSInteger)column inTab:(NSInteger)tab;
- (BOOL)filterView:(SGFilterView *)filterView shouldChangeTitleOnSelectRow:(NSInteger)row forColumn:(NSInteger)column inTab:(NSInteger)tab;
- (NSArray *)filterView:(SGFilterView *)filterView defaultSelectedIndexOfRowsInTab:(NSInteger)tab;
@end

@interface SGFilterView : UIControl
@property (nonatomic, strong, readonly) NSArray *titles;

//@property (nonatomic, assign) BOOL shouldChangeTitleOnFoldingBack;
@property (nonatomic, weak) id<SGFilterViewDataSource> dataSource;
@property (nonatomic, weak) id<SGFilterViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles;
@end
