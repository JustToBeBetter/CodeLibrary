//
//  UIView+Backtracking.m
//  Live
//  view回溯分类
//  Created by 戴奕 on 2017/3/27.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "UIView+Backtracking.h"

@implementation UIView (Backtracking)

- (UIViewController *)viewController{
    UIResponder *responder = [self nextResponder];
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }else {
            responder = [responder nextResponder];
        }
    }
    return nil;
}

- (UINavigationController *)navigationController {
    UIResponder *responder = [self nextResponder];
    while (responder) {
        if ([responder isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)responder;
        }else {
            responder = [responder nextResponder];
        }
    }
    return nil;
}

@end
