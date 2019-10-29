//
//  PersonalCenterViewController.m
//  PersonalCenter
//
//  Created by 颜仁浩 on 2019/10/29.
//  Copyright © 2019 颜仁浩. All rights reserved.
//

#import "PersonalCenterViewController.h"
#import "ChildOneViewController.h"
#import "ChildTwoViewController.h"
#import "ChildThreeViewController.h"
#import "JieMultiVCView.h"
#import "JieTableView.h"

@interface PersonalCenterViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property(nonatomic, strong)JieTableView *mainTableView;
@property(nonatomic, strong)JieMultiVCView *segmentView;
@property(nonatomic, strong)UIView *naviView;
@property(nonatomic, strong)UIImageView *headerImageView;
@property(nonatomic, strong)UIView *headerContentView;
@property(nonatomic, strong)UIImageView *avatarImageView;
@property(nonatomic, strong)UILabel *nickNameLabel;
/** mainTableView是否可以滚动 */
@property (nonatomic, assign) BOOL canScroll;
/** segmentHeaderView到达顶部, mainTableView不能移动 */
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;
/** segmentHeaderView离开顶部,childViewController的滚动视图不能移动 */
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;
/** 是否正在pop */
@property (nonatomic, assign) BOOL isBacking;

@end

@implementation PersonalCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人中心";
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //如果使用自定义的按钮去替换系统默认返回按钮，会出现滑动返回手势失效的情况
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self setupUI];
    //注册允许外层tableView滚动通知-解决和分页视图的上下滑动冲突问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:@"leaveTop" object:nil];
    //分页的scrollView左右滑动的时候禁止mainTableView滑动，停止滑动的时候允许mainTableView滑动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:IsEnablePersonalCenterVCMainTableViewScroll object:nil];
}


- (void)setupUI {
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.naviView];
    [self.headerImageView addSubview:self.headerContentView];
    [self.headerContentView addSubview:self.avatarImageView];
    [self.headerContentView addSubview:self.nickNameLabel];
    [self.mainTableView addSubview:self.headerImageView];
    
    [self.headerContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.centerX.mas_equalTo(self.headerImageView);
        make.width.mas_equalTo(ScreenWidth);
        make.height.mas_equalTo(HeaderImageViewHeight);
    }];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headerContentView);
        make.size.mas_equalTo(CGSizeMake(80, 80));
        make.bottom.mas_equalTo(-70);
    }];
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headerContentView);
        make.width.mas_lessThanOrEqualTo(200);
        make.bottom.mas_equalTo(-40);
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.naviView.hidden = NO;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isBacking = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:PersonalCenterVCBackingStatus object:nil userInfo:@{@"isBacking" : @(self.isBacking)}];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isBacking = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:PersonalCenterVCBackingStatus object:nil userInfo:@{@"isBacking" : @(self.isBacking)}];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.naviView.hidden = YES;
}


- (void)backAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark -  Notification
- (void)acceptMsg:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    if ([notification.name isEqualToString:@"leaveTop"]) {
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.canScroll = YES;
        }
    } else if ([notification.name isEqualToString:IsEnablePersonalCenterVCMainTableViewScroll]) {
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.mainTableView.scrollEnabled = YES;
        }else if([canScroll isEqualToString:@"0"]) {
            self.mainTableView.scrollEnabled = NO;
        }
    }
}

#pragma mark - UiScrollViewDelegate
/**
 * 处理联动
 * 因为要实现下拉头部放大的问题，tableView设置了contentInset，所以试图刚加载的时候会调用一遍这个方法，所以要做一些特殊处理，
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.mainTableView) {
        //当前y轴偏移量
        CGFloat yOffset  = scrollView.contentOffset.y;
        //临界点偏移量(吸顶临界点)
        CGFloat tabyOffset = [self.mainTableView rectForSection:0].origin.y - k_Height_StatusBar - k_Height_NavContentBar;
        
        //第一部分: 更改导航栏的背景图的透明度
        CGFloat alpha = 0;
        if (-yOffset <= k_Height_StatusBar + k_Height_NavContentBar) {
            alpha = 1;
        } else if ((-yOffset > k_Height_StatusBar + k_Height_NavContentBar) && -yOffset < HeaderImageViewHeight) {
            alpha = (HeaderImageViewHeight + yOffset) / (HeaderImageViewHeight - k_Height_StatusBar - k_Height_NavContentBar);
        }else {
            alpha = 0;
        }
        self.naviView.backgroundColor = RGBAColor(255, 126, 15, alpha);
        
        //第二部分：
        //利用contentOffset处理内外层scrollView的滑动冲突问题
        if (yOffset >= tabyOffset) {
            scrollView.contentOffset = CGPointMake(0, tabyOffset);
            _isTopIsCanNotMoveTabView = YES;
        }else{
            _isTopIsCanNotMoveTabView = NO;
        }
        
        _isTopIsCanNotMoveTabViewPre = !_isTopIsCanNotMoveTabView;
        
        if (!_isTopIsCanNotMoveTabViewPre) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goTop" object:nil userInfo:@{@"canScroll":@"1"}];
            _canScroll = NO;
        } else{
            if (!_canScroll) {
                _mainTableView.contentOffset = CGPointMake(0, tabyOffset);
            }
        }
        
        //第三部分：
        /**
         * 处理头部自定义背景视图 (如: 下拉放大)
         * 图片会被拉伸多出状态栏的高度
         */
        if(yOffset <= -HeaderImageViewHeight) {
            if (_isEnlarge) {
                CGRect f = self.headerImageView.frame;
                //改变HeadImageView的frame
                //上下放大
                f.origin.y = yOffset;
                f.size.height = -yOffset;
                //左右放大
                f.origin.x = (yOffset * ScreenWidth / HeaderImageViewHeight + ScreenWidth) / 2;
                f.size.width = -yOffset * ScreenWidth / HeaderImageViewHeight;
                //改变头部视图的frame
                self.headerImageView.frame = f;
            }else{
                scrollView.bounces = NO;
            }
        }else {
            scrollView.bounces = YES;
        }
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ScreenHeight - k_Height_StatusBar - k_Height_NavContentBar;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:self.setPageViewControllers];
    return cell;
}

