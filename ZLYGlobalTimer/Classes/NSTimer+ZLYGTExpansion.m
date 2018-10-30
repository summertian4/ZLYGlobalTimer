//
//  NSTimer+ZLYGTExpansion.m
//  Pods-ZLYGlobalTiimer_Example
//
//  Created by 周凌宇 on 2018/10/29.
//

#import "NSTimer+ZLYGTExpansion.h"

@implementation NSTimer (ZLYGTExpansion)

#pragma mark - Public

+ (NSTimer *)zly_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        repeats:(BOOL)repeats
                                          block:(void (^)(NSTimer *))block {
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(zly_blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];

}

#pragma mark - Private

- (void)zly_blockInvoke:(NSTimer *)timer {
    void(^block)(NSTimer *timer) = timer.userInfo;
    if (block) {
        block(timer);
    }
}

@end
