//
//  ZLYWeakTimer.m
//  ZLYGlobalTimer_Example
//
//  Created by 周凌宇 on 2018/10/30.
//

#import "ZLYWeakTimer.h"
#import "ZLYTimerEvent.h"

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

- (void)addEvents:(ZLYTimerEvent *)event {
    NSMutableArray *mutableEvents = [self.events mutableCopy];
    [mutableEvents addObject:event];
    self.events = mutableEvents;
}

- (void)removeEvents:(ZLYTimerEvent *)event {
    NSMutableArray *mutableEvents = [self.events mutableCopy];
    [mutableEvents removeObject:event];
    self.events = mutableEvents;
}

#pragma mark - Private

- (void)timerDidFire:(MSWeakTimer *)timer {
    NSAssert([NSThread isMainThread], @"This should be called from the main thread");
    long long max = 9223372036854775807;
    if (self.second == max) {
        self.second = 0;
    }
    self.second ++;
    [self.events enumerateObjectsUsingBlock:^(ZLYTimerEvent * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
