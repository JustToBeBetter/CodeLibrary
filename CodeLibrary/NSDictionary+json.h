//
//  NSDictionary+json.m

#import <Foundation/Foundation.h>

@interface NSDictionary (json)

- (NSString *)jsonString:(NSString *)key;
- (NSDictionary *)jsonDict:(NSString *)key;
- (NSArray *)jsonArray:(NSString *)key;
- (NSArray *)jsonStringArray:(NSString *)key;
- (BOOL)jsonBool:(NSString *)key;
- (NSInteger)jsonInteger:(NSString *)key;
- (long long)jsonLongLong:(NSString *)key;
- (unsigned long long)jsonUnsignedLongLong:(NSString *)key;
- (double)jsonDouble:(NSString *)key;

@end
