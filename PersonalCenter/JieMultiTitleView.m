//
//  JieMultiTitleView.m
//  PersonalCenter
//
//  Created by 颜仁浩 on 2019/10/29.
//  Copyright © 2019 颜仁浩. All rights reserved.
//

#import "JieMultiTitleView.h"

#define kWidth          self.frame.size.width
#define NORMAL_FONT     [UIFont systemFontOfSize:18]
#define NORMAL_COLOR    [UIColor blackColor]
#define SELECTED_COLOR  [UIColor orangeColor]

@interface JieMultiTitleCollectionCell ()

@property(nonatomic, strong)UILabel *titleLabel;

@end

#pragma mark - 标题label cell
@implementation JieMultiTitleCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return self;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = NORMAL_FONT;
        _titleLabel.textColor = NORMAL_COLOR;
    }
    return _titleLabel;
}

@end



#pragma mark - 整体
@interface JieMultiTitleView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, copy)NSArray *titleArray;
@property(nonatomic, strong)UIView *moveLine;
@property(nonatomic, strong)UIView *separator;
@property(nonatomic, assign)BOOL selectedCellExist;

@end

#pragma mark - 常量
static CGFloat const MoveLineHeight = 2;
static CGFloat const SeparatorHeight = 0.5;
static CGFloat const CellSpacing = 15;
static CGFloat const CollectionViewHeight = SegmentHeaderViewHeight - SeparatorHeight;

@implementation JieMultiTitleView

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray {
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
        self.titleArray = titleArray;
        self.selectedIndex = 0;
    }
    return self;
}


#pragma mark - 更改
- (void)changeItemWithTargetIndex:(NSUInteger)targetIndex {
    if (_selectedIndex == targetIndex) {
        return;
    }
    
    JieMultiTitleCollectionCell *selectedCell = [self getCell:_selectedIndex];
    if (selectedCell) {
        selectedCell.titleLabel.textColor = NORMAL_COLOR;
    }
    JieMultiTitleCollectionCell *targetCell = [self getCell:targetIndex];
    if (targetCell) {
        targetCell.titleLabel.textColor = SELECTED_COLOR;
    }
    
    _selectedIndex = targetIndex;
    
    [self layoutAndScrollToSelectedItem];
}


#pragma mark - 布局
- (void)setupSubViews {
    [self addSubview:self.collectionView];
    [self.collectionView addSubview:self.moveLine];
    [self addSubview:self.separator];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(CollectionViewHeight);
    }];
    [self.moveLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(CollectionViewHeight - MoveLineHeight);
        make.height.mas_equalTo(MoveLineHeight);
    }];
    [self.separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(SeparatorHeight);
    }];
}


// 创建cell
- (JieMultiTitleCollectionCell *)getCell:(NSUInteger)Index {
    return (JieMultiTitleCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:Index inSection:0]];
}


//  布局
- (void)layoutAndScrollToSelectedItem {
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView setNeedsLayout];
    [self.collectionView layoutIfNeeded];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

    if (self.selectedItemHelper) {
        self.selectedItemHelper(_selectedIndex);
    }
    
    JieMultiTitleCollectionCell *selectedCell = [self getCell:_selectedIndex];
    if (selectedCell) {
        self.selectedCellExist = YES;
        [self updateMoveLineLocation];
    } else {
        self.selectedCellExist = NO;
    //这种情况下updateMoveLineLocation将在self.collectionView滚动结束后执行（代理方法scrollViewDidEndScrollingAnimation）
    }
}


// 滑动线条
- (void)setupMoveLineDefaultLocation {
    CGFloat firstCellWidth = [self getWidthWithContent:self.titleArray[0]];
    [self.moveLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(firstCellWidth);
        make.left.mas_equalTo(CellSpacing);
    }];
}


// 移动划线的位置
- (void)updateMoveLineLocation {
    JieMultiTitleCollectionCell *cell = [self getCell:_selectedIndex];
    [UIView animateWithDuration:0.25 animations:^{
        [self.moveLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(CollectionViewHeight - MoveLineHeight);
            make.height.mas_equalTo(MoveLineHeight);
            make.width.centerX.equalTo(cell.titleLabel);
        }];
        [self.collectionView setNeedsLayout];
        [self.collectionView layoutIfNeeded];
    }];
}


// 获取标题文本的宽度
- (CGFloat)getWidthWithContent:(NSString *)content {
    CGRect rect = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, CollectionViewHeight)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:@{NSFontAttributeName:NORMAL_FONT}
                                        context:nil
                   ];
    return ceilf(rect.size.width);
}



#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = [self getWidthWithContent:self.titleArray[indexPath.row]];
    return CGSizeMake(itemWidth, SegmentHeaderViewHeight - 1);
}


#pragma mark -UICollectionViewDataSource  &&   UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titleArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JieMultiTitleCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JieMultiTitleCollectionCell" forIndexPath:indexPath];
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.titleLabel.textColor = _selectedIndex == indexPath.row ? SELECTED_COLOR : NORMAL_COLOR;
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self changeItemWithTargetIndex:indexPath.row];
}


// 滚动动画结束更新滑块位置
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (!self.selectedCellExist) {
        [self updateMoveLineLocation];
    }
}


#pragma mark - 重写set方法
- (void)setTitleArray:(NSArray *)titleArray {
    _titleArray = titleArray.copy;
    [self.collectionView reloadData];
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (self.titleArray == nil && self.titleArray.count == 0) {
        return;
    }
    
    if (selectedIndex >= self.titleArray.count) {
        _selectedIndex = self.titleArray.count - 1;
    } else {
        _selectedIndex = selectedIndex;
    }
    
    //设置初始选中位置
    if (_selectedIndex == 0) {
        [self setupMoveLineDefaultLocation];
    } else {
        [self layoutAndScrollToSelectedItem];
    }
}


#pragma mark - 懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = CellSpacing;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, CellSpacing, 0, CellSpacing);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kWidth, CollectionViewHeight) collectionViewLayout:flowLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor yellowColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = NO;
        [_collectionView registerClass:[JieMultiTitleCollectionCell class] forCellWithReuseIdentifier:@"JieMultiTitleCollectionCell"];
    }
    return _collectionView;
}

- (UIView *)moveLine {
    if (!_moveLine) {
        _moveLine = [[UIView alloc] init];
        _moveLine.backgroundColor = [UIColor orangeColor];
    }
    return _moveLine;
}


- (UIView *)separator {
    if (!_separator) {
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = [UIColor lightGrayColor];
    }
    return _separator;
}

@end
