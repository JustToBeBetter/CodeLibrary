//
//  UIScrollView+StickyHeader.m
//  CodeLibrary
//
//  Created by maopao on 2019/3/19.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import "UIScrollView+StickyHeader.h"

@implementation UIScrollView (StickyHeader)

- (CGPoint)normalizedContentOffset{
    
    CGPoint contentOffset  = self.contentOffset;
    UIEdgeInsets contentInset = self.effectiveContentInset;
    CGPoint output = CGPointMake(contentOffset.x +contentInset.left, contentOffset.y + contentInset.top);
    return output;
}
- (void)setNormalizedContentOffset:(CGPoint)normalizedContentOffset{
    
}
- (UIEdgeInsets)effectiveContentInset{
    if (@available(iOS 11.0, *)) {
        return self.adjustedContentInset;
    }else{
        return self.contentInset;
    }
}
- (void)setEffectiveContentInset:(UIEdgeInsets)effectiveContentInset{
    
    if (@available(iOS 11.0, *)) {
        if (self.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
            self.contentInset = UIEdgeInsetsMake(effectiveContentInset.top - self.safeAreaInsets.top, effectiveContentInset.left - self.safeAreaInsets.left, effectiveContentInset.bottom - self.safeAreaInsets.bottom, effectiveContentInset.right - self.safeAreaInsets.right);
        }else{
            self.contentInset = effectiveContentInset;
        }
    }else{
        self.contentInset = effectiveContentInset;
    }
}

@end
