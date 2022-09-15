//
//  LJZPlayerViewController.m

//  Created by maopao on 2019/3/20.
//

#import "LJZPlayerViewController.h"
#import "LJZPlayerView.h"

#define kAnimationDuration          0.35f

@interface LJZPlayerViewController ()
{
      CGPoint  _startLocation;
}
@property (nonatomic, strong) LJZPlayerView *playerView;
/** 状态栏正在发生变化 */
@property (nonatomic, assign) BOOL isStatusBarChanged;
/** 状态栏是否显示 */
@property (nonatomic, assign) BOOL isStatusBarShowing;
/** 是否显示状态栏，默认NO：不显示状态栏 */
@property (nonatomic, assign) BOOL isStatusBarShow;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) UIColor   *bgColor;
@end

@implementation LJZPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}
- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view  addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    WeakSelf(self);
    self.playerView.closeBlock = ^{
        [weakself dismissViewControllerAnimated:YES completion:nil];
    };
    NSString *path = [[NSBundle mainBundle]pathForResource:@"IMG_0088" ofType: @"mp4"];
    [self.playerView playWithUrl:[NSURL fileURLWithPath:path]];
    
    [self.view addGestureRecognizer:self.panGesture];
    
    self.playerView.dragingBlock = ^(BOOL isDraging) {
        if (isDraging) {
            weakself.panGesture.enabled = NO;
        }else{
            weakself.panGesture.enabled = YES;
        }
    };

}

- (void)dealloc{
    [self.playerView.player stopPlay];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {

    [self handlePanZoomScale:panGesture];
}
- (void)handlePanZoomScale:(UIPanGestureRecognizer *)panGesture {
    CGPoint point       = [panGesture translationInView:self.view];
    CGPoint location    = [panGesture locationInView:self.view];
    CGPoint velocity    = [panGesture velocityInView:self.view];


    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            double percent = 1 - fabs(point.y) / self.view.frame.size.height;
            percent  = MAX(percent, 0);
            double s = MAX(percent, 0.5);

            CGAffineTransform translation = CGAffineTransformMakeTranslation(point.x / s, point.y / s);
            CGAffineTransform scale = CGAffineTransformMakeScale(s, s);
           self.playerView.transform = CGAffineTransformConcat(translation, scale);

            self.view.backgroundColor = self.bgColor ? [self.bgColor colorWithAlphaComponent:percent] : [[UIColor blackColor] colorWithAlphaComponent:percent];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showDismissAnimation];
            }else {
                [self showCancelAnimation];
            }
        }
            break;
        default:
            break;
    }
}
- (void)showDismissAnimation {

    CGRect sourceRect = self.sourceView.frame;

    if (!CGRectEqualToRect(sourceRect, CGRectZero)) {
        if (self.sourceView == nil) {
            [UIView animateWithDuration:kAnimationDuration animations:^{
                self.view.alpha = 0;
            }completion:^(BOOL finished) {
                [self dismissAnimated:NO];
            }];
            return;
        }
        float systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
        if (systemVersion >= 8.0 && systemVersion < 9.0) {
            sourceRect = [ self.sourceView.superview convertRect: self.sourceView.frame toCoordinateSpace:self.playerView];
        }else {
            sourceRect = [self.sourceView.superview convertRect:self.sourceView.frame toView:self.playerView];
        }

    }else{
        sourceRect = CGRectMake(self.view.bounds.size.width/2 - 50, self.view.bounds.size.height, 100, 100);
    }
   

    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.playerView.frame = sourceRect;
        self.view.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        [self dismissAnimated:NO];


    }];
}
- (void)dismissAnimated:(BOOL)animated {
 
    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.playerView.alpha = 1.0;
        }];
    }else {
       self.playerView.alpha = 1.0;
    }
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)handlePanBegin {
  
    _isStatusBarShowing = self.isStatusBarShow;

    // 显示状态栏
    self.isStatusBarShow = YES;

}

- (void)showCancelAnimation {
 
    self.playerView.alpha = 1.0;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.playerView.transform = CGAffineTransformIdentity;
        self.view.backgroundColor = self.bgColor ? : [UIColor blackColor];
    }completion:^(BOOL finished) {
        if (!self.isStatusBarShowing) {
            // 隐藏状态栏
            self.isStatusBarShow = NO;
        }
    }];
}

- (void)setIsStatusBarShow:(BOOL)isStatusBarShow {
    _isStatusBarShow = isStatusBarShow;

    /**这一行代码打开，在有些情况下会出现pageControl位置不正确的bug */
    //    self.isStatusBarChanged = YES;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isStatusBarChanged = NO;
    });

    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];

        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}
- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    }
    return _panGesture;
}
- (LJZPlayerView *)playerView{
    if (_playerView == nil) {
        _playerView = [[LJZPlayerView alloc]init];
    }
    return _playerView;
}
@end
