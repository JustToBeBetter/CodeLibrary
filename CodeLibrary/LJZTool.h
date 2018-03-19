//
//  LJZTool.h
//  zimotv
//
//  Created by 李金柱 on 2017/2/23.
//  Copyright © 2017年 zimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface LJZTool : NSObject

//根据字符串的实际内容的多少 在固定的宽度和字体的大小，动态的计算出实际的高度
+ (CGFloat)textHeightFromTextString:(NSString *)text width:(CGFloat)textWidth fontName:(NSString *)fontName fontSize:(CGFloat)size;
//计算行宽
+(CGFloat)textWidthtFromTextString:(NSString *)text height:(CGFloat)textHeight fontName:(NSString *)fontName fontSize:(CGFloat)size;
//创建label
+ (UILabel *)creatLabelWithFrame:(CGRect)frame text:(NSString *)text fontName:(NSString *)fontName size:(CGFloat)size isAttribute:(BOOL)isAttribute;
+ (UIButton *)creatButtonWithFrame:(CGRect)frame
                            target:(id)target
                               sel:(SEL)sel
                             title:(NSString *)title;
+ (UIButton *)creatButtonWithFrame:(CGRect)frame target:(id)target sel:(SEL)sel tag:(NSInteger)tag image:(NSString *)name title:(NSString *)title;
//判断是否是空字符串
+ (BOOL) isBlankString:(NSString *)string;
//设置是否是有效密码
+ (BOOL)isAvailablePassword:(NSString *)password;
//判断手机号
+ (BOOL)isMobileNumber:(NSString *)numstring;
//身份证验证
+ (BOOL)isAvalidateIdentityCard:(NSString *)identityCard;
//邮箱验证
+ (BOOL)isAvalidateEmail:(NSString *)email;
//获取 当前设备版本
+ (double)getCurrentIOS;
//把一个秒字符串 转化为真正的本地时间
+ (NSString *)dateStringFromNumberTimer:(NSString *)timerStr;

//获取 一个文件 在沙盒Library/Caches/ 目录下的路径
+ (NSString *)getFullPathWithFile:(NSString *)urlName;
//检测 缓存文件 是否超时
+ (BOOL)isTimeOutWithFile:(NSString *)filePath timeOut:(double)timeOut ;

//json字符串转json对象
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
@end
