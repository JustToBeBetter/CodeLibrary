//
//  StickyHeaderViewController.m
//  CodeLibrary
//
//  Created by maopao on 2019/3/19.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import "StickyHeaderViewController.h"
#import "LJZStickyHeaderView.h"

@interface StickyHeaderViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView *collectionView;

@end

@implementation StickyHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI{
    LJZStickyHeaderView *header = [[LJZStickyHeaderView alloc]init];
    header.contentView = self.collectionView;
    header.frame  =  CGRectMake(0, 0, kScreenWidth, 130);
    [self.tableView addSubview:header];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark -
#pragma mark -tabbleView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行",indexPath.row + 1];
    return cell;
}


#pragma mark -
#pragma mark -collection

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor blueColor];
    
    return cell;
}


///初始化collectionView
- (UICollectionView *)collectionView{
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(80, 80);
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 114) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor lightGrayColor];
        collectionView.pagingEnabled = YES;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView setDelegate:self];
        [collectionView setDataSource:self];
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"item"];
        
        
        _collectionView = collectionView;
    }
    
    return _collectionView;
}
@end
