//
//  PhotoMakerViewController.m
//  CodeLibrary
//
//  Created by 李金柱 on 2019/2/16.
//  Copyright © 2019年 李金柱. All rights reserved.
//

#import "PhotoMakerViewController.h"
#import "LJZPhotoMaker.h"
@interface PhotoMakerViewController ()

@end

@implementation PhotoMakerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self showImage];
}
- (void)showImage{
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    imgView.center = self.view.center;
//    UIImage *firstImage = [UIImage imageNamed:@"pic1"];
//    UIImage *SecondImage = [UIImage imageNamed:@"pic2"];
//    UIImage *thirdImage = [UIImage imageNamed:@"pic3"];
//    UIImage *fourImage = [UIImage imageNamed:@"pic4"];
    
    NSString *fUrl = @"https://dpic.tiankong.com/26/3s/QJ6781149307.jpg?x-oss-process=style/450hs";
    NSString *sUrl = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1550316096666&di=1dc51ed974534c372e902cf53dd91052&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2Fe4dde71190ef76c6ace1b8399716fdfaaf5167f4.jpg";
    NSString *tUrl = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1550316096667&di=6cdf077c4228a76204f008088a0d5275&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F1b4c510fd9f9d72a4cd13c08de2a2834349bbb69.jpg";
    NSString *foUrl = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1550316096667&di=66bbd36cd56daee6dd62df8ddea9ed64&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2F48540923dd54564eb6d4a42bb9de9c82d1584f6a.jpg";
    NSData *fData = [NSData dataWithContentsOfURL:[NSURL URLWithString:fUrl]];
    NSData *sData = [NSData dataWithContentsOfURL:[NSURL URLWithString:sUrl]];
    NSData *tData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tUrl]];
    NSData *foData = [NSData dataWithContentsOfURL:[NSURL URLWithString:foUrl]];
    
    UIImage * firstImage = [UIImage imageWithData:fData];
    UIImage * SecondImage = [UIImage imageWithData:sData];
    UIImage *thirdImage = [UIImage imageWithData:tData];
    UIImage *fourImage = [UIImage imageWithData:foData];
    
    NSArray *images = @[firstImage,SecondImage,thirdImage,fourImage];
    
    imgView.image = [LJZPhotoMaker makePhtoWithImages:images];
    [self.view addSubview:imgView];
   
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
