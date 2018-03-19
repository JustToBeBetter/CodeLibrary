//
//  FloatingViewViewController.m
//  CodeLibrary
//
//  Created by lijz on 2018/3/19.
//  Copyright © 2018年 李金柱. All rights reserved.
//

#import "FloatingViewViewController.h"
#import "LJZFloatingView.h"

@interface FloatingViewViewController ()<LJZFloatingViewDelegate>
{
    BOOL _isPath;
    NSArray *_xArr;
    NSArray *_yArr;
}
@property (nonatomic, strong) LJZFloatingView  *ljzfloatView;

@end

@implementation FloatingViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    
}
- (void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    [self createBtn];
    [self.view addSubview:self.ljzfloatView];
    
}
- (void)createBtn{
    
    NSArray *images = @[@"wdzy",@"wopa",@"bdsc",@"yxgs"];
    for(int i = 0;i < images.count; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 56, 56);
        btn.hidden = YES;
        btn.center = self.ljzfloatView.center;
        [btn setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1000+i;
        [self.view addSubview:btn];
    }
}
-(void)pathDown
{
    
    if(_isPath == NO){
        for(int i = 0;i<4;i++){
            UIButton *btn = (UIButton*)[self.view viewWithTag:1000+i];
            btn.hidden = NO;
            btn.transform = CGAffineTransformMakeRotation(M_PI);
            [UIView animateWithDuration:0.5 animations:^{
                btn.frame = CGRectMake([_xArr[i] intValue], [_yArr[i] intValue], 56, 56);
                
                btn.transform = CGAffineTransformMakeRotation(2*M_PI);
            } completion:nil];
        }
        _isPath = YES;
    }else{
        
        for(int i = 0;i<4;i++){
            UIButton *btn = (UIButton*)[self.view viewWithTag:1000+i];
            [UIView animateWithDuration:0.5 animations:^{
                btn.frame = CGRectMake(0,0, 56, 56);
                btn.center = self.ljzfloatView.center;
                btn.transform = CGAffineTransformMakeRotation(M_PI);
            } completion:^(BOOL finished) {
                if (finished) {
                    btn.hidden = YES;
                }
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
            UIButton *btn = (UIButton*)[self.view viewWithTag:1000+i];
            [UIView animateWithDuration:0.5 animations:^{
                btn.frame = CGRectMake(0,0, 56, 56);
                btn.center = self.ljzfloatView.center;
                btn.transform = CGAffineTransformMakeRotation(M_PI);
            } completion:^(BOOL finished) {
                if (finished) {
                    btn.hidden = YES;
                }
            }];
        }
        _isPath = NO;
    }
    
    
}
#pragma mark
#pragma mark =====================delegate=====================
- (void)clickedWithXArray:(NSArray *)xArray yArray:(NSArray *)yArray{
    _xArr = xArray;
    _yArr = yArray;
    [self pathDown];
}
- (void)dragWithPoint:(CGPoint)center dragState:(UIGestureRecognizerState)state{
    
    _isPath = NO;
    for(int i = 0;i<4;i++){
        UIButton *btn = (UIButton*)[self.view viewWithTag:1000+i];
        btn.center = center;
    }
 
}
- (LJZFloatingView *)ljzfloatView{
    if (_ljzfloatView == nil) {
        _ljzfloatView = [[LJZFloatingView alloc]initWithFrame:CGRectMake(300, 300, 75, 75)];
        _ljzfloatView.delegate = self;
    }
    
    return _ljzfloatView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
