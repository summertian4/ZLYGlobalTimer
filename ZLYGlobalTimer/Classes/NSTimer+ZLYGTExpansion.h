//
//  NSTimer+ZLYGTExpansion.h
//  Pods-ZLYGlobalTiimer_Example
//
//  Created by 周凌宇 on 2018/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (ZLYGTExpansion)
+ (NSTimer *)zly_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        repeats:(BOOL)repeats
                                          block:(void (^)(NSTimer *timer))block;
@end

NS_ASSUME_NONNULL_END
