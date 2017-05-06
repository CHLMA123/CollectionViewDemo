//
//  CollectionViewController.m
//  MZCollectionViewDemo
//
//  Created by MACHUNLEI on 2017/5/6.
//  Copyright © 2017年 MACHUNLEI. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionReusableView.h"
#import "NorCollectionViewCell.h"
#import "SectionModel.h"
#import "CellModel.h"
#import "CustomAnimation.h"
#import "CellManagerLayout.h"

typedef NS_ENUM(NSInteger, CellStateIndex) {
    NormalStateIndex = 0,
    DeleteStateIndex,
    SelectStateIndex,
};

@interface CollectionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CellManagerDelegate>

@property (nonatomic, strong) UICollectionView          *collectionView;
@property (nonatomic, strong) UIButton                  *editButton;
@property (nonatomic, strong) CollectionReusableView    *reusableView;
@property (nonatomic, assign) CellStateIndex            cellState;
@property (nonatomic, assign) BOOL                      rotateAnimationFlag;

@property (nonatomic, strong) NSMutableArray    *dataSectionArray;
@property (nonatomic, strong) NSMutableArray    *dataCellArray;
@property (nonatomic, strong) SectionModel      *section;
@property (nonatomic, strong) NSMutableArray    *headerArray;
@property (nonatomic, strong) NSMutableArray    *cellImageArr;
@property (nonatomic, strong) NSMutableArray    *cellDescArr;

@property (nonatomic, strong) CellManagerLayout *flowLayout;

@property (nonatomic, strong) NSMutableArray *deleteArr;

@end

@implementation CollectionViewController

#pragma mark - Lif
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _cellState = NormalStateIndex;
    _rotateAnimationFlag = YES;
    _deleteArr = [NSMutableArray array];
    [self setupView];
}

- (void)setupView{
    self.title = @"今天周六哦";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    
    UIBarButtonItem *rNavBtn  = [[UIBarButtonItem alloc] initWithCustomView:self.editButton];
    UIBarButtonItem *rNavBtn2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(changeViewDisplay)];
    self.navigationItem.rightBarButtonItems = @[rNavBtn, rNavBtn2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Private Methods
- (void)changeViewDisplay{
    if (_cellState == NormalStateIndex) {
        _cellState = SelectStateIndex;
    }else if (_cellState == SelectStateIndex){
        _cellState = NormalStateIndex;
        if (_deleteArr.count >0) {
            SectionModel *sec = [self.dataSectionArray objectAtIndex:0];
            [sec.cellArray removeObjectsInArray:_deleteArr];
            [self.collectionView reloadData];
        }
    }
}

- (void)editButtonPressed:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (_cellState == NormalStateIndex) {
        _cellState = DeleteStateIndex;
        _rotateAnimationFlag = NO;
        //循环遍历整个CollectionView；
        for(NorCollectionViewCell *cell in self.collectionView.visibleCells){
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            //找到某一个具体的section；
            SectionModel *section = self.dataSectionArray[indexPath.section];
            //除最后一个cell外都显示删除按钮；
            if (indexPath.row != section.cellArray.count - 1){
                [cell.deleteButton setHidden:false];
            }
        }
        //self.collectionView.allowsSelection = NO;
    }
    else if (_cellState == DeleteStateIndex){
        _cellState = NormalStateIndex;
        _rotateAnimationFlag = YES;
        //self.collectionView.allowsSelection = YES;
    }
    [self.flowLayout setInEditState:sender.selected];
    [self.collectionView reloadData];
}

- (void)deleteCellButtonPressed:(id)sender{
    
    NorCollectionViewCell *cell = (NorCollectionViewCell *)[sender superview];
    // 获取cell对应的indexpath;
    NSIndexPath *indexpath = [self.collectionView indexPathForCell:cell];
    // 删除cell；
    SectionModel *sec = [self.dataSectionArray objectAtIndex:indexpath.section];
    [sec.cellArray removeObjectAtIndex:indexpath.row];
    
    [self.collectionView reloadData];
    NSLog(@"删除按钮，section:%ld ,   row: %ld",(long)indexpath.section,(long)indexpath.row);
}

