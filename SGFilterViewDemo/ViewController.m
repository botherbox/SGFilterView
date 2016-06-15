//
//  ViewController.m
//  SGFilterViewDemo
//
//  Created by BotherBox on 16/6/15.
//  Copyright © 2016年 BotherBox. All rights reserved.
//

#import "ViewController.h"
#import "SGFilterView.h"

@interface ViewController () <SGFilterViewDataSource, SGFilterViewDelegate>
@property (nonatomic, strong) NSArray *pData;
@property (nonatomic, strong) NSArray *cData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.pData= @[@"北京", @"上海", @"河北"];
    self.cData = @[
                   @[@"海淀区", @"朝阳区", @"西城区", @"丰台区"],
                   @[@"浦东区", @"徐汇区", @"虹口区"],
                   @[@"石家庄市", @"邯郸市", @"保定市"]
                   ];
    
    SGFilterView *filter = [[SGFilterView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 44) titles:@[@"地区", @"品牌", @"离我最近"]];
    filter.dataSource = self;
    filter.delegate = self;
    [self.view addSubview:filter];
}

#pragma mark - SGFilterViewDelegate
- (BOOL)filterView:(SGFilterView *)filterView shouldFoldingOnSelectedRow:(NSInteger)row forColumn:(NSInteger)column inTab:(NSInteger)tab
{
    BOOL foldback = YES;
    if (tab == 0) { // 地区
        if (column == 0) {
            foldback = NO; // 不收回
        }
        
    } else {
        foldback = YES;
        if (tab == 1) { // 所有品牌
            
        } else if (tab == 2) // 其他条件
        {
            
        }
        
    }
    
    
    
    return foldback;
}

- (BOOL)filterView:(SGFilterView *)filterView shouldChangeTitleOnSelectRow:(NSInteger)row forColumn:(NSInteger)column inTab:(NSInteger)tab
{
    return YES;
}

#pragma mark - SGFilterViewDataSource
- (NSInteger)filterView:(SGFilterView *)filterView numberOfColumnForTab:(NSInteger)tab
{
    if (tab == 0) {
        return 2;
    }
    return 1;
}

- (NSArray *)filterView:(SGFilterView *)filterView dataForColumn:(NSInteger)column inTab:(NSInteger)tab previousSelectedRow:(NSInteger)previousRow
{
    if (tab == 0) {
        if (column == 0) {
            return self.pData;
        } else if (column == 1) {
            return self.cData[previousRow];
        }
    } else if (tab == 1)
    {
        return @[@"所有品牌", @"保利国际影院", @"星美国际影城", @"中影国际影城"];
    } else if (tab == 2)
    {
        return @[@"离我最近", @"好评优先", @"价格最低"];
    }
    return nil;
}

- (CGFloat)filterView:(SGFilterView *)filterView ratioForMainListInTab:(NSInteger)index
{
    if (index == 0) {
        return 1.0/3;
    }
    return 1.0;
}

@end
