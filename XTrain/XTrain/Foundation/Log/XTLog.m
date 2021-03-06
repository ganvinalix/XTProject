//
//  XTLog.m
//  XTrain
//
//  Created by Ben on 14/11/7.
//  Copyright (c) 2014年 XTeam. All rights reserved.
//

#import "XTLog.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "XTUtil.h"

#ifdef DEBUG
    static int ddLogLevel = DDLogLevelVerbose;
#else
    static int ddLogLevel = DDLogLevelInfo;
#endif

void XTLogout(XTLogLevel level, const char *file, int line, const char *func, NSString *category, NSString *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    NSString *content = [[NSString alloc] initWithFormat:fmt arguments:ap];
    NSString *logContent = [NSString stringWithFormat:@"[%@:%d][%s][%@]",
                            [[NSString stringWithFormat:@"%s", file] lastPathComponent],
                            line,
                            func,
                            category];
    switch (level)
    {
        case XTLogLevelVerbose:
            DDLogVerbose(@"%@[verbose] %@", logContent, content);
            break;
        case XTLogLevelDebug:
            DDLogDebug(@"%@[Debug] %@", logContent, content);
            break;
        case XTLogLevelInfo:
            DDLogInfo(@"%@[Info] %@", logContent, content);
            break;
        case XTLogLevelWarn:
            DDLogWarn(@"%@[Warn] %@", logContent, content);
            break;
        case XTLogLevelError:
            DDLogError(@"%@[Error] %@", logContent, content);
            break;
        default:
            break;
    }
}

@implementation XTLogConfig

+ (void)loadConfig
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    NSString *directory = [[XTUtil appDocPath] stringByAppendingPathComponent:@"log"];
    DDLogFileManagerDefault *fileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:directory];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:fileManager];
    fileLogger.maximumFileSize = 10 * 1024 * 1024; // Default 10M
    [DDLog addLogger:fileLogger withLevel:DDLogLevelError];
}

@end