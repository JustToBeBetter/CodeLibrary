//
//  LJZPlayerShowView.m
//  Test
//
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import "LJZPlayerShowView.h"
#import "LJZPlayerLayerView.h"

@interface LJZPlayerShowView()

@property (nonatomic, strong) LJZPlayerLayerView *vPlayerLayer;

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation LJZPlayerShowView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setUIs];
    }
    return self;
}

- (void)setUIs{

    
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.vPlayerLayer];
    [self.vPlayerLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    
}

#pragma mark - setter and getter Methods
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}

- (void)setImage:(UIImage *)img{
    if (img) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imageView.hidden = NO;
            [self.imageView setImage:img];
            self.vPlayerLayer.hidden = YES;
        } completion:^(BOOL finished) {
            self.imageView.hidden = YES;
        }];
        
    }else{
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.imageView.alpha = 0.0;
            self.vPlayerLayer.hidden = NO;
        } completion:^(BOOL finished) {
            self.imageView.hidden = YES;
            self.imageView.alpha = 1.0;
        }];
    }
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self.vPlayerLayer layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self.vPlayerLayer layer] setPlayer:player];
}

- (LJZPlayerLayerView *)vPlayerLayer{
    if (_vPlayerLayer == nil) {
        _vPlayerLayer = [[LJZPlayerLayerView alloc] init];
    }
    return _vPlayerLayer;
}
@end
