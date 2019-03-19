//
//  LJZRecordViewController.h
//  CodeLibrary
//
//  Created by maopao on 2019/3/19.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJZRecordViewController : UIViewController

@property (nonatomic ,copy) void (^recordBlock) (UIImage *image, NSString *videoPath,UIImage *videoCoverImage);

@end
