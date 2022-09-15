//
//  LJZLogFormatter.m
//  CodeLibrary
//

#import "LJZLogFormatter.h"
#import <libkern/OSAtomic.h>

@interface LJZLogFormatter ()
{
    //thread safe
    int atomicLoggerCounter;
    NSDateFormatter *threadUnsafeDateFormatter;
}

@end

@implementation LJZLogFormatter

- (NSString *)stringFromDate:(NSDate *)date {
    int32_t loggerCount = OSAtomicAdd32(0, &atomicLoggerCounter);
    NSString *dateFormatString = @"yyyy-MM-dd HH:mm:ss";
    if (loggerCount <= 1) {
        // Single-threaded mode.
        
        if (threadUnsafeDateFormatter == nil) {
            threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
            [threadUnsafeDateFormatter setDateFormat:dateFormatString];
        }
        
        return [threadUnsafeDateFormatter stringFromDate:date];
    } else {
        // Multi-threaded mode.
        // NSDateFormatter is NOT thread-safe.
        
        NSString *key = @"LJZLogFormatter_NSDateFormatter";
        
        NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
        NSDateFormatter *dateFormatter = [threadDictionary objectForKey:key];
        
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:dateFormatString];
            [threadDictionary setObject:dateFormatter forKey:key];
        }
        
        return [dateFormatter stringFromDate:date];
    }
}


- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;
    switch (logMessage->_flag) {
        case DDLogFlagError    : logLevel = @"E"; break;
        case DDLogFlagWarning  : logLevel = @"W"; break;
        case DDLogFlagInfo     : logLevel = @"I"; break;
        case DDLogFlagDebug    : logLevel = @"D"; break;
        default                : logLevel = @"V"; break;
    }

    NSString *dateAndTime = [self stringFromDate:(logMessage.timestamp)];
    NSString *logMsg = logMessage->_message;
    
    return [NSString stringWithFormat:@"%@ | %@ | %@.m:%ld | %@",dateAndTime,logLevel,logMessage->_fileName,logMessage->_line,logMsg];
}

- (void)didAddToLogger:(id <DDLogger>)logger {
    OSAtomicIncrement32(&atomicLoggerCounter);
}

- (void)willRemoveFromLogger:(id <DDLogger>)logger {
    OSAtomicDecrement32(&atomicLoggerCounter);
}
@end
