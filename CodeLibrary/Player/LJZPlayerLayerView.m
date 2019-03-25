//
//  LJZPlayerLayerView.m
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import "LJZPlayerLayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation LJZPlayerLayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end
