#ifndef FILELOGGING
#define FILELOGGING

#ifndef DEBUG
#define FLOG(args...)
#else
FOUNDATION_EXPORT void _FLog(const char *functionName, int lineNumber, NSString *msgFormat, ...);

#define FLOG(args...) _FLog(__func__, __LINE__, args);

#endif
#endif // FILELOGGING
