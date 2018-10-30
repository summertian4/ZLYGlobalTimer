//
//  ZLYGlobalTimer.m
//  Pods-ZLYGlobalTimer_Example
//
//  Created by 周凌宇 on 2018/10/29.
//

#import "ZLYGlobalTimer.h"
#import "ZLYWeakTimer.h"

@interface ZLYGlobalTimer ()
#pragma mark - TODO 线程安全
@property (nonatomic, strong) NSArray *events;
@property (strong, nonatomic) dispatch_queue_t privateQueue;

@property (nonatomic, strong) NSArray<ZLYWeakTimer *> *timers;

@end

@implementation ZLYGlobalTimer

#pragma mark - Public

+ (instancetype)shareInstance {
    static ZLYGlobalTimer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZLYGlobalTimer alloc] init];
    });
    return instance;
}

+ (void)start {
    ZLYGlobalTimer *globalTimer = [self shareInstance];
    [globalTimer start];
}

+ (void)end {
    ZLYGlobalTimer *globalTimer = [self shareInstance];
    [globalTimer end];
}

- (ZLYWeakTimer *)addEvent:(ZLYTimerEvent *)event {
    if (self.timers.lastObject.events.count >= MaxEventsCount) { // 超过容量，新加一个
        ZLYWeakTimer *timer = [[ZLYWeakTimer alloc] init];
        [self addTimer:timer];
    }
    ZLYWeakTimer *timer = self.timers.lastObject;
    [timer addEvents:event];
    return timer;
}

#pragma mark - Life Circle

- (void)dealloc {
    [self.timers enumerateObjectsUsingBlock:^(MSWeakTimer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj invalidate];
    }];
}

- (void)start {
#pragma mark - TODO 待处理
    ZLYWeakTimer *backgroundTimer = [[ZLYWeakTimer alloc] init];
    [self addTimer:backgroundTimer];
}

- (void)addTimer:(ZLYWeakTimer *)timer {
    NSMutableArray *mutableTimers = [self.timers mutableCopy];
    [mutableTimers addObject:timer];
    self.timers = mutableTimers;
}

- (void)end {
    [self.timers enumerateObjectsUsingBlock:^(MSWeakTimer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj invalidate];
    }];
}

#pragma mark - Getter Setter

- (NSArray *)events {
    if (_events == nil) {
        _events = [NSArray array];
    }
    return _events;
}

- (NSArray<MSWeakTimer *> *)timers {
    if (_timers == nil) {
        _timers = [NSArray array];
    }
    return _timers;
}

@end
