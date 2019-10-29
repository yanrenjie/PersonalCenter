//
//  ViewController.m
//  PersonalCenter
//
//  Created by 颜仁浩 on 2019/10/28.
//  Copyright © 2019 颜仁浩. All rights reserved.
//

#import "ViewController.h"
#import "PersonalCenterViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    PersonalCenterViewController *personVC = [[PersonalCenterViewController alloc] init];
    [self.navigationController pushViewController:personVC animated:YES];
}

@end
