//
//  FaceDetectView.m
//  MNNKitDemo
//
//  Created by tsia on 2019/12/24.
//  Copyright © 2019 tsia. All rights reserved.
//

#import "FaceDetectView.h"

#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

@interface FaceDetectView()

@property (nonatomic, strong) UILabel *lbYpr;
@property (strong, nonatomic) UILabel *lbFaceAction;

@end

@implementation FaceDetectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.lbYpr = [[UILabel alloc] init];
        self.lbYpr.textColor = [UIColor greenColor];
        self.lbYpr.numberOfLines = 0;
        [self addSubview:self.lbYpr];
        
        self.lbFaceAction = [[UILabel alloc] init];
        self.lbFaceAction.textColor = [UIColor greenColor];
        self.lbFaceAction.numberOfLines = 1;
        self.lbFaceAction.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lbFaceAction];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [self.lbYpr sizeThatFits:CGSizeMake(150, CGFLOAT_MAX)];
    self.lbYpr.frame = CGRectMake(self.frame.size.width-size.width-4, self.uiOffsetY+4, size.width, size.height);
    
    size = [self.lbFaceAction sizeThatFits:CGSizeMake(CGFLOAT_MAX, 30)];
    self.lbFaceAction.frame = CGRectMake(self.frame.size.width-size.width-8, CGRectGetMaxY(self.lbYpr.frame)+10, size.width, size.height);
}

-(void)setUseRedColor:(BOOL)useRedColor {
    _useRedColor = useRedColor;
    
    if (useRedColor) {
        self.lbYpr.textColor = [UIColor redColor];
    }
}



@end
