//
//  NSString+AddMethods.h
//  Live
//
//  Created by wenjie hua on 2017/3/21.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AddMethods)

+ (instancetype)hourMinSecTimeFromSeconds:(int)seconds;
+ (instancetype)hourMinsTimeFromScconds:(int)seconds;
+ (instancetype)MinSecTimeFromSeconds:(int)seconds;
+ (NSString *)urlEncodedByUrl:(NSString *)oldUrl;
//清晰度转对应文字
+ (NSString *)changBitToString:(NSString *)bit;
    
@end
