//
//  SAMCLogUploader.m
//  SamChat
//
//  Created by HJ on 11/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCLogUploader.h"
#import "SAMCResourceManager.h"
#import "SSZipArchive.h"
#import "SAMCServerAPIMacro.h"
#import "SAMCAccountManager.h"

@implementation SAMCLogUploader
- (void)upload:(void (^)(NSString *urlString,NSError *error))completion
{
    NSString *filepath = [self zipFilepath];
    SSZipArchive *archive = [[SSZipArchive alloc] initWithPath:filepath];
    BOOL archived = NO;
    if ([archive open]) {
        NSDictionary *files = [self allFiles];
        for (NSString *key in files.allKeys) {
            [archive writeFileAtPath:files[key]
                        withFileName:key
                        withPassword:nil];
        }
        
        if ([archive close]) {
            archived = YES;
            NSString *key = [NSString stringWithFormat:@"%@%@", SAMC_AWSS3_LOG_PATH, [filepath lastPathComponent]];
            [[SAMCResourceManager sharedManager] upload:filepath key:key contentType:@"application/x-zip-compressed" progress:nil completion:^(NSString *urlString, NSError *error) {
                if (completion) {
                    completion(urlString, error);
                }
            }];
        }
    }
    
    if (!archived) {
        if (completion) {
            completion(nil,[NSError errorWithDomain:@"com.github.gknows.samchat" code:0 userInfo:nil]);
        }
    }
}

- (NSString *)zipFilepath
{
//    NSString *filename = [NSString stringWithFormat:@"%@.zip",[[NSUUID UUID] UUIDString]];
    NSString *currentAccount = [SAMCAccountManager sharedManager].currentAccount;
    NSInteger timeInterval = [@([[NSDate date] timeIntervalSince1970] * 1000) integerValue];
    NSString *filename = [NSString stringWithFormat:@"log_%@_%ld.zip",currentAccount,timeInterval];
    return  [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
}

- (NSDictionary *)allFiles
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //添加 NIM SDK 文件
    NSString *logFilepath = [[NIMSDK sharedSDK] currentLogFilepath];
    NSString *sdkDir = [[logFilepath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    NSMutableDictionary *files = [NSMutableDictionary dictionary];
    NSMutableArray *dirs = [NSMutableArray array];
    [dirs addObject:sdkDir];
    while ([dirs count]) {
        NSString *dir = [dirs firstObject];
        [dirs removeObjectAtIndex:0];
        
        NSArray *filenames = [fileManager contentsOfDirectoryAtPath:dir
                                                              error:nil];
        for (NSString *filename in filenames) {
            NSString *path = [dir stringByAppendingPathComponent:filename];
            BOOL isDir = NO;
            if ([fileManager fileExistsAtPath:path
                                  isDirectory:&isDir]) {
                if (isDir) {
                    [dirs addObject:path];
                } else {
                    NSString *pathExtension = [path pathExtension];
                    if ([pathExtension isEqualToString:@"log"] ||
                        [pathExtension isEqualToString:@"db"]) {
                        NSString *key = [path lastPathComponent];
                        if ([pathExtension isEqualToString:@"db"]) {
                            NSString *parentDir = [[path stringByDeletingLastPathComponent] lastPathComponent];
                            key = [NSString stringWithFormat:@"%@_%@",parentDir,key];
                        }
                        files[key] = path;
                    }
                }
            }
        }
    }
    
    //添加 DDLog 文件
    NSArray *loggers = [DDLog allLoggers];
    for (id logger in loggers) {
        if ([logger isKindOfClass:[DDFileLogger class]]) {
            NSString *filepath = [[(DDFileLogger *)logger currentLogFileInfo] filePath];
            NSString *key = [filepath lastPathComponent];
            files[key] = filepath;
        }
    }
    
    return files;
}

@end
