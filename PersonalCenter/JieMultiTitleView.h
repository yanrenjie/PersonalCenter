//
//  JieMultiTitleView.h
//  PersonalCenter
//
//  Created by 颜仁浩 on 2019/10/29.
//  Copyright © 2019 颜仁浩. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JieMultiTitleCollectionCell : UICollectionViewCell

@end

@interface JieMultiTitleView : UIView

@property(nonatomic, assign)NSUInteger defaultSelectedIndex;

@property(nonatomic, assign)NSUInteger selectedIndex;

@property(nonatomic, copy)void (^selectedItemHelper)(NSUInteger index);

- (void)changeItemWithTargetIndex:(NSUInteger)targetIndex;

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray;

@end

NS_ASSUME_NONNULL_END
