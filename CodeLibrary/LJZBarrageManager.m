//
//  LJZBarrageManager.m
//  CodeLibrary
//
//  Created by 李金柱 on 2017/4/12.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import "LJZBarrageManager.h"
#import "LJZBarrageView.h"
#define kDefaultTrajectoryCount 1   ///< 默认弹幕轨道数

@interface LJZBarrageManager ()

@property(nonatomic, strong) NSMutableArray *datasource;    ///< 弹幕的数据来源

@property(nonatomic, strong) NSMutableArray *barrageComments;   ///< 使用过程中的数组变量

@property(nonatomic, strong) NSMutableArray *barrageViews;      ///< 存储弹幕view的数组变量

@property(nonatomic, assign) BOOL isBarrageStart;           ///< 判断当前弹幕的状态
@end
@implementation LJZBarrageManager

- (instancetype)initWithComments:(NSArray *)comments
{
    if (self = [super init]) {
        _isBarrageStart = NO;
        
        [self.datasource addObjectsFromArray:comments];
        _trajectoryCount = kDefaultTrajectoryCount;
    }
    return self;
}

- (void)initBarrageComment
{
    NSMutableArray *trajectorys = [NSMutableArray array];
    for (int i=0; i<self.trajectoryCount; i++) {
        [trajectorys addObject:@(i)];
    }
    
    for (int i=0; i<self.trajectoryCount; i++) {
        NSInteger index = arc4random()%trajectorys.count;
        int trajectory = [[trajectorys objectAtIndex:index] intValue];
        [trajectorys removeObjectAtIndex:index];
        
        NSString *comments = [self.barrageComments firstObject];
        [self.barrageComments removeObjectAtIndex:0];
        
        [self createBarrageView:comments trajectory:trajectory];
    }
}

- (void)createBarrageView:(NSString *)comment trajectory:(int)trajectory
{
    if (!self.isBarrageStart) {
        return;
    }
    
    LJZBarrageView *view = [[LJZBarrageView alloc] initWithComment:comment];
    view.trajectory = trajectory;
    
    __weak typeof (view) weakView = view;
    __weak typeof (self) weakSelf = self;
    view.BarrageStatusBlock = ^(BarrageStatus status){
        if (!self.isBarrageStart) {
            return ;
        }
        
        switch (status) {
            case BarrageStart: {
                //弹幕开始进入屏幕，将弹幕view加入到弹幕管理变量中的barrageViews中
                [weakSelf.barrageViews addObject:weakView];
                NSLog(@"1");
                break;
            }
            case BarrageEnter: {
                //弹幕完全进入屏幕，判断是否还有其他内容，如果有，则在弹幕轨迹中创建弹幕
                NSString *newComment = [self nextComment];
                if (newComment) {
                    [weakSelf createBarrageView:newComment trajectory:trajectory];
                    NSLog(@"2");
                }
                break;
            }
            case BarrageEnd: {
                //弹幕完全飞出屏幕后，从barrageViews释放资源
                if ([weakSelf.barrageViews containsObject:weakView]) {
                    [weakView stopAnimation];
                    [weakSelf.barrageViews removeObject:weakView];
                    NSLog(@"3");
                }
                
                //说明屏幕上已经没有弹幕，开始循环滚动
                if (weakSelf.barrageViews.count == 0) {
                    self.isBarrageStart = NO;
                    [weakSelf start];
                    NSLog(@"4");

                }
                NSLog(@"5");
                break;
            }
            default:
                break;
        }
    };
    
    if (self.generateViewBlock) {
        self.generateViewBlock(view);
    }
}

- (NSString *)nextComment
{
    if (self.barrageComments.count == 0) {
        return nil;
    }
    NSString *comment = [self.barrageComments firstObject];
    if (comment) {
        [self.barrageComments removeObjectAtIndex:0];
    }
    return comment;
}

- (void)start
{
    if (self.isBarrageStart) {
        return;
    }
    
    
    self.isBarrageStart = YES;
    [self.barrageComments removeAllObjects];
    [self.barrageComments addObjectsFromArray:self.datasource];
    
    [self initBarrageComment];
}

- (void)stop
{
    if (!self.isBarrageStart) {
        return;
    }
    
    self.isBarrageStart = NO;
    [self.barrageViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LJZBarrageView *view = obj;
        [view stopAnimation];
        view = nil;
    }];
    
    [self.barrageViews removeAllObjects];
}

- (void)appendData:(NSArray *)data
{
    [self.datasource addObjectsFromArray:data];
    [self.barrageComments addObjectsFromArray:data];
}

#pragma mark - setter
- (void)setTrajectoryCount:(NSInteger)trajectoryCount
{
    _trajectoryCount = trajectoryCount;
}

#pragma mark - getter
- (NSMutableArray *)datasource{
    if (!_datasource) {
        _datasource = [NSMutableArray array];
    }
    return _datasource;
}

- (NSMutableArray *)barrageComments{
    if (!_barrageComments) {
        _barrageComments = [NSMutableArray array];
    }
    return _barrageComments;
}

- (NSMutableArray *)barrageViews{
    if (!_barrageViews) {
        _barrageViews = [NSMutableArray array];
    }
    return _barrageViews;
}

@end
