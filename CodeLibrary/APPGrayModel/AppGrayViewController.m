//
//  AppGrayViewController.m
//  CodeLibrary
//
//  Created by lijinzhu on 2022/12/1.
//  Copyright © 2022 李金柱. All rights reserved.
//

#import "AppGrayViewController.h"
#import "MMAvatarView.h"
#import "UIImageView+Gray.h"

@interface AppGrayViewController ()

@end

@implementation AppGrayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    self.view.backgroundColor = UIColor.whiteColor;
    [[SDImageCodersManager sharedManager] addCoder:[SDImageWebPCoder sharedCoder]];
    [[SDWebImageDownloader sharedDownloader] setValue:@"image/webp,image/*,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
//    [self testUI];
//    [self showGrayViewInSuperView:self.view];
//    [self filterTest];
//    [self testImgViewGray];
}
- (void)testImgViewGray{
    NSArray *webpArray =   @[@"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-09-29/1664433922363.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-09-21/1663745765475.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-09-21/1663745030591.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-08-30/1661843657224.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-08-06/1659764421354.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-06-29/1656491704481.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-04-21/1650534806109.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-03-25/1648179332124.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-02-25/1645756808205.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642646112541.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642644460847.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642643766102.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642645941636.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642646465626.webp"];
    CGFloat imgW = 100;
    NSInteger numPerLine = 3;
    CGFloat space = (self.view.width - imgW * numPerLine)/(numPerLine + 1);
    for (int i = 0;  i < 12; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(space + imgW *(i%numPerLine), 100 + imgW *(i/numPerLine), imgW, imgW)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        NSURL *url = [NSURL URLWithString:@"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-06-29/1656491704481.webp"];
        if (i < webpArray.count-1) {
            url = [NSURL URLWithString:webpArray[i]];
        }
        [imageView sd_setImageWithURL:url];
        [self.view addSubview:imageView];
    }
}
//CAFilter为苹果私有方法，有被拒可能
- (void)filterTest{
    CGFloat r,g,b,a;
    [[UIColor lightGrayColor] getRed:&r green:&g blue:&b alpha:&a];
    id cls = NSClassFromString(@"CAFilter");
    id filter = [cls filterWithName:@"colorMonochrome"];
    [filter setValue:@[@(r),@(g),@(b),@(a)] forKey:@"inputColor"];
    [filter setValue:@(0) forKey:@"inputBias"];
    [filter setValue:@(1) forKey:@"inputAmount"];
    //也可以设置给window
    self.view.layer.filters = [NSArray arrayWithObject:filter];
}
- (void)testUI{
    NSArray *webpArray =   @[@"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-09-29/1664433922363.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-09-21/1663745765475.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-09-21/1663745030591.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-08-30/1661843657224.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-08-06/1659764421354.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-06-29/1656491704481.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-04-21/1650534806109.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-03-25/1648179332124.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-02-25/1645756808205.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642646112541.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642644460847.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642643766102.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642645941636.webp",
                             @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-01-20/1642646465626.webp"];
    CGFloat imgW = 100;
    NSInteger numPerLine = 3;
    CGFloat space = (self.view.width - imgW * numPerLine)/(numPerLine + 1);
    for (int i = 0;  i < 12; i++) {
        MMAvatarView *avatarView = [[MMAvatarView alloc]initWithFrame:CGRectMake(space + imgW *(i%numPerLine), 100 + imgW *(i/numPerLine), imgW, imgW)];
        avatarView.contentMode = UIViewContentModeScaleAspectFit;
        NSString *micurl = @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-06-29/1656491704481.webp";
        if (i < webpArray.count-1) {
            micurl = webpArray[i];
        }
        [avatarView showWithUid:0 avatar:@"http://murder-mystery.oss-cn-shanghai.aliyuncs.com/th_nGDiObuIKJ.jpg" backgroundAvatar:@"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2021-09-24/1632481127406.gif" clickBlock:^{
        }];
        [avatarView loadMicImgWithMicUrl:micurl showLevle:0];
        [avatarView showMicphoneImg:YES];
        [self.view addSubview:avatarView];
        
//        SDAnimatedImageView *imageView = [[SDAnimatedImageView alloc]initWithFrame:CGRectMake(space + imgW *(i%numPerLine), 100 + imgW *(i/numPerLine), imgW, imgW)];
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        NSURL *url = [NSURL URLWithString:@"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/dressIMG/2022-06-29/1656491704481.webp"];
//        if (i < webpArray.count-1) {
//            url = [NSURL URLWithString:webpArray[i]];
//        }
//        [imageView sd_setImageWithURL:url];
//        [self.view addSubview:imageView];
    }
}

- (void)showGrayViewInSuperView:(UIView *)superView{
    if (@available(iOS 12.0, *)) {//只支持12及以上
        UIView *overlay = [[UIView alloc] initWithFrame:superView.bounds];
        overlay.userInteractionEnabled = NO;
        overlay.translatesAutoresizingMaskIntoConstraints = false;
        overlay.backgroundColor = [UIColor grayColor];
        overlay.layer.compositingFilter = @"saturationBlendMode";
        [superView addSubview:overlay];
        [superView bringSubviewToFront:overlay];
    }
}

@end
