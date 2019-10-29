//
//  JieMultiViewController.m
//  PersonalCenter
//
//  Created by 颜仁浩 on 2019/10/29.
//  Copyright © 2019 颜仁浩. All rights reserved.
//

#import "JieMultiViewController.h"

@interface JieMultiViewController ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, assign)BOOL canScroll;
@property(nonatomic, strong)NSNumber *selectedPageIndex;

@end

@implementation JieMultiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //子控制器视图到达顶部的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"goTop" object:nil];
    //子控制器视图离开顶部的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"leaveTop" object:nil];
    //切换分页选项的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:CurrentSelectedChildViewControllerIndex object:nil];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Notification
- (void)acceptMsg:(NSNotification *)notification {
    NSString *notificationName = notification.name;
    if ([notificationName isEqualToString:@"goTop"]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.canScroll = YES;
            self.scrollView.showsVerticalScrollIndicator = YES;
        } else {
            self.canScroll = NO;
        }
    } else if ([notificationName isEqualToString:@"leaveTop"]){
        self.canScroll = NO;
        self.scrollView.contentOffset = CGPointZero;
        self.scrollView.showsVerticalScrollIndicator = NO;
    } else if ([notificationName isEqualToString:CurrentSelectedChildViewControllerIndex]) {
        NSDictionary *userInfo = notification.userInfo;
        self.selectedPageIndex = userInfo[@"selectedPageIndex"];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.canScroll) {
        [scrollView setContentOffset:CGPointZero];
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"leaveTop" object:nil userInfo:@{@"canScroll":@"1"}];
    }
    self.scrollView = scrollView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.selectedPageIndex isEqualToNumber:@0]) {
        return YES;
    }
    return NO;
}

@end
