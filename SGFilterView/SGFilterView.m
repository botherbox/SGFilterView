//
//  SGFilterView.m
//  SGFilterViewDemo
//
//  Created by BotherBox on 16/6/1.
//  Copyright © 2016年 BotherBox. All rights reserved.
//

#import "SGFilterView.h"
#import "UIButton+SGAdd.h"
#import "SGFilterViewUtil.h"

#pragma mark - Private <_SGFilterCell>
@interface _SGFilterViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation _SGFilterViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = RGBHEX(0xf5f5f5);
        self.backgroundColor = RGBHEX(0xf5f5f5);
        
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage resizableImageWithColor:RGBHEX(0xeaeaea)]];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        // 内容
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = RGBHEX(0x333333);
        self.titleLabel.font = [UIFont systemFontOfSize:15.0];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;

        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        // top
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
        [self.contentView addConstraint:constraint];
        
        // right
        constraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f];
        [self.contentView addConstraint:constraint];
        
        // bottom
        constraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
        [self.contentView addConstraint:constraint];
        
        // left
        constraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f];
        [self.contentView addConstraint:constraint];
        
        // 分割线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = RGBHEX(0xdddddd);
        [self.contentView addSubview:lineView];
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint *lineCons = [NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f];
        [self.contentView addConstraint:lineCons];
        
        lineCons = [NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
        [self.contentView addConstraint:lineCons];
        
        lineCons = [NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f];
        [self.contentView addConstraint:lineCons];
        
        lineCons = [NSLayoutConstraint constraintWithItem:lineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:1.0f];
        [lineView addConstraint:lineCons];
    }
    return self;
}

@end

#define kAnimationDuration 0.3

NSInteger const SGFilterViewPreviousRowNone = -1;

@interface SGFilterView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
// Data
@property (nonatomic, strong, readwrite) NSArray *titles;

// View
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *separatorLine;
@property (nonatomic, strong) UITableView *leftTable; // main
@property (nonatomic, strong) UITableView *rightTable;
// Assist
@property (nonatomic, strong) NSMutableArray *tabButtons;
@property (nonatomic, assign) NSInteger currentTabIdx;
@property (nonatomic, strong) NSArray *mainDataSource;
@property (nonatomic, strong) NSArray *subDataSource;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *selectedRows;

@property (nonatomic, assign) NSInteger currentNumberOfCols;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) NSInteger lastExpandedTab;
@end

@implementation SGFilterView
{
    CGFloat _originalHeight;
}

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titles = titles;
        
        self.backgroundColor = [UIColor clearColor];
        CGFloat width = CGRectGetWidth(frame);
        CGFloat height = CGRectGetHeight(frame);
        _originalHeight = height;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFoldingBack:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
        // 按钮
        NSUInteger btnCount = titles.count;
        CGFloat btnw = width / btnCount;
        CGFloat btnh = height;
        _tabButtons = [NSMutableArray arrayWithCapacity:btnCount];
        _selectedRows = [NSMutableArray arrayWithCapacity:btnCount];
        NSMutableArray *separatorLines = [NSMutableArray arrayWithCapacity:btnCount-1];
        for (NSInteger i = 0;i < btnCount;++i)
        {
            [_selectedRows addObject:[NSMutableArray arrayWithArray:@[@0, @(-1)]]];
            
            NSString *btnTitle = titles[i];
            
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*btnw, 0, btnw, btnh)];
            [btn setTitle:btnTitle forState:UIControlStateNormal];
            [btn setTitleColor:RGBHEX(0x999999) forState:UIControlStateNormal];
            [btn setTitleColor:RGBHEX(0xffffff) forState:UIControlStateHighlighted];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [btn setBackgroundImage:[UIImage resizableImageWithColor:RGBHEX(0xffffff)]
                           forState:UIControlStateNormal];
            [_tabButtons addObject:btn];
            [btn setImage:[UIImage imageNamed:@"SGFilterView.bundle/indicator@2x.png"] forState:UIControlStateNormal];
            [btn sg_exchangeImageAndTitlePosition];
            [self addSubview:btn];
            
            [btn addTarget:self
                    action:@selector(clickBtn:)
          forControlEvents:UIControlEventTouchUpInside];
            
            if (i < btnCount) {
                // 竖分割线
                UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame), 8, [SGFilterViewUtil fittingPixelLineWidth:0.5], height-16)];
                lineV.backgroundColor = RGBHEX(0xdddddd);
                [self addSubview:lineV];
                [separatorLines addObject:lineV];
            }
        }
        
        [separatorLines enumerateObjectsUsingBlock:^(UIView *line, NSUInteger idx, BOOL * _Nonnull stop) {
            [self bringSubviewToFront:line];
        }];
        
        // 底部分割线
        CGFloat lineHeight = [SGFilterViewUtil fittingPixelLineWidth:0.5];
        UIView *lineVB = [[UIView alloc] initWithFrame:CGRectMake(0, height-lineHeight, width, lineHeight)];
        lineVB.backgroundColor = RGBHEX(0xdddddd);
        [self addSubview:lineVB];
        
        // 内容区域
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, height, width, 0)];
        _contentView.userInteractionEnabled = YES;
        _contentView.backgroundColor = RGBHEX(0xeaeaea);
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
        
        [_contentView addSubview:self.leftTable];
        [_contentView addSubview:self.rightTable];
        // 分割线
        self.separatorLine = [[UIView alloc] initWithFrame:CGRectZero];
        self.separatorLine.backgroundColor = RGBHEX(0xdddddd);
        [self.contentView addSubview:self.separatorLine];
    }
    return self;
}

