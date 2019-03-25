//
//  LJZPlayerSlider.m
//
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import "LJZPlayerSlider.h"
#import "LJZSlider.h"
@interface LJZPlayerSlider ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) LJZSlider*slider;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) BOOL isDraging;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation LJZPlayerSlider

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setUI];
    }
    return self;
}

- (void)setUI{
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self).offset(-4);
        make.centerY.equalTo(self).offset(0.5);
        make.height.equalTo(@(2));
    }];
    
    [self addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark - Public Methods
- (void)setLoaded:(CGFloat)load{
    self.progressView.progress = load;
}

- (void)setPlayed:(CGFloat)played{
    if (self.isDraging == NO) {
        [self.slider setValue:played animated:YES];
    }
}

- (CGFloat)getPlayed{
    return self.slider.value;
}

- (void)initPlayed:(CGFloat)played{
    [self.slider setValue:played animated:YES];
}

#pragma mark - Event Methods
- (void)sliderValueChanged:(id)sender{
    NSLog(@"?????%.2f",self.slider.value);
    [self.delegate sliderChangingValue:self.slider.value];
}
- (void)sliderBeginDrag{
    self.isDraging = YES;
    self.tapGestureRecognizer.enabled = NO;
}
- (void)sliderValueChangedTouchUp{
    self.isDraging = NO;
    self.tapGestureRecognizer.enabled = YES;
    [self.delegate sliderChangedValue:self.slider.value];
}

-(void)tapSlider:(id)sender{
    self.isDraging = NO;
    UITapGestureRecognizer * tapGR = (UITapGestureRecognizer *)sender;
    CGPoint location = [tapGR locationInView:tapGR.view];
    CGFloat value = location.x/self.slider.frame.size.width;
    [self.slider setValue:value animated:NO];
    [self.delegate sliderChangedValue:self.slider.value];
 
}

#pragma mark - setter and getter Methods
- (LJZSlider *)slider{
    if (_slider == nil) {
        _slider = [[LJZSlider alloc] init];
        _slider.backgroundColor = [UIColor clearColor];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
        [_slider setThumbImage:[UIImage imageNamed:@"player_slider"] forState:UIControlStateNormal];
        [_slider setThumbImage:[UIImage imageNamed:@"player_slider"] forState:UIControlStateHighlighted];
        
        [_slider addTarget:self action:@selector(sliderValueChangedTouchUp) forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self action:@selector(sliderValueChangedTouchUp) forControlEvents:UIControlEventTouchUpOutside];
        [_slider addTarget:self action:@selector(sliderValueChangedTouchUp) forControlEvents:UIControlEventTouchCancel];
        [_slider addTarget:self action:@selector(sliderBeginDrag) forControlEvents:UIControlEventTouchDragInside];
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        
    }
    return _slider;
}

- (UIProgressView *)progressView{
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.trackTintColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:0.5];
        _progressView.tintColor = [UIColor colorWithWhite:1 alpha:0.6];
        _progressView.layer.cornerRadius = 1.5;
        _progressView.clipsToBounds = YES;
    }
    return _progressView;
}

- (void)setIsDraging:(BOOL)isDraging{
    if (_isDraging != isDraging) {
        _isDraging = isDraging;
        [self.delegate isDraging:isDraging];
    }
}

- (UITapGestureRecognizer *)tapGestureRecognizer{
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSlider:)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
        _tapGestureRecognizer.numberOfTouchesRequired = 1;
    }
    return _tapGestureRecognizer;
}


@end
