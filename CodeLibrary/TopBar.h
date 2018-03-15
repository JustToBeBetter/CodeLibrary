//
//  TopBar.h
//  KillGame
//
//  Created by 李金柱 on 2017/8/15.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTopbarHeight 40
typedef void (^ButtonClickHandler)(NSInteger currentPage);

@interface TopBar : UIScrollView

@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, copy) ButtonClickHandler blockHandler;

@end

