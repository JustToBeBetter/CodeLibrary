//
//  NSMutableArray+safe.h


#import <Foundation/Foundation.h>

@interface NSMutableArray (safe)

- (id)objectAtIndexCheck:(NSUInteger)index;

- (void)addObjectCheck:(id)anObject;

- (void)insertObjectCheck:(id)anObject atIndex:(NSUInteger)index;

- (void)removeObjectAtIndexCheck:(NSUInteger)index;

- (void)replaceObjectAtIndexCheck:(NSUInteger)index withObject:(id)anObject;

- (void)removeObjectsInArrayCheck:(NSArray *)array;

@end

