//
//  NSArray+safe.m


#import "NSArray+safe.h"

@implementation NSArray (safe)

-(id)objectAtIndexCheck:(NSUInteger)index{
    if (index < self.count) {
        return [self objectAtIndex:index];
    }
    return nil;
}

@end
