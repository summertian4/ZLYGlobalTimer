#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSTimer+ZLYGTExpansion.h"
#import "ZLYGlobalTimer.h"
#import "ZLYTimerEvent.h"
#import "ZLYWeakTimer.h"

FOUNDATION_EXPORT double ZLYGlobalTimerVersionNumber;
FOUNDATION_EXPORT const unsigned char ZLYGlobalTimerVersionString[];

