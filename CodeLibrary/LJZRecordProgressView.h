//
//  LJZRecordProgressView.h
//  CodeLibrary
//
//  Created by maopao on 2019/3/19.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJZRecordProgressView : UIButton


@property (nonatomic ,assign) CGFloat progress;

- (void)resetScale;

- (void)setScale;


@end
