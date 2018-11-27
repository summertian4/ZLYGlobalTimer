//
//  ZLYWeakTimer.m
//  ZLYGlobalTimer_Example
//
//  Created by 周凌宇 on 2018/10/30.
//

#import "ZLYWeakTimer.h"
#import "ZLYTimerEvent.h"

@interface ZLYWeakTimer ()

/** 专门处理 timers events 变动的串行队列 */
@property (strong, nonatomic) dispatch_queue_t privateQueue;
@end

@implementation ZLYWeakTimer

- (instancetype)init {
    if (self = [super initWithTimeInterval:1
                                    target:self
                                  selector:@selector(timerDidFire:)
                                  userInfo:nil
                                   repeats:YES
                             dispatchQueue:dispatch_get_main_queue()]) {
        self.privateQueue = dispatch_queue_create("com.zhoulingyu.ZLYGlobalTimer.privatQueue", DISPATCH_QUEUE_SERIAL);
        [self schedule];
    }
    return self;
}

#pragma mark - Public

- (BOOL)addEvent:(ZLYTimerEvent *)event {
    __weak __typeof(self)weakSelf = self;
    __block BOOL result = NO;
    dispatch_sync(self.privateQueue, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            if (strongSelf.events.count < MaxEventsCount) { // 有空余超过容量，允许加入
                NSMutableArray *mutableEvents = [self.events mutableCopy];
                [mutableEvents addObject:event];
                strongSelf.events = mutableEvents;
                result = YES;
            } else { // 没有空余
                result = NO;
            }
        }
    });
    return result;
}

- (void)removeEvents:(ZLYTimerEvent *)event {
    __weak __typeof(self)weakSelf = self;
    dispatch_sync(self.privateQueue, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            NSMutableArray *mutableEvents = [strongSelf.events mutableCopy];
            [mutableEvents removeObject:event];
            strongSelf.events = mutableEvents;
        }
    });
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
