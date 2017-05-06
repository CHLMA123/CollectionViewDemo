//
//  SectionModel.h
//  MZCollectionViewDemo
//
//  Created by MACHUNLEI on 2017/5/6.
//  Copyright © 2017年 MACHUNLEI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SectionModel : NSObject

//定义Section头的名字；
@property(nonatomic,copy) NSString *sectionName;
//定义Section中的cell数组；
@property(nonatomic,strong) NSMutableArray *cellArray;//这里存放的是section中的每一个cell；

@end
