//
//  NSFileManager+path.h
//  CodeLibrary
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (path)

+ (NSURL *)documentsURL;
+ (NSString *)documentsPath;

+ (NSURL *)libraryURL;
+ (NSString *)libraryPath;

+ (NSURL *)cachesURL;
+ (NSString *)cachesPath;

+ (BOOL)addSkipBackupAttributeToFile:(NSString *)path;

+ (double)availableDiskSpace;

/** 获取文件夹文件大小*/
+ (float)directoryDiskSizeAtPath:(NSString *)directoryPath;


/**获取虚拟形象压缩包路径*/
+ (NSString *)pathForLive2dZip;
/**获取虚拟形象模型路径*/
+ (NSString *)pathForLive2dModel;
/**获取模型解压路径*/
+ (NSString *)pathForLive2dModelWithModelName:(NSString *)modelName;


@end

NS_ASSUME_NONNULL_END
