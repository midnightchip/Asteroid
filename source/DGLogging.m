#ifndef FILELOGGING
#define FILELOGGING

#define kLOGFILEPATH @"/var/mobile/Library/Asteroid/logging.txt"

void _FLog(const char *functionName, int lineNumber, NSString *msgFormat, ...) {
    va_list ap;
    va_start(ap, msgFormat);
    NSString *logFormattedMessage = [[NSString alloc] initWithFormat:msgFormat arguments:ap];
    va_end(ap);
    NSString *logMessage = [NSString stringWithFormat:@"%@ -- %s[%d] %@\n", [NSDate date], functionName, lineNumber, logFormattedMessage];
    if (![[NSFileManager defaultManager] fileExistsAtPath:kLOGFILEPATH])
        [[NSData data] writeToFile:kLOGFILEPATH atomically:YES];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:kLOGFILEPATH];
    [handle truncateFileAtOffset:[handle seekToEndOfFile]];
    [handle writeData:[logMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
}

#endif // FILELOGGING
