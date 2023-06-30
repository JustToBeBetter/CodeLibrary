//
//  NSFileManager+path.m
//  CodeLibrary
//


#import "NSFileManager+path.h"

@implementation NSFileManager (path)

+ (NSURL *)URLForDirectory:(NSSearchPathDirectory)directory
{
    return [self.defaultManager URLsForDirectory:directory inDomains:NSUserDomainMask].lastObject;
}

+ (NSString *)pathForDirectory:(NSSearchPathDirectory)directory
{
    return NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES)[0];
}

+ (NSURL *)documentsURL
{
    return [self URLForDirectory:NSDocumentDirectory];
}

+ (NSString *)documentsPath
{
    return [self pathForDirectory:NSDocumentDirectory];
}

+ (NSURL *)libraryURL
{
    return [self URLForDirectory:NSLibraryDirectory];
}

+ (NSString *)libraryPath
{
    return [self pathForDirectory:NSLibraryDirectory];
}

+ (NSURL *)cachesURL
{
    return [self URLForDirectory:NSCachesDirectory];
}

+ (NSString *)cachesPath
{
    return [self pathForDirectory:NSCachesDirectory];
}

+ (BOOL)addSkipBackupAttributeToFile:(NSString *)path
{
    return [[NSURL.alloc initFileURLWithPath:path] setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
}

+ (double)availableDiskSpace
{
    NSDictionary *attributes = [self.defaultManager attributesOfFileSystemForPath:self.documentsPath error:nil];
    
    return [attributes[NSFileSystemFreeSize] unsignedLongLongValue] / (double)0x100000;
}

+ (float)directoryDiskSizeAtPath:(NSString *)directoryPath{
    if([[NSFileManager defaultManager]fileExistsAtPath:directoryPath]){
        NSEnumerator *fileEnumerator = [[[NSFileManager defaultManager]subpathsAtPath:directoryPath]objectEnumerator];
        NSString *fileName;
        long long totalSize = 0;
        while ((fileName = [fileEnumerator nextObject])!= nil) {
            totalSize += [self fileSizeAtPath:[directoryPath stringByAppendingPathComponent:fileName]];
        }
        return totalSize;
    }
    return 0;
}

+ (long)fileSizeAtPath:(NSString *)filePath{
    if([[NSFileManager defaultManager]fileExistsAtPath:filePath]){
        return [[[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:nil]fileSize];
    }
    return 0;
}

+ (NSString *)pathForGiftAudio{
    NSString *path = [NSString stringWithFormat:@"%@/gift/audio", [NSFileManager cachesPath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return path;
}
+ (NSString *)pathForSvga{
    NSString *path = [NSString stringWithFormat:@"%@/svga", [NSFileManager cachesPath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return path;
}
+ (NSString *)pathForTimelineRecord{
    NSString *path = [NSString stringWithFormat:@"%@/timeline", [NSFileManager cachesPath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return path;
}
+ (NSString *)pathForPersonalRecord {
    NSString *path = [NSString stringWithFormat:@"%@/personal", [NSFileManager cachesPath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return path;
}
+ (NSString *)pathForGuideAudioZip{
    NSString *path = [NSString stringWithFormat:@"%@/guidezip", [NSFileManager cachesPath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return path;
}
+ (NSString *)pathForGuideAudio{
    NSString *path = [NSString stringWithFormat:@"%@/guideaudio", [NSFileManager cachesPath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return path;
}
+ (NSString *)pathForGuideAudioWithAudioName:(NSString *)audioName{
    NSString *path = [NSString stringWithFormat:@"%@/guideaudio/%@", [NSFileManager cachesPath],audioName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    return path;
}
+ (NSString *)pathForLive2dRecord{
    NSString *path = [NSString stringWithFormat:@"%@/l2drecord", [NSFileManager cachesPath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return path;
}
+ (NSString *)pathForLive2dZip{
    NSString *path = [NSString stringWithFormat:@"%@/l2dzip", [NSFileManager documentsPath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return path;
}
+ (NSString *)pathForLive2dModel{
    NSString *path = [NSString stringWithFormat:@"%@/l2dmodel", [NSFileManager documentsPath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"File Create Failed: %@", path);
        }
    }
    return path;
}
+ (NSString *)pathForLive2dModelWithModelName:(NSString *)modelName{
    NSString *path = [NSString stringWithFormat:@"%@/l2dmodel/%@", [NSFileManager documentsPath],modelName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    return path;
}
@end
