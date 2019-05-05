#ifndef FILELOGGING
#define FILELOGGING

FOUNDATION_EXPORT void _FLog(const char *functionName, int lineNumber, NSString *msgFormat, ...);

#define FLOG(args...) _FLog(__func__, __LINE__, args);

#endif // FILELOGGING
