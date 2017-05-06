//
//  CollectionReusableView.m
//  MZCollectionViewDemo
//
//  Created by MACHUNLEI on 2017/5/6.
//  Copyright © 2017年 MACHUNLEI. All rights reserved.
//

#import "CollectionReusableView.h"

@implementation CollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, [[UIScreen mainScreen] bounds].size.width, 20)];
        self.title.textColor = [UIColor blackColor];
        self.title.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.title];
    }
    return self;
}

@end
