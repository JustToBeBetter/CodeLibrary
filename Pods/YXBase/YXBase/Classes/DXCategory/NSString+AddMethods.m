//
//  NSString+AddMethods.m
//  Live
//
//  Created by wenjie hua on 2017/3/21.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "NSString+AddMethods.h"

@implementation NSString (AddMethods)
+ (instancetype)hourMinSecTimeFromSeconds:(int)seconds{
    int secs = seconds % 60;
    int mins = ((seconds - secs) % 3600)/60;
    int hours = seconds/3600;
    NSString *strSecs = [NSString addZeroByInt:secs];
    NSString *strMins = [NSString addZeroByInt:mins];
    NSString *strHours = [NSString addZeroByInt:hours];
    
    return [NSString stringWithFormat:@"%@:%@:%@",strHours,strMins,strSecs];
    
}

+ (instancetype)MinSecTimeFromSeconds:(int)seconds{
    int secs = seconds % 60;
    int mins = ((seconds - secs) % 3600)/60+seconds/3600*60;
    NSString *strSecs = [NSString addZeroByInt:secs];
    NSString *strMins = [NSString addZeroByInt:mins];
    return [NSString stringWithFormat:@"%@:%@",strMins,strSecs];
    
}

+ (instancetype)hourMinsTimeFromScconds:(int)seconds{
    int secs = seconds % 60;
    int mins = ((seconds - secs) % 3600)/60;
    int hours = seconds/3600;
    
    if (hours>0)
    {
        return [NSString stringWithFormat:@"%d小时%d分钟%d秒",hours,mins,secs];
    }
    else
    {
        if (mins > 0) {
            return [NSString stringWithFormat:@"%d分钟%d秒",mins,secs];
        }else{
            return [NSString stringWithFormat:@"%d秒",secs];
        }
    }
}

+ (NSString *)addZeroByInt:(int)num{
    if (num < 10) {
        if (num == 0) {
            return @"00";
        }else {
            return [NSString stringWithFormat:@"0%d",num];
        }
    }else {
        return [NSString stringWithFormat:@"%d",num];

    }
}
    
+ (NSString *)urlEncodedByUrl:(NSString *)oldUrl{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              
                                                              (CFStringRef)oldUrl,
                                                              
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              
                                                              NULL,
                                                              
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

+ (NSString *)changBitToString:(NSString *)bit{
    NSString *BitStr;
    if ([bit isEqualToString:@"240P"]) {
        BitStr = @"流畅";
    }
    if ([bit isEqualToString:@"480P"]) {
        BitStr = @"标清";
    }
    if ([bit isEqualToString:@"720P"]) {
        BitStr = @"高清";
    }
    if ([bit isEqualToString:@"1080P"]) {
        BitStr = @"1080P";
    }
    
    return BitStr;
}


@end
