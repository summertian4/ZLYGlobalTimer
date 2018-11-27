//
//  ZLYWeakTimer.h
//  ZLYGlobalTimer_Example
//
//  Created by 周凌宇 on 2018/10/30.
//

#import <MSWeakTimer/MSWeakTimer.h>

static int MaxEventsCount = 10;

NS_ASSUME_NONNULL_BEGIN

@class ZLYTimerEvent;

@interface ZLYWeakTimer : MSWeakTimer
@property (nonatomic, strong) NSArray<ZLYTimerEvent *> *events;
@property (nonatomic, assign) long long second;
- (BOOL)addEvent:(ZLYTimerEvent *)event;
- (void)removeEvents:(ZLYTimerEvent *)event;
@end

NS_ASSUME_NONNULL_END
