//
//  DXFooterRefresh.m
//  Live
//
//  Created by thy on 2017/4/28.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "DXFooterRefresh.h"
#import "UIView+Extension.h"

@interface DXFooterRefresh()
@property (weak, nonatomic) UILabel *label;
@property (weak, nonatomic) UIActivityIndicatorView *loading;
@end

@implementation DXFooterRefresh
    
- (void)prepare
{
    [super prepare];
    
    // 隐藏状态
    self.stateLabel.hidden = YES;
    // 设置控件的高度
    self.mj_h = 50;
    
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=60; ++i) {
        UIImage *image = [UIImage imageNamed:@"MJRefreshFoot1"];
        [idleImages addObject:image];
    }
    [self setImages:idleImages forState:MJRefreshStateIdle];
    
    NSMutableArray *refreshingImages = [NSMutableArray array];
    UIImage *image1 = [UIImage imageNamed:@"MJRefreshFoot2"];
    [refreshingImages addObject:image1];
    UIImage *image2 = [UIImage imageNamed:@"MJRefreshFoot3"];
    [refreshingImages addObject:image2];
    UIImage *image3 = [UIImage imageNamed:@"MJRefreshFoot4"];
    [refreshingImages addObject:image3];
    UIImage *image4 = [UIImage imageNamed:@"MJRefreshFoot5"];
    [refreshingImages addObject:image4];
    UIImage *image5 = [UIImage imageNamed:@"MJRefreshFoot6"];
    [refreshingImages addObject:image5];
    UIImage *image6 = [UIImage imageNamed:@"MJRefreshFoot7"];
    [refreshingImages addObject:image6];
    UIImage *image7 = [UIImage imageNamed:@"MJRefreshFoot8"];
    [refreshingImages addObject:image7];
    [self setImages:refreshingImages forState:MJRefreshStatePulling];
    
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
 
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor colorWithRed:187.0/255.0 green:187.0/255.0 blue:187.0/255.0 alpha:1.0];
    label.font = [UIFont boldSystemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.label = label;
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
    
    CGRect gifViewFrame = self.gifView.frame;
    gifViewFrame.origin.x = (self.width-gifViewFrame.size.width)/2-3;
    self.gifView.frame = gifViewFrame;
    
    self.label.frame = CGRectMake(0 ,0, self.width, 35);
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
    
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateNoMoreData:
            [self.loading stopAnimating];
            self.label.text = @"已经到底了";
            break;
        default:
            self.label.text = @"";
            break;
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
}


@end