- (void)clickBtn:(UIButton *)button
{
    [self.tabButtons[self.lastExpandedTab] setSelected:NO];
    NSInteger tabIdx = [self.tabButtons indexOfObject:button];
    if (self.lastExpandedTab == tabIdx && self.isExpanded) {
        button.selected = NO;
        [self foldingBack];
        return;
    }
    
    button.selected = !button.selected;
    
    // 保存第tabIdx标签里的第column列选中的row
    NSArray *selectedRowsInTab = self.selectedRows[tabIdx];
    NSInteger mainSelectedRow = [selectedRowsInTab[0] integerValue];
    NSInteger subSelectedRow = [selectedRowsInTab[1] integerValue];
    
    self.mainDataSource = [self.dataSource filterView:self dataForColumn:0 inTab:tabIdx previousSelectedRow:SGFilterViewPreviousRowNone];
    NSInteger numberOfCols = [self.dataSource filterView:self numberOfColumnForTab:tabIdx];
    self.currentNumberOfCols = numberOfCols;
    
    // default selected row
    NSInteger mainDefaultRow = -1;
    NSInteger subDefaultRow = -1;
    if ([self.delegate respondsToSelector:@selector(filterView:defaultSelectedIndexOfRowsInTab:)]) {
        NSArray *defaultSelectedRows = [self.delegate filterView:self defaultSelectedIndexOfRowsInTab:tabIdx];
        NSParameterAssert(defaultSelectedRows.count > 0);
        mainDefaultRow = [defaultSelectedRows[0] integerValue];
        if (numberOfCols > 1) {
            NSParameterAssert(defaultSelectedRows.count > 1);
            subDefaultRow = [defaultSelectedRows[1] integerValue];
        }
    }
    
    CGFloat ratio = 1.0;
    NSUInteger rowCount = MIN(self.mainDataSource.count, 6); // 最多显示6条
    CGFloat height = rowCount*44;
    if (numberOfCols == 2) {
        
        // Data
        self.subDataSource = [self.dataSource filterView:self dataForColumn:1 inTab:tabIdx previousSelectedRow:mainSelectedRow];
        NSUInteger subRowCount = MIN(self.subDataSource.count, 6);
        rowCount = MAX(rowCount, subRowCount);
        height = rowCount*44; // 44 is row height
        
        // View
        ratio = 0.5;
        if ([self.dataSource respondsToSelector:@selector(filterView:ratioForMainListInTab:)]) {
            ratio = [self.dataSource filterView:self ratioForMainListInTab:tabIdx];
            ratio = MAX(0.1, ratio);
            ratio = MIN(0.9, ratio);
        }
        CGFloat mainWidth = CGRectGetWidth(self.frame) * ratio;
        self.leftTable.frame = CGRectMake(0, 0, mainWidth, height);
        self.rightTable.frame = CGRectMake(CGRectGetMaxX(self.leftTable.frame), 0, CGRectGetWidth(self.frame) - mainWidth, height);
        self.rightTable.hidden = NO;
        self.separatorLine.hidden = NO;
//        [self.contentView bringSubviewToFront:self.rightTable];
        
        self.separatorLine.frame = CGRectMake(CGRectGetMaxX(self.leftTable.frame), 0, [SGFilterViewUtil fittingPixelLineWidth:0.5], height);
    } else {
        self.subDataSource = nil;
        self.leftTable.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), height);
//        [self.contentView bringSubviewToFront:self.leftTable];
        self.rightTable.hidden = YES;
        self.separatorLine.hidden = YES;
    }
    
    [self.leftTable reloadData];
    [self.rightTable reloadData];
    
    [self.leftTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:mainSelectedRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    if (subSelectedRow > -1 && self.subDataSource.count > subSelectedRow) {
        [self.rightTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:subSelectedRow inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    [self expandingToHeight:height];
    
    self.lastExpandedTab = tabIdx;
}

/// 展开
- (void)expandingToHeight:(CGFloat)destHeight
{
    [self rotateTabArrowIndicator:nil];
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height = [SGFilterViewUtil screenSize].height - _originalHeight;
    self.frame = selfFrame;
    
    CGFloat height = destHeight;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    CGRect contentFrame = self.contentView.frame;
    contentFrame.size.height = height;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.contentView.frame = contentFrame;
    } completion:^(BOOL finished) {
        self.isExpanded = YES;
    }];
}

