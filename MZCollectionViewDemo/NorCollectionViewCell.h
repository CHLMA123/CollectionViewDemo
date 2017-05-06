//
//  NorCollectionViewCell.h
//  MZCollectionViewDemo
//
//  Created by MACHUNLEI on 2017/5/6.
//  Copyright © 2017年 MACHUNLEI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NorCollectionViewCell : UICollectionViewCell
//cell中的图片；
@property(strong,nonatomic) UIImageView *imageView;
//cell中的描述文本；
@property(strong,nonatomic) UILabel *descLabel;
//cell右上角的删除按钮；
@property(nonatomic,strong)UIButton *deleteButton;

@end