#pragma mark - Lazy
- (UIView *)naviView {
    if (!_naviView) {
        _naviView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, k_Height_StatusBar + k_Height_NavContentBar)];
        _naviView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        //添加返回按钮
        UIButton *backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [backButton setImage:[UIImage imageNamed:@"back"] forState:(UIControlStateNormal)];
        backButton.frame = CGRectMake(5, 8 + k_Height_StatusBar, 28, 25);
        backButton.adjustsImageWhenHighlighted = YES;
        [backButton addTarget:self action:@selector(backAction) forControlEvents:(UIControlEventTouchUpInside)];
        [_naviView addSubview:backButton];
    }
    return _naviView;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        //⚠️这里的属性初始化一定要放在mainTableView.contentInset的设置滚动之前, 不然首次进来视图就会偏移到临界位置，contentInset会调用scrollViewDidScroll这个方法。
        //初始化变量
        self.canScroll = YES;
        self.isTopIsCanNotMoveTabView = NO;
        
        self.mainTableView = [[JieTableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.showsVerticalScrollIndicator = NO;
        //注意：这里不能使用动态高度_headimageHeight, 不然tableView会往下移，在iphone X下，头部不放大的时候，上方依然会有白色空白
        _mainTableView.contentInset = UIEdgeInsetsMake(HeaderImageViewHeight, 0, 0, 0);//内容视图开始正常显示的坐标为(0, HeaderImageViewHeight)
    }
    return _mainTableView;
}

- (UIView *)headerContentView {
    if (!_headerContentView) {
        _headerContentView = [[UIView alloc]init];
        _headerContentView.backgroundColor = [UIColor clearColor];
    }
    return _headerContentView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.image = [UIImage imageNamed:@"center_avatar.jpeg"];
        _avatarImageView.userInteractionEnabled = YES;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.layer.borderWidth = 1;
        _avatarImageView.layer.borderColor = RGBAColor(255, 253, 253, 1).CGColor;
        _avatarImageView.layer.cornerRadius = 40;
    }
    return _avatarImageView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = [UIFont systemFontOfSize:16];
        _nickNameLabel.textColor = [UIColor whiteColor];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
        _nickNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _nickNameLabel.numberOfLines = 0;
        _nickNameLabel.text = @"撒哈拉下雪了";
    }
    return _nickNameLabel;
}

- (UIImageView *)headerImageView {
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"center_bg.jpg"]];
        _headerImageView.backgroundColor = [UIColor greenColor];
        _headerImageView.userInteractionEnabled = YES;
        _headerImageView.frame = CGRectMake(0, -HeaderImageViewHeight, ScreenWidth, HeaderImageViewHeight);
    }
    return _headerImageView;
}

/*
 * 这里可以设置替换你喜欢的segmentView
 */
- (UIView *)setPageViewControllers {
    if (!_segmentView) {
        //设置子控制器
        ChildOneViewController *firstVC  = [[ChildOneViewController alloc] init];
        ChildTwoViewController *secondVC = [[ChildTwoViewController alloc] init];
        ChildThreeViewController *thirdVC  = [[ChildThreeViewController alloc] init];
        ChildOneViewController *fourthVC  = [[ChildOneViewController alloc] init];
        ChildTwoViewController *fifthVC = [[ChildTwoViewController alloc] init];
        ChildThreeViewController *sixthVC  = [[ChildThreeViewController alloc] init];
        ChildOneViewController *seventhVC  = [[ChildOneViewController alloc] init];
        ChildTwoViewController *eighthVC = [[ChildTwoViewController alloc] init];
        ChildThreeViewController *ninthVC  = [[ChildThreeViewController alloc] init];
        NSArray *controllers = @[firstVC, secondVC, thirdVC, fourthVC, fifthVC, sixthVC, seventhVC, eighthVC, ninthVC];
        NSArray *titleArray = @[@"华盛顿", @"夏威夷", @"拉斯维加斯", @"纽约", @"西雅图", @"底特律", @"费城", @"旧金山", @"芝加哥"];
        JieMultiVCView *segmentView = [[JieMultiVCView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - (k_Height_StatusBar) - (k_Height_NavContentBar)) childVCs:controllers parentVC:self vcTitles:titleArray];
        //注意：不能通过初始化方法传递selectedIndex的初始值，因为内部使用的是Masonry布局的方式, 否则设置selectedIndex不起作用
        segmentView.selectedIndex = self.selectedIndex;
        _segmentView = segmentView;
    }
    return _segmentView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