/// 收起
- (void)foldingBack
{
    [self rotateTabArrowIndicator:nil];
    CGRect contentFrame = self.contentView.frame;
    contentFrame.size.height = 0;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        self.contentView.frame = contentFrame;
    } completion:^(BOOL finished) {
        self.isExpanded = NO;
        CGRect selfFrame = self.frame;
        selfFrame.size.height = _originalHeight;
        self.frame = selfFrame;
    }];
}

- (void)rotateTabArrowIndicator:(UIButton *)tabBtn
{
    [self.tabButtons enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat angle = btn.selected ? M_PI : 0;
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [btn.imageView setTransform:transform];
        }];
    }];
}

- (void)changeTabTitle:(NSString *)title
{
    UIButton *btn = self.tabButtons[self.lastExpandedTab];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn sg_exchangeImageAndTitlePosition];
}

- (void)tapFoldingBack:(UITapGestureRecognizer *)tapGes
{
    [self.tabButtons[self.lastExpandedTab] setSelected:NO];
    [self foldingBack];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UITapGestureRecognizer *)tapGes
{
    CGPoint pos = [tapGes locationInView:self];
    if (CGRectContainsPoint(CGRectMake(0, CGRectGetMaxY(self.contentView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)), pos)) {
        return YES;
    }
    return NO;
}

#pragma mark - Table Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.leftTable) {
        return self.mainDataSource.count;
    } else if (tableView == self.rightTable)
    {
        return self.subDataSource.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _SGFilterViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"_SGFilterViewCell"];
    if (cell == nil) {
        cell = [[_SGFilterViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"_SGFilterViewCell"];
    }
    
    if (tableView == self.leftTable) {
        cell.titleLabel.text = self.mainDataSource[indexPath.row];
    } else if (tableView == self.rightTable) {
        cell.titleLabel.text = self.subDataSource[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isFold = YES;
    bool shouldChangeTitle = YES;
    NSMutableArray *selectedRowsInTab = self.selectedRows[self.lastExpandedTab];
//    NSInteger numberOfCols = [self.dataSource filterView:self numberOfColumnForTab:self.lastExpandedTab];
    if (tableView == self.leftTable) {
        [selectedRowsInTab replaceObjectAtIndex:0 withObject:@(indexPath.row)];
        [selectedRowsInTab replaceObjectAtIndex:1 withObject:@(-1)];
        
        if ([self.delegate respondsToSelector:@selector(filterView:shouldFoldingOnSelectedRow:forColumn:inTab:)]) {
            isFold = [self.delegate filterView:self shouldFoldingOnSelectedRow:indexPath.row forColumn:0 inTab:self.lastExpandedTab];
        }
        if ([self.delegate respondsToSelector:@selector(filterView:shouldChangeTitleOnSelectRow:forColumn:inTab:)]) {
            shouldChangeTitle = [self.delegate filterView:self shouldChangeTitleOnSelectRow:indexPath.row forColumn:0 inTab:self.lastExpandedTab];
        }
        
        // TODO: 这里没有依照代理方法，而是强制不收回也不改变title
        if (self.currentNumberOfCols > 1) {
            isFold = shouldChangeTitle = NO;
            self.subDataSource = [self.dataSource filterView:self dataForColumn:1 inTab:self.lastExpandedTab previousSelectedRow:indexPath.row];
            [self.rightTable reloadData];
            [self.rightTable scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            return;
        }
    } else if (tableView == self.rightTable)
    {
        [selectedRowsInTab replaceObjectAtIndex:1 withObject:@(indexPath.row)];
        if ([self.delegate respondsToSelector:@selector(filterView:shouldFoldingOnSelectedRow:forColumn:inTab:)]) {
            isFold = [self.delegate filterView:self shouldFoldingOnSelectedRow:indexPath.row forColumn:1 inTab:self.lastExpandedTab];
        }
        if ([self.delegate respondsToSelector:@selector(filterView:shouldChangeTitleOnSelectRow:forColumn:inTab:)]) {
            shouldChangeTitle = [self.delegate filterView:self shouldChangeTitleOnSelectRow:indexPath.row forColumn:1 inTab:self.lastExpandedTab];
        }
    }
    
    if (isFold) {
        [self.tabButtons[self.lastExpandedTab] setSelected:NO];
        [self foldingBack];
    }
    if (shouldChangeTitle) {
        _SGFilterViewCell *cell = (_SGFilterViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [self changeTabTitle:cell.titleLabel.text];
    }
}

#pragma mark - Lazy load
- (UITableView *)leftTable
{
    if (_leftTable) {
        return _leftTable;
    }
    
    _leftTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    _leftTable.dataSource = self;
    _leftTable.delegate = self;
    _leftTable.rowHeight = 44.0;
    _leftTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    return _leftTable;
}

- (UITableView *)rightTable
{
    if (_rightTable) {
        return _rightTable;
    }
    
    _rightTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    _rightTable.rowHeight = 44.0;
    _rightTable.dataSource = self;
    _rightTable.delegate = self;
    _rightTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    return _rightTable;
}

@end
