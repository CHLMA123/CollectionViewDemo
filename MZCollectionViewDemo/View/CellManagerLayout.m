//
//  CellManagerLayout.m
//  MZCollectionViewDemo
//
//  Created by MACHUNLEI on 2017/5/6.
//  Copyright © 2017年 MACHUNLEI. All rights reserved.
//

#import "CellManagerLayout.h"

@interface CellManagerLayout ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) NSIndexPath *currentIndexPath; // 当前indexPath
@property (nonatomic, assign) CGPoint movePoint; // 移动的中心点
@property (nonatomic, strong) UIView  *moveView; // 移动的视图

@end

@implementation CellManagerLayout

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureObserver];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configureObserver];
    }
    return self;
}

#pragma mark - 添加观察者
- (void)configureObserver {
    [self addObserver:self forKeyPath:@"collectionView" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"collectionView"]) {
        [self createLongPressGesture];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - 创建手势
- (void)createLongPressGesture{
    if (self.collectionView == nil) {
        return;
    }
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    _longPressGesture.minimumPressDuration = 0.5;
    _longPressGesture.delegate = self;
    [self.collectionView addGestureRecognizer:_longPressGesture];
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    _panGesture.delegate = self;
    [self.collectionView addGestureRecognizer:_panGesture];
    for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gestureRecognizer requireGestureRecognizerToFail:_longPressGesture];
        }
    }
}

- (void)handleGestureBegan:(CGPoint)touchPoint{
    //找到当前点击的cell的位置
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    //判断哪个分区可以被点击并且移动
    if (indexPath == nil) {
        NSLog(@"空");
    }else{
        NSLog(@"Section = %ld,Row = %ld",(long)indexPath.section,(long)indexPath.row);
        self.currentIndexPath = indexPath;
        UICollectionViewCell *targetCell = [self.collectionView cellForItemAtIndexPath:indexPath];
        //得到当前cell的映射(截图)
        self.moveView = [targetCell snapshotViewAfterScreenUpdates:YES];
        //隐藏被点击的cell
        targetCell.hidden = YES;
        //给截图添加上边框，如果不添加的话，截图有一部分是没有边框的，具体原因也没有找到
        self.moveView.layer.borderWidth = 0.5;
        self.moveView.layer.borderColor = [UIColor grayColor].CGColor;
        [self.collectionView addSubview:self.moveView];
        //放大截图
        self.moveView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.moveView.center = targetCell.center;
    }
}

- (void)handleGestureChanged:(CGPoint)touchPoint{
    //更新cell的位置
    self.moveView.center = touchPoint;
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    if (indexPath == nil)  return;
    if (indexPath.section == self.currentIndexPath.section) {
        //通过代理去改变数据源
        if ([self.delegate respondsToSelector:@selector(moveItemAtIndexPath:toIndexPath:)]) {
            [self.delegate updateItemAtIndexPath:self.currentIndexPath toIndexPath:indexPath];
        }
        //移动的方法
        [self.collectionView moveItemAtIndexPath:self.currentIndexPath toIndexPath:indexPath];
        self.currentIndexPath = indexPath;
    }
}

- (void)moveItemIfNeeded:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    if (toIndexPath == nil || [fromIndexPath isEqual:toIndexPath]) return;
    [self.collectionView performBatchUpdates:^{
        //通过代理去改变数据源
        if ([self.delegate respondsToSelector:@selector(moveItemAtIndexPath:toIndexPath:)]) {
            [self.delegate updateItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
        }
        //移动到指定项
        [self.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
        self.currentIndexPath = toIndexPath;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture {
    if (!self.inEditState) {
        [self setInEditState:YES];
    }
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint location = [gesture locationInView:self.collectionView];
            [self handleGestureBegan:location];
        }
            break;
        case UIGestureRecognizerStateChanged: { //手势在变化
            CGPoint location = [gesture locationInView:self.collectionView];
            [self handleGestureChanged:location];
        }
            break;
        case UIGestureRecognizerStateEnded: {  //手势结束
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
            //手势结束后，把截图隐藏，显示出原先的cell
            [UIView animateWithDuration:0.25 animations:^{
                self.moveView.center = cell.center;
            } completion:^(BOOL finished) {
                [self.moveView removeFromSuperview];
                cell.hidden = NO;
                self.moveView = nil;
                self.currentIndexPath = nil;
                [self.collectionView reloadData];
            }];
        }
            break;
        default:
            break;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateChanged: {
            CGPoint panlocation = [pan translationInView:self.collectionView];
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:panlocation];
            // 判断哪个分区可以被点击并且移动
            if (indexPath == nil) {
                NSLog(@"PanGestur: 空");
            }else{
                NSLog(@"PanGestur: Section = %ld,Row = %ld",(long)indexPath.section,(long)indexPath.row);
            }
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            NSLog(@"cancle");
        }
        case UIGestureRecognizerStateEnded:
            break;
            
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([_panGesture isEqual:gestureRecognizer]) {
        if (_longPressGesture.state == 0 || _longPressGesture.state == 5) {
            return NO;
        }
    }else if ([_longPressGesture isEqual:gestureRecognizer]) {
        if (self.collectionView.panGestureRecognizer.state != 0 && self.collectionView.panGestureRecognizer.state != 5) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([_panGesture isEqual:gestureRecognizer]) {
        if (_longPressGesture.state != 0 && _longPressGesture.state != 5) {
            if ([_longPressGesture isEqual:otherGestureRecognizer]) {
                return YES;
            }
            return NO;
        }
    }else if ([_longPressGesture isEqual:gestureRecognizer]) {
        if ([_panGesture isEqual:otherGestureRecognizer]) {
            return YES;
        }
    }else if ([self.collectionView.panGestureRecognizer isEqual:gestureRecognizer]) {
        if (_longPressGesture.state == 0 || _longPressGesture.state == 5) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 处于编辑状态
- (void)setInEditState:(BOOL)inEditState {
    if (_inEditState != inEditState) {
        //通过代理方法改变处于编辑状态的cell
        if (_delegate && [_delegate respondsToSelector:@selector(didChangeEditState:)]) {
            [_delegate didChangeEditState:inEditState];
        }
    }
    _inEditState = inEditState;
}

#pragma mark - 移除观察者
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"collectionView"];
}

@end
