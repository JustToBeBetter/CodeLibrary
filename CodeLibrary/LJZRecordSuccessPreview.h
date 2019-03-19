//
//  LJZRecordSuccessPreview.h
//  CodeLibrary
//
//  Created by maopao on 2019/3/19.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface LJZRecordSuccessPreview : UIView

@property (nonatomic ,copy) void (^sendBlock) (UIImage *image, NSString *videoPath);
@property (nonatomic ,copy) void (^cancelBlcok) (void);

/**
 设置图片或视频
 @param image 图片
 @param videoPath 视频地址
 @param orientation 方向
 */
- (void)setImage:(UIImage *)image videoPath:(NSString *)videoPath  captureVideoOrientation:(AVCaptureVideoOrientation)orientation;



@end
