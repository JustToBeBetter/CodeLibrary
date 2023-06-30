//
//  NSString+Tools.h
//  CodeLibrary
//
//  Created by yk on 2023/6/27.
//  Copyright © 2023 李金柱. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Tools)

/** json字符串转 dic*/
- (NSDictionary *_Nullable)jsonStringTodictionary;

+ (NSString *)pinyinFromChineseString:(NSString *)string;

- (BOOL)isValidChinese;

- (NSString*)pinYin;
@end

NS_ASSUME_NONNULL_END
