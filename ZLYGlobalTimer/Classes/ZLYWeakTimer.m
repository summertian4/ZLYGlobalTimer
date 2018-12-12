//
//  ZLYWeakTimer.m
//  ZLYGlobalTimer_Example
//
//  Created by 周凌宇 on 2018/10/30.
//

#import "ZLYWeakTimer.h"
#import "ZLYTimerEvent.h"

@interface ZLYWeakTimer ()
@end

@implementation ZLYWeakTimer

- (instancetype)init {
    if (self = [super initWithTimeInterval:1
                                    target:self
                                  selector:@selector(timerDidFire:)
                                  userInfo:nil
                                   repeats:YES
                             dispatchQueue:dispatch_get_main_queue()]) {
        [self schedule];
    }
    return self;
}

#pragma mark - Public

- (BOOL)addEvent:(ZLYTimerEvent *)event {
    BOOL result = NO;
    @synchronized (self) {
        if (self.events.count < MaxEventsCount) { // 有空余超过容量，允许加入
            NSMutableArray *mutableEvents = [self.events mutableCopy];
            [mutableEvents addObject:event];
            self.events = mutableEvents;
            result = YES;
        } else { // 没有空余
            result = NO;
        }
    }
    return result;
}

- (instancetype)removeEvents:(ZLYTimerEvent *)event {
    @synchronized (self) {
        NSMutableArray *mutableEvents = [self.events mutableCopy];
        if ([mutableEvents containsObject:event]) {
            [mutableEvents removeObject:event];
            self.events = mutableEvents;
            return self;
        } else {
            return nil;
        }
    }
}

#pragma mark - Private

- (void)timerDidFire:(MSWeakTimer *)timer {
    long long max = 9223372036854775807;
    if (self.second == max) {
        self.second = 0;
    }
    self.second ++;
    [self.events enumerateObjectsUsingBlock:^(ZLYTimerEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.interval <= 0) {
            NSLog(@"未设置 %@ 的 interval", obj);
            return;
        }
        if (self.second % obj.interval == 0) {
            if (obj.callBack) {
                obj.callBack();
            }
        }
    }];
}

#pragma mark - Getter Setter

- (NSArray<ZLYTimerEvent *> *)events {
    if (_events == nil) {
        _events = [NSArray array];
    }
    return _events;
}
@end
