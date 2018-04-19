//
//  LJZSegmentView.h
//  CodeLibrary
//
//  Created by lijz on 2018/4/19.
//  Copyright © 2018年 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LJZSegmentView;

@protocol LJZSegmentedViewDelegate <NSObject>

@required

-(void)segmentedView:(LJZSegmentView *)segmentedView didSeletIndex:(NSInteger)index;

@end
@interface LJZSegmentView : UIView
/**
 选中label的背景颜色
 */
@property (nonatomic, strong) UIColor *selectedViewColor;
/**
 未选中label文字的颜色
 */
@property (nonatomic, strong) UIColor *normalLabelColor;

@property (nonatomic, strong) NSArray <NSString *>* titles;

@property (nonatomic, weak) id<LJZSegmentedViewDelegate> delegate;

@property (nonatomic, assign) NSInteger selectedIndex;
@end
