//
//  CellModel.h
//  MZCollectionViewDemo
//
//  Created by MACHUNLEI on 2017/5/6.
//  Copyright © 2017年 MACHUNLEI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellModel : NSObject

//定义cell中的图片；
@property (nonatomic, strong) NSString *cellImage;
//定义cell中的描述文字；
@property (nonatomic, strong) NSString *cellDesc;
//是否是选中状态
@property (nonatomic, assign) BOOL cellSelect;

@end
