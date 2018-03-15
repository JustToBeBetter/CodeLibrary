//
//  PagesViewController.h
//  CodeLibrary
//
//  Created by 李金柱 on 2017/8/24.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagesViewController : UIViewController

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, copy) NSString *page;
@property (nonatomic, assign) NSInteger currentPage;

- (id)initWithViewControllers:(NSArray *)viewControllers;

@end
