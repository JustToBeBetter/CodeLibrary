//
//  UIAlertController+Rotation.m
//  Live
//
//  Created by 邵雄华 on 2017/4/6.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "UIAlertController+Rotation.h"
#import "UIViewController+LifeCycle.h"

@implementation UIAlertController (Rotation)

- (BOOL)shouldAutorotate
{
    UIViewController *vc = self.presentedViewController;
    if ([vc getIsPlayerVC]) {
        return [self.presentedViewController shouldAutorotate];
    }
    return [super shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIViewController *vc = self.presentedViewController;
    if ([vc getIsPlayerVC]) {
        return [self.presentedViewController supportedInterfaceOrientations];
    }
    return [super supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIViewController *vc = self.presentedViewController;
    if ([vc getIsPlayerVC]) {
        return [self.presentedViewController preferredInterfaceOrientationForPresentation];
    }
    return [super preferredInterfaceOrientationForPresentation];
}

@end
