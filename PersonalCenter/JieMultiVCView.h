//
//  JieMultiVCView.h
//  PersonalCenter
//
//  Created by 颜仁浩 on 2019/10/29.
//  Copyright © 2019 颜仁浩. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JieMultiVCView : UIView

@property(nonatomic, assign)NSInteger selectedIndex;

- (instancetype)initWithFrame:(CGRect)frame childVCs:(NSArray *)childVCs parentVC:(UIViewController *)parentVC vcTitles:(NSArray<NSString *> *)vcTitles;

@end

NS_ASSUME_NONNULL_END
