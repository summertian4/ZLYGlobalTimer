//
//  ZLYGlobalTimer.h
//  Pods-ZLYGlobalTimer_Example
//
//  Created by 周凌宇 on 2018/10/29.
//

#import <Foundation/Foundation.h>
#import "ZLYTimerEvent.h"
#import "ZLYWeakTimer.h"

// You should know these about NSTimer first.
// This is the official document:
//      https://developer.apple.com/documentation/foundation/nstimer?preferredLanguage=occ
// 1. For a repeating timer, you must invalidate the timer object yourself by calling its invalidate method.
// 2. Calling this method requests the removal of the timer from the current run loop;
// 3. As a result, you should always call the invalidate method from the *same thread* on which the timer was installed.

NS_ASSUME_NONNULL_BEGIN

@interface ZLYGlobalTimer : NSObject

+ (instancetype)shareInstance;

+ (void)start;
+ (void)end;

- (void)addEvent:(ZLYTimerEvent *)event;
- (BOOL)removeEvent:(ZLYTimerEvent *)event;

- (NSUInteger)timersCount;
- (NSUInteger)eventsCount;

@end

NS_ASSUME_NONNULL_END
