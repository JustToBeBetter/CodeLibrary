//
//  LJZStickyHeaderView.m
//  CodeLibrary
//
//  Created by maopao on 2019/3/19.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import "LJZStickyHeaderView.h"
#import "LJZHeaderRefreshView.h"
#import "UIScrollView+StickyHeader.h"
#import <AudioToolbox/AudioToolbox.h>

#define DefaultContentHeight  130

CGFloat ContentOffsetContext = 0;

typedef NS_ENUM(NSUInteger, ContentViewGravity) {
    ContentViewGravityTop,
    ContentViewGravityCenter,
    ContentViewGravityBottom,
};


@interface LJZStickyHeaderView (){
    BOOL _revealed;
    UIView *_contentView;
}
@property (assign, nonatomic) BOOL revealed;
@property (assign, nonatomic) CGFloat contentHeight;
@property (assign, nonatomic) CGFloat threshold;
@property (assign, nonatomic) UIEdgeInsets appliedInsets;
@property (assign, nonatomic) BOOL  insetsApplied;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *contentContainer;
@property (strong, nonatomic) LJZHeaderRefreshView *shadowView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) ContentViewGravity contentViewGravity;

@end

@implementation LJZStickyHeaderView

- (instancetype)initWithFrame:(CGRect)frame  {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}
- (void)setupViews{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.clipsToBounds = YES;
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.contentContainer];
    self.shadowView = [[LJZHeaderRefreshView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, DefaultContentHeight)];
    [self.contentContainer addSubview:self.shadowView];
    self.scrollView = (UIScrollView *)self.superview;
    self.revealed = NO;
    self.threshold = 0.3;
    self.appliedInsets = UIEdgeInsetsZero;
    self.contentViewGravity = ContentViewGravityBottom;
    self.contentHeight = DefaultContentHeight;
    
}
- (void)applyContentContainerTransform:(CGFloat)progress{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34  = -1 /50;
    CGFloat angle  = (1 - progress) * M_PI_2;
    transform = CATransform3DRotate(transform, angle, 1, 0, 0);
    self.contentContainer.layer.transform = transform;
}
#pragma mark
#pragma mark =====================view lifecycle=====================
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if (newSuperview == nil) {
        UIView *view = self.superview;
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *supView =  (UIScrollView *)self.superview;
            [supView removeObserver:self forKeyPath:@"contentOffset" context:&ContentOffsetContext];
            [supView.panGestureRecognizer  removeTarget:self action:@selector(handlePan:)];
            self.appliedInsets = UIEdgeInsetsZero;
            
        }
    }
}
- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    UIView *view =  self.superview;
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *supView = (UIScrollView *)self.superview;
        self.scrollView = supView;
        [supView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionInitial |NSKeyValueObservingOptionNew  context:&ContentOffsetContext];
        [supView.panGestureRecognizer addTarget:self action:@selector(handlePan:)];
        [supView sendSubviewToBack:self];
    }
}

- (void)setRevealed:(BOOL)revealed{
    if (revealed != _revealed) {
        if (revealed) {
            [self addInsets];
        }else{
            [self removeInsets];
        }
    }
    _revealed = revealed;
}
- (BOOL)revealed{
    return _revealed;
}
- (void)setContentView:(UIView *)contentView{
    
    if (_contentView) {
        [_contentView removeFromSuperview];
    }
    _contentView = contentView;
    UIView *view = _contentView;
    view.frame = self.contentContainer.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentContainer addSubview:view];
    [self.contentContainer sendSubviewToBack:view];
    
}
#pragma mark
#pragma mark =====================lazy=====================
- (UIImageView *)backgroundImageView{
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc]init];
        
    }
    return _backgroundImageView;
}

- (UIView *)contentContainer{
    if (_contentContainer == nil) {
        _contentContainer = [[UIView alloc]init];
        _contentContainer.layer.anchorPoint = CGPointMake(0.5, 1);
        _contentContainer.backgroundColor = [UIColor clearColor];
    }
    return _contentContainer;
}

