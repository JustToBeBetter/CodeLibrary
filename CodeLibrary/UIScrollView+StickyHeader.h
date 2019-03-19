//
//  UIScrollView+StickyHeader.h
//  CodeLibrary
//
//  Created by maopao on 2019/3/19.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (StickyHeader)

@property (nonatomic,assign) CGPoint normalizedContentOffset;

@property (nonatomic,assign) UIEdgeInsets effectiveContentInset;

@end
