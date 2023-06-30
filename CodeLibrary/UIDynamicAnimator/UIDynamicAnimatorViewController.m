//
//  UIDynamicAnimatorViewController.m
//  CodeLibrary
//
//  Created by lijinzhu on 2023/2/28.
//  Copyright © 2023 李金柱. All rights reserved.
//

#import "UIDynamicAnimatorViewController.h"

@interface UIDynamicAnimatorViewController ()<UICollisionBehaviorDelegate>

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIImageView *animationImgView;

@property (nonatomic, strong) UIView *baseView;

@property (nonatomic, strong) UIView *hiddenView;

@property (nonatomic, strong) UIDynamicAnimator *animator;

@property (nonatomic, strong) UICollisionBehavior *collision;

@property (nonatomic, strong) UIPushBehavior *push;

@property (nonatomic, strong) NSMutableArray *itemsArray;

@end

@implementation UIDynamicAnimatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}
- (void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.baseView];
    self.hiddenView.center = self.baseView.center;
    [self.containerView addSubview:self.hiddenView];
    [self.containerView addSubview:self.animationImgView];
    [self.animator addBehavior:self.push];
    [self.animator addBehavior:self.collision];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.collision removeItem:self.hiddenView];
    [self.animator removeBehavior:self.push];
    self.hiddenView.center = self.baseView.center;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.containerView];
    CGPoint origin = self.baseView.center;
    CGFloat distance = sqrtf(powf(origin.x-point.x, 2.0)+powf(origin.y-point.y, 2.0));
    CGFloat angle = atan2(point.y-origin.y, point.x-origin.x);
    distance = MAX(distance, 10.0);
    NSLog(@"angle:%.1f distance:%.1f",angle,distance);
    // icon位置离中心越远拉力越大
    self.push = [[UIPushBehavior alloc]initWithItems:@[self.hiddenView] mode:UIPushBehaviorModeInstantaneous];
    [self.push setMagnitude:3];//distance/10.0
    [self.push setAngle:angle];
    [self.push setActive:YES];
    [self.animator addBehavior:self.push];
    [self.collision addItem:self.hiddenView];
}

#pragma mark ---------UICollisionBehaviorDelegate--------
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier atPoint:(CGPoint)p{
    NSLog(@"beganContactForItem:x:%.1f y:%.1f",p.x,p.y);

}
- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2{
    NSLog(@"1:%@ 2:%@",item1,item2);
}
- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(nullable id <NSCopying>)identifier{
    UIView *view = (UIView *)item;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (view == self.hiddenView) {
            [self.collision removeItem:item];
        }
    });
}
#pragma mark ---------lazy--------

- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)- 400)/2, (CGRectGetHeight(self.view.frame) - 300)/2, 400, 300)];
        _containerView.backgroundColor = UIColor.lightGrayColor;
    }
    return _containerView;
}
- (UIImageView *)animationImgView{
    if (!_animationImgView) {
        _animationImgView = [[UIImageView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.containerView.frame)- 40)/2, (CGRectGetHeight(self.containerView.frame) - 40)/2, 40, 40)];
        _animationImgView.layer.cornerRadius = 20;
        _animationImgView.layer.masksToBounds = YES;
        _animationImgView.backgroundColor = UIColor.greenColor;
    }
    return _animationImgView;
}
- (UIView *)baseView{
    if (!_baseView) {
        _baseView = [[UIView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.containerView.frame)- 40)/2, CGRectGetHeight(self.containerView.frame) - 40, 40, 40)];
        _baseView.layer.cornerRadius = 20;
        _baseView.layer.masksToBounds = YES;
        _baseView.backgroundColor = UIColor.blueColor;
        _baseView.hidden = YES;
    }
    return _baseView;
}
- (UIView *)hiddenView{
    if (!_hiddenView) {
        _hiddenView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        _hiddenView.layer.cornerRadius = 20;
        _hiddenView.layer.masksToBounds = YES;
        _hiddenView.backgroundColor = UIColor.redColor;
    }
    return _hiddenView;
}
- (UIDynamicAnimator*)animator{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.containerView];
    }
    return _animator;
}
- (UIPushBehavior *)push{
    if (!_push) {
        _push = [[UIPushBehavior alloc]initWithItems:@[self.hiddenView] mode:UIPushBehaviorModeInstantaneous];
        _push.angle = 0.0;
        _push.magnitude = 0.0;
    }
    return _push;
}
- (UICollisionBehavior *)collision{
    if (!_collision) {
        _collision = [[UICollisionBehavior alloc]initWithItems:@[self.animationImgView,self.hiddenView]];
        _collision.collisionMode = UICollisionBehaviorModeEverything;
        _collision.translatesReferenceBoundsIntoBoundary = YES;
        _collision.collisionDelegate = self;
    }
    return _collision;
}
@end
