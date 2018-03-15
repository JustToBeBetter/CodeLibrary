//
//  TopBar.m
//  KillGame
//
//  Created by 李金柱 on 2017/8/15.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import "TopBar.h"
#define kDevice_Is_iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define kScreenSize  [UIScreen mainScreen].bounds.size
#define kBarFontText  @"PingFangSC-Regular"
#define kBarTitleSize   kDevice_Is_iPhone5?(12):(14)
#define kSelectedColor [UIColor colorWithRed:0.53 green:0.37 blue:0.91 alpha:1.00]
#define kNormalColor [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1.00]
#define kMarkViewWidth 100

#define kPagesNumber 5

@interface TopBar ()

@property (nonatomic, strong) UIView *markView;
@property (nonatomic, strong) NSMutableArray *buttons;
@end
@implementation TopBar

- (void)setTitles:(NSMutableArray *)titles {
    
    self.showsHorizontalScrollIndicator = NO;
    self.scrollsToTop = NO;
    _titles = titles;
    self.buttons = [NSMutableArray array];
    CGFloat buttonW = kScreenSize.width/kPagesNumber;
    self.contentSize = CGSizeMake(buttonW *titles.count, 0);
    
    for (int i = 0; i < titles.count; i++) {
        if ([_titles[i] isKindOfClass:[NSNull class]]) {
            continue;
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:_titles[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:kBarFontText size:kBarTitleSize];
        [button setTitleColor:kNormalColor forState:UIControlStateNormal];
        button.frame = CGRectMake(buttonW * i, 0,buttonW, kTopbarHeight);
        
        [self addSubview:button];
        [self.buttons addObject:button];
    }
    
    //markView 动画
    UIButton *firstButton = self.buttons.firstObject;
    CGRect frame = firstButton.frame;
    self.markView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x + (frame.size.width - kMarkViewWidth)/2, CGRectGetMaxY(frame)-2, kMarkViewWidth, 2)];
    _markView.backgroundColor = kSelectedColor;
    [self addSubview:_markView];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.markView.frame)-0.5, buttonW *titles.count, 0.5)];
    line.backgroundColor =[UIColor colorWithRed:233/255 green:233/255 blue:233/255 alpha:0.1];
    [self addSubview:line];
}

- (void)buttonClick:(id)sender {
    
    self.currentPage = [self.buttons indexOfObject:sender];
    //    [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshOrderList" object:nil];
    for (UIButton *btn in self.buttons) {
        if (btn.tag == self.currentPage) {
            btn.titleLabel.font = [UIFont fontWithName:kBarFontText size:kBarTitleSize];
            [btn setTitleColor:kSelectedColor forState:UIControlStateNormal];
            
        }else{
            btn.titleLabel.font = [UIFont fontWithName:kBarFontText size:kBarTitleSize];
            [btn setTitleColor:kNormalColor forState:UIControlStateNormal];
        }
    }
    if (_blockHandler) {
        _blockHandler(_currentPage);
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    
    _currentPage = currentPage;
    for (UIButton *btn in self.buttons) {
        if (btn.tag == _currentPage) {
            btn.titleLabel.font = [UIFont fontWithName:kBarFontText size:kBarTitleSize];
            [btn setTitleColor:kSelectedColor forState:UIControlStateNormal];
            
        }else{
            btn.titleLabel.font = [UIFont fontWithName:kBarFontText size:kBarTitleSize];
            [btn setTitleColor:kNormalColor forState:UIControlStateNormal];
            
        }
    }
   
    //markView 动画
    UIButton *button = [_buttons objectAtIndex:_currentPage];
    CGRect frame = button.frame;
    frame.origin.x -= 5;
    frame.size.width += 10;
    [self scrollRectToVisible:frame animated:YES];
    if (currentPage >= kPagesNumber ) {
        
      [self setContentOffset:CGPointMake(frame.size.width *(currentPage - kPagesNumber+1), 0) animated:NO];
    }else{
        [self setContentOffset:CGPointMake(0, 0)];
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.markView.frame = CGRectMake(button.frame.origin.x + (button.frame.size.width - kMarkViewWidth)/2 , CGRectGetMaxY(button.frame)-3, kMarkViewWidth, 3);
    } completion:nil];
}
@end
