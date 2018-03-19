//
//  LJZFloatingView.m
//  CodeLibrary
//
//  Created by lijz on 2018/3/19.
//  Copyright © 2018年 李金柱. All rights reserved.
//

#import "LJZFloatingView.h"

#define SCREEN_WIDTH        ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT        ([UIScreen mainScreen].bounds.size.height)

@interface LJZFloatingView() {
    
    // 当前坐标
    CGPoint _curPoint;
    // 开始坐标
    CGPoint _beganPoint;
    
    BOOL _isPath;
    
    NSArray *_xArr;
    NSArray *_yArr;
    
}
@property (nonatomic, strong) UIView *tmpView;
// 图标
@property (nonatomic, strong) UIImageView *iconImageView;

// 上边距(默认值:0)
@property (nonatomic, assign) CGFloat upEdgeDistance;
// 下边距(默认值:SCREEN_HEIGHT)
@property (nonatomic, assign) CGFloat downEdgeDistance;
// 左边距(默认值:0)
@property (nonatomic, assign) CGFloat leftEdgeDistance;
// 右边距(右边距:SCREEN_WIDTH)
@property (nonatomic, assign) CGFloat rightEdgeDistance;

@end
@implementation LJZFloatingView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        // 添加 手势
        [self addPanGestureRecognizer];
        // 设置 默认 边距
        [self setupDefaultEdgeDistance];
        //  [self createBtn];
        // 图标
        [self addSubview:self.iconImageView];
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    return self;
}
- (void)createBtn{
    
    NSArray *images = @[@"wdzy",@"wopa",@"bdsc",@"yxgs"];
    for(int i = 0;i < images.count; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 56, 56);
        btn.hidden = YES;
        btn.center = self.center;
        [btn setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1000+i;
        [[UIApplication sharedApplication].keyWindow addSubview:btn];
    }
}
-(void)pathDown
{
    
    if(_isPath == NO){
        for(int i = 0;i<4;i++){
            UIButton *btn = (UIButton*)[[UIApplication sharedApplication].keyWindow viewWithTag:1000+i];
            btn.hidden = NO;
            btn.transform = CGAffineTransformMakeRotation(M_PI);
            [UIView animateWithDuration:1 animations:^{
                btn.frame = CGRectMake([_xArr[i] intValue], [_yArr[i] intValue], 56, 56);
                
                btn.transform = CGAffineTransformMakeRotation(2*M_PI);
            } completion:nil];
        }
        _isPath = YES;
    }else{
        
        for(int i = 0;i<4;i++){
            UIButton *btn = (UIButton*)[[UIApplication sharedApplication].keyWindow viewWithTag:1000+i];
            [UIView animateWithDuration:1 animations:^{
                btn.frame = CGRectMake(0,0, 56, 56);
                btn.center = self.center;
                btn.transform = CGAffineTransformMakeRotation(M_PI);
            } completion:^(BOOL finished) {
                
                btn.hidden = YES;
                
            }];
        }
        _isPath = NO;
        
    }
    
}
-(void)btnDown:(UIButton*)btn
{
    NSLog(@"现在点击了第%ld个btn",btn.tag-1000);
    //还可以进行界面跳转
    
    //收回去
    if (_isPath) {
        for(int i = 0;i<4;i++){
            UIButton *btn = (UIButton*)[[UIApplication sharedApplication].keyWindow viewWithTag:1000+i];
            [UIView animateWithDuration:1 animations:^{
                btn.frame = CGRectMake(0,0, 56, 56);
                btn.center = self.center;
                btn.transform = CGAffineTransformMakeRotation(M_PI);
            } completion:^(BOOL finished) {
                btn.hidden = YES;
                
            }];
        }
        _isPath = NO;
    }
    
    
}
#pragma mark --- private method
// 添加 手势
- (void)addPanGestureRecognizer {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
    [self addGestureRecognizer:tap];
}
// 设置 默认 边距
- (void)setupDefaultEdgeDistance {
    // 左边距
    self.leftEdgeDistance = 0;
    // 右边距
    self.rightEdgeDistance = SCREEN_WIDTH;
    // 上边距
    self.upEdgeDistance = 0;
    // 下边距
    self.downEdgeDistance = SCREEN_HEIGHT;
}

