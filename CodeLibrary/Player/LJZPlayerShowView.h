//
//  LJZPlayerShowView.h
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LJZPlayerShowView : UIView
@property (nonatomic,weak) AVPlayer *player;

- (void)setImage:(UIImage *)img;

@end
