//
//  LJZPlayerView.h
//
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LJZPlayerToolsView.h"
#import "LJZPlayer.h"
#import "LJZPlayerENUM.h"
@interface LJZPlayerView : UIView

@property (nonatomic,strong) LJZPlayerToolsView *vTools;
@property (nonatomic, assign) BOOL isSuccessLoad;//视频是否加载成功
@property (nonatomic,strong) LJZPlayer *player;
@property (nonatomic, copy)  void (^closeBlock)(void);
@property (nonatomic, copy)  void (^dragingBlock)(BOOL isDraging);

- (void)playWithUrl:(NSURL *)url;

- (void)deallocTimer;

@end
