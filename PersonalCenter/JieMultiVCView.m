//
//  JieMultiVCView.m
//  PersonalCenter
//
//  Created by 颜仁浩 on 2019/10/29.
//  Copyright © 2019 颜仁浩. All rights reserved.
//

#import "JieMultiVCView.h"
#import "JieMultiTitleView.h"

@interface JieMultiVCView ()<UIScrollViewDelegate>

@property(nonatomic, strong)JieMultiTitleView *headerView;

@property(nonatomic, strong)UIScrollView *contentScrollView;

@end

@implementation JieMultiVCView

- (instancetype)initWithFrame:(CGRect)frame childVCs:(NSArray *)childVCs parentVC:(UIViewController *)parentVC vcTitles:(NSArray<NSString *> *)vcTitles {
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        
        self.headerView = [[JieMultiTitleView alloc] initWithFrame:CGRectMake(0, 0, self.jie_width, SegmentHeaderViewHeight) titleArray:vcTitles];
        [self addSubview:self.headerView];
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(SegmentHeaderViewHeight);
        }];
        __weak  typeof(self) weakSelf = self;
        weakSelf.headerView.selectedItemHelper = ^(NSUInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.contentScrollView setContentOffset:CGPointMake(index * self.jie_width, 0) animated:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:CurrentSelectedChildViewControllerIndex object:nil userInfo:@{@"selectedPageIndex" : @(index)}];
        };
        
        self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, SegmentHeaderViewHeight, self.jie_width, self.jie_height - SegmentHeaderViewHeight)];
        self.contentScrollView.contentSize = CGSizeMake(self.jie_width * childVCs.count, 0);
        self.contentScrollView.delegate = self;
        self.contentScrollView.showsHorizontalScrollIndicator = NO;
        self.contentScrollView.pagingEnabled = YES;
        self.contentScrollView.bounces = NO;
        [self addSubview:self.contentScrollView];
        
        [childVCs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIViewController *controller = obj;
            [self.contentScrollView addSubview:controller.view];
            controller.view.frame = CGRectMake(idx * self.jie_width, 0, self.jie_width, self.jie_height);
            [parentVC addChildViewController:controller];
            [controller didMoveToParentViewController:parentVC];
        }];
    }
    return self;
}


#pragma mark - Setter
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    self.headerView.selectedIndex =  selectedIndex;
    [[NSNotificationCenter defaultCenter] postNotificationName:CurrentSelectedChildViewControllerIndex object:nil userInfo:@{@"selectedPageIndex" : @(selectedIndex)}];
}


#pragma mark - UIScrollViewDelegate
//增加分页视图左右滑动和外界tableView上下滑动互斥处理
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:IsEnablePersonalCenterVCMainTableViewScroll object:nil userInfo:@{@"canScroll" : @"0"}];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [[NSNotificationCenter defaultCenter] postNotificationName:IsEnablePersonalCenterVCMainTableViewScroll object:nil userInfo:@{@"canScroll" : @"1"}];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger selectedIndex = (NSUInteger)self.contentScrollView.contentOffset.x / self.jie_width;
    [self.headerView changeItemWithTargetIndex:selectedIndex];
    [[NSNotificationCenter defaultCenter] postNotificationName:CurrentSelectedChildViewControllerIndex object:nil userInfo:@{@"selectedPageIndex" : @(selectedIndex)}];
}

@end