#pragma mark
#pragma mark =====================keypath=====================

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (context == &ContentOffsetContext) {
        [self didScroll];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)didScroll{
    [self layoutToFit];
    [self layoutIfNeeded];
    CGFloat fractionRevealed = MIN(self.bounds.size.height / self.contentHeight, 1);
    CGFloat progress = fractionRevealed;
    self.shadowView.alpha = 1 - progress;
    
}
- (void)layoutToFit{
    
    CGFloat origin = self.scrollView.contentOffset.y + self.scrollView.effectiveContentInset.top - self.appliedInsets.top;
    CGRect frame = self.frame;
    frame.origin.y = origin;
    self.frame = frame;
    [self sizeToFit];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundImageView.frame = self.bounds;
    CGFloat containerY;
    switch (self.contentViewGravity) {
        case ContentViewGravityTop:
            containerY = MIN(self.bounds.size.height - self.contentHeight,self.bounds.origin.y);
            break;
        case ContentViewGravityCenter:
            containerY = MIN(self.bounds.size.height - self.contentHeight,self.bounds.origin.y+ self.bounds.size.height/2 - self.contentHeight/2);
            break;
        case ContentViewGravityBottom:
            containerY = self.bounds.size.height - self.contentHeight;
            break;
        default:
            break;
    }
    self.contentContainer.frame = CGRectMake(0, containerY, self.bounds.size.width, self.contentHeight);
    self.shadowView.frame =  CGRectInset(self.contentContainer.bounds, -round(self.contentContainer.bounds.size.width/16), 0);
    
    
}
- (CGSize)sizeThatFits:(CGSize)size{
    CGFloat height = 0;
    if (self.revealed) {
        height = self.appliedInsets.top - self.scrollView.normalizedContentOffset.y;
    }else{
        height = self.scrollView.normalizedContentOffset.y * -1;
    }
    CGSize output = CGSizeMake(self.scrollView.bounds.size.width, MAX(height, 0));
    [self.shadowView updateAnimationWithOffsetY:output.height];
    return output;
}
#pragma mark
#pragma mark =====================private=====================

- (void)setContentHeight:(CGFloat)contentHeight{
    _contentHeight = contentHeight;
    if (self.subviews != nil) {
        if (self.revealed) {
            [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                [self addInsets];
            } completion:^(BOOL finished) {
                CGPoint contenOffset = self.scrollView.contentOffset;
                contenOffset.y = - self.scrollView.effectiveContentInset.top;
                [UIView animateWithDuration:0 animations:^{
                    self.scrollView.contentOffset = contenOffset;
                }];
            }];
        }
        [self layoutToFit];
    }
}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat value = self.scrollView.normalizedContentOffset.y *(self.revealed?1:-1);
        CGFloat triggeringValue = self.contentHeight * self.threshold;
        CGFloat velocity  = [recognizer velocityInView:self.scrollView].y;
        
        if (triggeringValue < value) {
            BOOL adjust = !self.revealed || (velocity < 0 && (-velocity < self.contentHeight));
            
            if (!self.revealed && adjust){
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            [self setRevealed:!self.revealed animated:YES adjustContentOffset:adjust];
        }else if (self.bounds.size.height > 0 && self.bounds.size.height < self.contentHeight){
            CGPoint contentOffset = self.scrollView.contentOffset;
            contentOffset.y =  - self.scrollView.effectiveContentInset.top;
            [UIView animateWithDuration:0.3 animations:^{
                self.scrollView.contentOffset = contentOffset;
            }];
        }
    }
    
}
- (void)setRevealed:(BOOL)revealed animated:(BOOL)animated{
    [self setRevealed:revealed animated:animated adjustContentOffset:YES];
}
- (void)setRevealed:(BOOL)revealed animated:(BOOL)animated adjustContentOffset :(BOOL)adjust{
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.revealed = revealed;
        } completion:^(BOOL finished) {
            if (adjust) {
                CGPoint contentOffset = self.scrollView.contentOffset;
                contentOffset.y = -self.scrollView.effectiveContentInset.top;
                [UIView animateWithDuration:0.2  animations:^{
                    self.scrollView.contentOffset = contentOffset;
                }];
            }
        }];
    }else{
        self.revealed = revealed;
        if (adjust) {
            CGPoint contentOffset = self.scrollView.contentOffset;
            contentOffset.y =  - self.scrollView.effectiveContentInset.top;
            self.scrollView.contentOffset = contentOffset;
        }
    }
}
- (BOOL)insetsApplied{
    return  !UIEdgeInsetsEqualToEdgeInsets(self.appliedInsets, UIEdgeInsetsZero);
}
- (void)applyInsets:(UIEdgeInsets)insets{
    
    UIEdgeInsets  originalInset = UIEdgeInsetsMake(self.scrollView.effectiveContentInset.top - self.appliedInsets.top,self.scrollView.effectiveContentInset.left - self.appliedInsets.left , self.scrollView.effectiveContentInset.bottom - self.appliedInsets.bottom, self.scrollView.effectiveContentInset.right - self.appliedInsets.right);
    UIEdgeInsets targetInset = UIEdgeInsetsMake(originalInset.top + insets.top, originalInset.left + insets.left, originalInset.bottom + insets.bottom, originalInset.right + insets.right);
    
    self.appliedInsets = insets;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            self.scrollView.effectiveContentInset = targetInset;
            [self.scrollView setContentOffset:CGPointMake(0, -targetInset.top) animated:NO];
        } completion:^(BOOL finished) {
        }];
    });
    
}
- (void)removeInsets{
    NSAssert(self.insetsApplied, @"内部不一致");
    [self applyInsets:UIEdgeInsetsZero];
}
- (void)addInsets{
    NSAssert(!self.insetsApplied, @"内部不一致");
    [self applyInsets:UIEdgeInsetsMake(self.contentHeight, 0, 0, 0)];
}
@end
