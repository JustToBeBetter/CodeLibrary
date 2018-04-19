//
//  SegmentViewViewController.m
//  CodeLibrary
//
//  Created by lijz on 2018/4/19.
//  Copyright © 2018年 李金柱. All rights reserved.
//

#import "SegmentViewViewController.h"
#import "LJZSegmentView.h"
@interface SegmentViewViewController ()<LJZSegmentedViewDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) LJZSegmentView *segmentedView;
@end

@implementation SegmentViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initNav];
    [self initScrollView];
}
- (void)initScrollView
{
    UIScrollView *mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    mainScrollView.delegate = self;
    mainScrollView.pagingEnabled = YES;
    mainScrollView.scrollEnabled = YES;
    mainScrollView.contentSize = CGSizeMake(kScreenWidth * 2, 0);
    mainScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:mainScrollView];
    
    self.mainScrollView = mainScrollView;
    
    UIViewController *firstVC  = [[UIViewController alloc] init];
    firstVC.view.frame = CGRectMake(0, 0, kScreenWidth, self.mainScrollView.height);
    firstVC.view.backgroundColor = [UIColor blueColor];
    [self addChildViewController:firstVC];
    [self.mainScrollView addSubview:firstVC.view];
    
    UIViewController *secondVC  = [[UIViewController alloc] init];
    secondVC.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, self.mainScrollView.height);
    secondVC.view.backgroundColor = [UIColor orangeColor];
    [self addChildViewController:secondVC];
    [self.mainScrollView addSubview:secondVC.view];
    
}
- (void)initNav{
    
    LJZSegmentView *slideView = [[LJZSegmentView alloc] initWithFrame:CGRectMake(0, 0, 226*kProportion, 30)];
    slideView.delegate = self;
    slideView.selectedViewColor = [UIColor redColor];
    slideView.normalLabelColor  = [UIColor blueColor];
    slideView.titles = @[@"推荐",@"关注"];
    self.segmentedView = slideView;
    self.navigationItem.titleView = slideView;
    self.navigationController.view.backgroundColor = self.navigationController.navigationBar.barTintColor;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - LJZSegmentViewDelegate
- (void)segmentedView:(LJZSegmentView *)segmentedView didSeletIndex:(NSInteger)index{
    [self.mainScrollView setContentOffset:CGPointMake(kScreenWidth *index, 0) animated:YES];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.segmentedView.selectedIndex = scrollView.contentOffset.x/kScreenWidth;
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
