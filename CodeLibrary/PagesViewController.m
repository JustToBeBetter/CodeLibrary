
//
//  PagesViewController.m
//  CodeLibrary
//
//  Created by 李金柱 on 2017/8/24.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import "PagesViewController.h"
#import "TopBar.h"
#import "LJZFirstViewController.h"
#import "LJZSecondViewController.h"

@interface PagesViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TopBar *topbar;
@end

@implementation PagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = YES;
    self.automaticallyAdjustsScrollViewInsets = YES;
    //设置CGRectZero从导航栏下开始计算
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    [self iniUI];
}
- (void)iniUI{
    
    NSMutableArray *controllers = [[NSMutableArray alloc]init];
    NSArray *names = @[@"LJZFirstViewController",
                       @"LJZSecondViewController",
                       @"LJZFirstViewController",
                       @"LJZSecondViewController",
                       @"LJZFirstViewController",
                       @"LJZSecondViewController",
                       @"LJZFirstViewController",
                       @"LJZSecondViewController"];
    NSArray *titles = @[@"第一页",@"第二页",@"第三页",@"第四页",@"第五页",@"第六页",@"第七页",@"第八页"];
    for (NSInteger i = 0; i < names.count; i++) {
        Class vcClass = NSClassFromString(names[i]);
        UIViewController * vc = [[vcClass alloc] init];
        [controllers addObject:vc];
    }
    
    self.topbar.titles = [NSMutableArray arrayWithArray:titles];
    self.viewControllers = controllers;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.topbar];
    
}
- (id)initWithViewControllers:(NSArray *)viewControllers {
    if (self = [super init]) {
        _viewControllers = viewControllers;
    }
    return self;
}
- (TopBar *)topbar {
    
    if (!_topbar) {
        _topbar = [[TopBar alloc] initWithFrame:CGRectMake(0,0,kScreenWidth, kTopbarHeight)];
        _topbar.scrollsToTop = NO;
        __block PagesViewController *_self = self;
        _topbar.blockHandler = ^(NSInteger currentPage) {
            [_self setCurrentPage:currentPage];
        };
        [self.view addSubview:_topbar];
    }
    return _topbar;
}

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topbar.frame), kScreenWidth,kScreenHeight - kTopbarHeight)];
        _scrollView.delegate                       = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator   = NO;
        _scrollView.bounces                        = NO;
        _scrollView.pagingEnabled                  = YES;
        _scrollView.scrollsToTop                   = NO;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = [NSArray arrayWithArray:viewControllers];
    CGFloat x = 0.0;
    for (UIViewController *viewController in _viewControllers) {
        [viewController willMoveToParentViewController:self];
        viewController.view.frame = CGRectMake(x, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        [self.scrollView addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
        
        x += CGRectGetWidth(self.scrollView.frame);
        _scrollView.contentSize   = CGSizeMake(x, _scrollView.frame.size.width);
    }
    
    //self.topbar.titles = [_viewControllers valueForKey:@"title"];
    //设置偏移量以及指示器
    self.currentPage = [self.page integerValue];
    self.topbar.currentPage = self.currentPage;
    
    
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    [self.scrollView setContentOffset:CGPointMake(_currentPage*_scrollView.frame.size.width, 0) animated:NO];
}

- (void)layoutSubViews
{
    
    CGFloat x = 0.0;
    for (UIViewController *viewController in self.viewControllers) {
        viewController.view.frame = CGRectMake(x, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        x += CGRectGetWidth(self.scrollView.frame);
    }
    self.scrollView.contentSize   = CGSizeMake(x, _scrollView.frame.size.width);
    self.scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0);
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_scrollView]) {
        NSInteger currentPage = _scrollView.contentOffset.x / _scrollView.frame.size.width;
        _topbar.currentPage   = currentPage;
        _currentPage = currentPage;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
