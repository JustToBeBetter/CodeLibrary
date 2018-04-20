//
//  DXModel.m
//  Live
//  基础模型
//  Created by 戴奕 on 2017/3/24.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "DXModel.h"
#import <objc/runtime.h>

@interface DXModel ()

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation DXModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        [self populateWithDic:dic];
    }
    return self;
}

+ (NSArray *)modelsFromArr:(NSArray *)arr {
    if (![arr isKindOfClass:[NSArray class]]) {
        return @[];
    }
    NSMutableArray *marr = [[NSMutableArray alloc]initWithCapacity:arr.count];
    Class cls = [self class];
    for (NSDictionary *dic in arr) {
        id model = [[cls alloc]initWithDic:dic];
        [marr addObject:model];
    }
    return [NSArray arrayWithArray:marr];
}

- (void)populateWithDic:(NSDictionary *)dic {
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    Class cls = [self class];
    unsigned int count;
    
    objc_property_t *properties =class_copyPropertyList(cls, &count);
    
    for (int i = 0; i < count; i ++) {
        objc_property_t property = properties[i];
        
        const char* name = property_getName(property);
        
        NSMutableString *ocName = [NSMutableString stringWithUTF8String:name];
        
        
        if ([self.array containsObject:ocName]) {
            [ocName replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        
        NSString *key = [ocName copy];
        
        id value = dic[key];
        //数组不处理，只处理一层和二层JCModel数据
        if ([value isKindOfClass:[NSDictionary class]]){
            //字典也是通过JCModel的子类方法进行解析
            const char* str = property_getAttributes(property);
            NSMutableString *strProperty = [NSMutableString stringWithUTF8String:str];
            NSArray *arry=[strProperty componentsSeparatedByString:@"\""];
            if (arry.count >= 3) {
                NSString * strPropertyClass = arry[1];
                Class clsProperty = NSClassFromString(strPropertyClass);
                id model = [[clsProperty alloc]initWithDic:value];//这里应该加一个判断，但由于规范中限定了，就不用了
                [self setValue:model forKey:ocName];
            }
        }else if (![value isKindOfClass:[NSArray class]] && value != nil && value != [NSNull null]){
            NSString *mOCName = [NSString stringWithFormat:@"m%@",ocName];
            if ([self.array containsObject:mOCName]) {
                ocName = [[NSMutableString alloc]initWithString:mOCName];
            }
            
            const char * type = property_getAttributes(property);
            NSString *attr = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
            
            if ([attr hasPrefix:@"T@\"NSString\""] ) {
                if([value isKindOfClass:[NSString class]]){
                    [self setValue:value forKey:ocName];
                }else{
                    [self setValue:[NSString stringWithFormat:@"%@",value] forKey:ocName];
                }
            }else{
                [self setValue:value forKey:ocName];
            }
        }

    }
    free(properties);
}

- (NSMutableArray *)array{
    if (_array == nil) {
        _array = [[NSMutableArray alloc] initWithObjects:@"mid",@"mstatic",nil];
    }
    return _array;
}


@end