#pragma mark --- response event
- (void)click:(UITapGestureRecognizer *)tap{
    [self clickEvent];
    //    [[self class]cancelPreviousPerformRequestsWithTarget:self selector:@selector(clickEvent) object:nil];
    //
    //    [self performSelector:@selector(clickEvent) withObject:nil afterDelay:0.2];
    
}
- (void)clickEvent{
    CGFloat centerX = self.center.x;
    CGFloat centerY = self.center.y;
    CGFloat x1 = 0,x2 = 0,x3 = 0,x4 = 0;
    CGFloat y1 = 0,y2 = 0,y3 = 0,y4 = 0;
    if (centerX > 108 && centerY > 109 + 80 && centerY < SCREEN_HEIGHT - 53 - 63) {//居中及靠右正常显示
        x1 = centerX - 28;
        x2 = centerX - 108;
        x3 = centerX - 108;
        x4 = centerX - 28;
        
        y1 = centerY - 109;
        y2 = centerY - 73;
        y3 = centerY + 17;
        y4 = centerY + 53;
    }else if (centerX < 108 && (centerY > 109 + 80  && centerY < SCREEN_HEIGHT - 53 - 63)){//靠左
        
        x1 = centerX - 28;
        x2 = centerX + 50;
        x3 = centerX + 50;
        x4 = centerX - 28;
        
        y1 = centerY - 109;
        y2 = centerY - 73;
        y3 = centerY + 17;
        y4 = centerY + 53;
    }else if (centerX > 108 && centerY < 109){//顶中部
        
        x1 = centerX - 109;
        x2 = centerX - 73 ;
        x3 = centerX + 17;
        x4 = centerX + 53;
        
        y1 = centerY - 28;
        y2 = centerY + 50;
        y3 = centerY + 50;
        y4 = centerY - 28;
        
    }else if (centerX > 108 && centerY > SCREEN_HEIGHT - 53 - 63){//底中部
        
        x1 = centerX - 109;
        x2 = centerX - 73 ;
        x3 = centerX + 17;
        x4 = centerX + 53;
        
        y1 = centerY - 28;
        y2 = centerY - 106;
        y3 = centerY - 106;
        y4 = centerY - 28;
        
    }else if (centerX < 108 && centerY < 109){//左上
        
        x1 = centerX + 53;
        x2 = centerX + 42;
        x3 = centerX + 12.5;
        x4 = centerX - 28;
        
        y1 = centerY - 28;
        y2 = centerY + 12.5;
        y3 = centerY + 42;
        y4 = centerY + 53;
        
    }else{
        x1 = centerX - 28;
        x2 = centerX - 108;
        x3 = centerX - 108;
        x4 = centerX - 28;
        
        y1 = centerY - 109;
        y2 = centerY - 73;
        y3 = centerY + 17;
        y4 = centerY + 53;
    }
    NSArray *xArray = @[@(x1),@(x2),@(x3),@(x4)];
    NSArray *yArray = @[@(y1),@(y2),@(y3),@(y4)];
    if (self.delegate &&[self.delegate respondsToSelector:@selector(clickedWithXArray:yArray:)]) {
        [self.delegate clickedWithXArray:xArray yArray:yArray];
    }
}
-(void)pan:(UIPanGestureRecognizer *)sender {
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            _beganPoint = [sender locationInView:self.superview];
            _curPoint = self.center;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [sender locationInView:self.superview];
            
            if (point.y < 200) {
                point.y = 200;
            }
            if (point.y > SCREEN_HEIGHT - 150) {
                point.y = SCREEN_HEIGHT - 150;
            }
            
            NSInteger x_offset = point.x - _beganPoint.x;
            NSInteger y_offset = point.y - _beganPoint.y;
            self.tmpView.center = self.center;
            self.tmpView.center = CGPointMake(_curPoint.x + x_offset, _curPoint.y + y_offset);
            // 设置 左边距
            if (CGRectGetMinX(self.tmpView.frame) < self.leftEdgeDistance){
                x_offset -= CGRectGetMinX(self.tmpView.frame);
            }
            // 设置 右边距
            if (CGRectGetMaxX(self.tmpView.frame) > self.rightEdgeDistance) {
                x_offset += SCREEN_WIDTH - CGRectGetMaxX(self.tmpView.frame);
            }
            // 设置 上边距
            if (CGRectGetMinY(self.tmpView.frame) < self.upEdgeDistance) {
                y_offset -= CGRectGetMinY(self.tmpView.frame);
            }
            // 设置 下边距
            if (CGRectGetMaxY(self.tmpView.frame) > self.downEdgeDistance) {
                y_offset += self.downEdgeDistance - CGRectGetMaxY(self.tmpView.frame);
            }
            
            self.center = CGPointMake(_curPoint.x + x_offset, _curPoint.y + y_offset);
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            CGPoint point = [sender locationInView:self.superview];
            
            if (point.y < 200) {
                point.y = 200;
            }
            if (point.y > SCREEN_HEIGHT - 150) {
                point.y = SCREEN_HEIGHT - 150;
            }
            NSInteger y_offset = point.y - _beganPoint.y;
            if (point.x > SCREEN_WIDTH/2) {
                self.center = CGPointMake(SCREEN_WIDTH - 45, _curPoint.y + y_offset);
            }
            if (point.x < SCREEN_WIDTH/2) {
                self.center = CGPointMake(45, _curPoint.y + y_offset);
            }
        }
            break;
        default:
            break;
    }
    if (self.delegate &&[self.delegate respondsToSelector:@selector(dragWithPoint:dragState:)]) {
        [self.delegate dragWithPoint:self.center dragState:sender.state];
    }
}


// 图标
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _iconImageView.image = [UIImage imageNamed:@"sc"];
        _iconImageView.clipsToBounds = YES;
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        
    }
    return _iconImageView;
}

// 中间view 用来计算位置
- (UIView *)tmpView {
    if (!_tmpView) {
        _tmpView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _tmpView;
}

@end
