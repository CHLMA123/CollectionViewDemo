//
//  NorCollectionViewCell.m
//  MZCollectionViewDemo
//
//  Created by MACHUNLEI on 2017/5/6.
//  Copyright © 2017年 MACHUNLEI. All rights reserved.
//

#import "NorCollectionViewCell.h"
#import "CellModel.h"

#define CELL_WIDTH ((SCREEN_WIDTH - 80) / 3)

@implementation NorCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH,CELL_WIDTH)];
        //[self.imageView setUserInteractionEnabled:true];
        self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CELL_WIDTH, CELL_WIDTH, 20)];
        self.descLabel.textAlignment = NSTextAlignmentCenter;
        self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH - 35, 5, 30, 30)];
        [self.deleteButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        //先设置不可见；
        [self.deleteButton setHidden:true];
        
        self.selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH - 35, 5, 30, 30)];
        self.selectImageView.image = [UIImage imageNamed:@"checkbox_checked"];
        //[self.selectImageView setUserInteractionEnabled:true];
        [self.selectImageView setHidden:YES];
        
        self.layer.borderWidth = 0.5;
        [self addSubview:self.imageView];
        [self addSubview:self.descLabel];
        [self addSubview:self.deleteButton];
        [self addSubview:self.selectImageView];
    }
    return self;
}

- (void)fillCellWithModel:(CellModel *)model{

    self.imageView.image = [UIImage imageNamed:model.cellImage];
    self.descLabel.text = model.cellDesc;
    self.selectImageView.hidden = !model.cellSelect;
}
@end
