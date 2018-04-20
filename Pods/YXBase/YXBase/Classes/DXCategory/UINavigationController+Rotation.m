//
//  UINavigationController+Rotation.m
//  Live
//
//  Created by wenjie hua on 2017/3/14.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "UINavigationController+Rotation.h"
#import "UIViewController+LifeCycle.h"
@implementation UINavigationController (Rotation)

- (BOOL)shouldAutorotate
{
    UIViewController *vc = [self.viewControllers lastObject];
    if ([vc getIsPlayerVC]) {
        return [[self.viewControllers lastObject] shouldAutorotate];
    }
    return NO;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIViewController *vc = [self.viewControllers lastObject];
    if ([vc getIsPlayerVC]) {
        return [[self.viewControllers lastObject] supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *vc = [self.viewControllers lastObject];
    if ([vc getIsPlayerVC]) {
         return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
     }
    return UIInterfaceOrientationPortrait;
}

@end
