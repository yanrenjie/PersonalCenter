//
//  PersonalCenterViewController.h
//  PersonalCenter
//
//  Created by 颜仁浩 on 2019/10/29.
//  Copyright © 2019 颜仁浩. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PersonalCenterViewController : UIViewController

//默认上下左右放大
@property (nonatomic, assign) BOOL isEnlarge;

@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, readonly, assign) BOOL isBacking;

@end

NS_ASSUME_NONNULL_END