#pragma mark - CellManagerDelegate
//处于编辑状态
- (void)didChangeEditState:(BOOL)inEditState
{}
//改变数据源中model的位置
- (void)moveItemAtIndexPath:(NSIndexPath *)fromPath toIndexPath:(NSIndexPath *)toPath {
    if (fromPath.section != toPath.section) {
        return;
    }
    SectionModel *sec = [self.dataSectionArray objectAtIndex:fromPath.section];
    self.dataCellArray = sec.cellArray;
    CellModel *tempCell = self.dataCellArray[fromPath.row];
    //先把移动的这个model移除
    [self.dataCellArray removeObject:tempCell];
    //再把这个移动的model插入到相应的位置
    [self.dataCellArray insertObject:tempCell atIndex:toPath.row];
}
#pragma mark - 弹出输入环境名称的提示框
- (void)createNewItemDialog:(NSIndexPath *)indexPath{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入Section名称" preferredStyle:UIAlertControllerStyleAlert];
    //以下方法就可以实现在提示框中输入文本；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *envirnmentNameTextField = alertController.textFields.firstObject;
        //初始化一个新的cell模型；
        CellModel *cel = [[CellModel alloc] init];
        cel.cellImage = @"1";
        cel.cellDesc = envirnmentNameTextField.text;
        SectionModel *sec = [self.dataSectionArray objectAtIndex:indexPath.section];
        //获取当前的cell数组,把新创建的cell插入到最后一个之前；
        self.dataCellArray = sec.cellArray;
        [self.dataCellArray insertObject:cel atIndex:self.dataCellArray.count - 1];
        NSLog(@"你输入新的Item文本: %@",envirnmentNameTextField.text);
        [self.collectionView reloadData];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入新的Item名称";
    }];
    [self presentViewController:alertController animated:true completion:nil];
}
//- (void)addEnvirnmentClick {
//    
//    self.dataCellArray = [[NSMutableArray alloc] init];
//    for (int i = 0; i < 6; i++) {
//        
//        CellModel *cell = [[CellModel alloc] init];
//        cell.cellDesc = self.cellDescArr[i];
//        cell.cellImage = self.cellImageArr[i];
//        [self.dataCellArray addObject:cell];
//    }
//    [self popEnvirnmentNameDialog];
//}
//- (void)popEnvirnmentNameDialog{
//    
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入Section名称" preferredStyle:UIAlertControllerStyleAlert];
//    //以下方法就可以实现在提示框中输入文本；
//    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        UITextField *envirnmentNameTextField = alertController.textFields.firstObject;
//        
//        SectionModel *sec = [[SectionModel alloc] init];
//        sec.sectionName = envirnmentNameTextField.text;
//        sec.cellArray = self.dataCellArray;
//        //增加一个section，就要加入到dataSectionArray中；
//        [self.dataSectionArray addObject:sec];
//        [self.headerArray addObject:envirnmentNameTextField.text];
//        [self.collectionView reloadData];
//        NSLog(@"你输入的文本%@",envirnmentNameTextField.text);
//    }]];
//    
//    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = @"请输入Section名称";
//    }];
//    [self presentViewController:alertController animated:true completion:nil];
//}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    SectionModel *tempModel = [self.dataSectionArray objectAtIndex:section];
    return  tempModel.cellArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NorCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NorCollectionCell" forIndexPath:indexPath];
    SectionModel *tempSectionM = [self.dataSectionArray objectAtIndex:indexPath.section];
    CellModel *tempCellM = [tempSectionM.cellArray objectAtIndex:indexPath.row];
    [cell fillCellWithModel:tempCellM];
    // 设置删除按钮
    // 点击编辑按钮触发事件
    if(_cellState == NormalStateIndex){
        // 正常情况下，所有删除按钮都隐藏；
        cell.deleteButton.hidden = true;
    }else if(_cellState == DeleteStateIndex){
        // 可删除情况下；
        // 找到某个具体的section；
        SectionModel *section = self.dataSectionArray[indexPath.section];
        // cell数组中的最后一个是添加按钮，不能删除；
        if (indexPath.row == section.cellArray.count - 1){
            cell.deleteButton.hidden = true;
        }else{
            cell.deleteButton.hidden = false;
        }
        [cell.deleteButton addTarget:self action:@selector(deleteCellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (!_rotateAnimationFlag) {
        [CustomAnimation vibrateAnimation:cell];
    }else{
        [cell.layer removeAnimationForKey:@"shake"];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.dataSectionArray.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *reusable = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        
        CollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
        view.title.text = [[NSString alloc] initWithFormat:@"头部视图%ld",indexPath.section];
        reusable = view;
    }
    return reusable;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SectionModel *sec = [self.dataSectionArray objectAtIndex:indexPath.section];
    if (_cellState == NormalStateIndex) {
        if ((indexPath.row == sec.cellArray.count - 1)) {
            NSLog(@"点击最后一个cell，执行添加操作");
            [self createNewItemDialog:indexPath];
        }else{
            NSLog(@"第%ld个section,点击图片%ld",indexPath.section,indexPath.row);
        }
    }else if(_cellState == SelectStateIndex) {
        if ((indexPath.row == sec.cellArray.count - 1)) {
            NSLog(@"点击最后一个cell，执行添加操作");
        }else{
            NSLog(@"第%ld个section,点击图片%ld",indexPath.section,indexPath.row);
            self.dataCellArray = sec.cellArray;
            CellModel *tempCell = self.dataCellArray[indexPath.row];
            tempCell.cellSelect = !tempCell.cellSelect;
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            if (tempCell.cellSelect) {
                [_deleteArr addObject:tempCell];
            }else{
                if ([_deleteArr containsObject:tempCell]) {
                    [_deleteArr removeObject:tempCell];
                }
            }
        }
    }
//    NSString *message = [[NSString alloc] initWithFormat:@"你点击了第%ld个section，第%ld个cell",(long)indexPath.section,(long)indexPath.row];
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        //点击确定后执行的操作；
//    }]];
//    [self presentViewController:alert animated:true completion:^{
//        //显示提示框后执行的事件；
//    }];
}

#pragma mark - Setter && Getter
- (CellManagerLayout *)flowLayout
{
    if (!_flowLayout) {
        _flowLayout = [[CellManagerLayout alloc] init];
        _flowLayout.delegate = self;
        _flowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 80)/3, (SCREEN_WIDTH - 80)/3 + 20);
        _flowLayout.minimumLineSpacing = 20;
        _flowLayout.minimumInteritemSpacing = 0;
        //设置collectionView整体的上下左右之间的间距
        _flowLayout.sectionInset = UIEdgeInsetsMake(20, 20, 10, 20);
        _flowLayout.headerReferenceSize = CGSizeMake(self.collectionView.frame.size.width, 50);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:[[UIScreen mainScreen] bounds] collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [_collectionView registerClass:[NorCollectionViewCell class] forCellWithReuseIdentifier:@"NorCollectionCell"];
        [_collectionView registerClass:[CollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    }
    return _collectionView;
}

- (UIButton *)editButton{

    if (_editButton == nil) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _editButton.backgroundColor = [UIColor grayColor];
        _editButton.frame = CGRectMake(0, 0, 40, 40);
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [_editButton setTitle:@"完成" forState:UIControlStateSelected];
        [_editButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    return _editButton;
}

- (NSMutableArray *)dataSectionArray{
    if (!_dataSectionArray){
        _dataSectionArray = [[NSMutableArray alloc] initWithCapacity:2];
        for (int i = 0; i < 2; i++) {
            _dataCellArray = [[NSMutableArray alloc] initWithCapacity:6];
            for (int j = 0; j < 6; j++) {
                CellModel *cellModel = [[CellModel alloc] init];
                cellModel.cellImage = self.cellImageArr[j];
                cellModel.cellDesc = self.cellDescArr[j];
                cellModel.cellSelect = NO;
                [_dataCellArray addObject:cellModel];
            }
            SectionModel *sectionModel = [[SectionModel alloc] init];
            sectionModel.sectionName = self.headerArray[i];
            sectionModel.cellArray = _dataCellArray;
            [_dataSectionArray addObject:sectionModel];
        }
    }
    return _dataSectionArray;
}

- (NSMutableArray *)headerArray{
    if (!_headerArray) {
        self.headerArray = [[NSMutableArray alloc] initWithObjects:@"第一个",@"第二个", nil];
    }
    return _headerArray;
}

- (NSMutableArray *)cellImageArr{
    
    if (!_cellImageArr) {
        self.cellImageArr = [[NSMutableArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",nil];
    }
    return _cellImageArr;
}

- (NSMutableArray *)cellDescArr{
    if (!_cellDescArr) {
        self.cellDescArr = [[NSMutableArray alloc] initWithObjects:@"第0个",@"第1个",@"第2个",@"第3个",@"第4个",@"添加",nil];
    }
    return _cellDescArr;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
