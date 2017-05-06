//
//  CellManagerLayout.h
//  MZCollectionViewDemo
//
//  Created by MACHUNLEI on 2017/5/6.
//  Copyright © 2017年 MACHUNLEI. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CellManagerDelegate <NSObject>

/**
 * 更新数据源
 */
- (void)moveItemAtIndexPath:(NSIndexPath *)fromPath toIndexPath:(NSIndexPath *)toPath;

/**
 * 改变编辑状态
 */
- (void)didChangeEditState:(BOOL)inEditState;

@end
@interface CellManagerLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) BOOL inEditState; //检测是否处于编辑状态
@property (nonatomic,   weak) id<CellManagerDelegate> delegate;

@end
