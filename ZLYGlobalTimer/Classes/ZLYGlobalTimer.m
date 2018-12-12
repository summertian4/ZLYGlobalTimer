//
//  ZLYGlobalTimer.m
//  Pods-ZLYGlobalTimer_Example
//
//  Created by 周凌宇 on 2018/10/29.
//

#import "ZLYGlobalTimer.h"
#import "ZLYWeakTimer.h"

@interface ZLYGlobalTimer ()
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

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (NSUInteger)timersCount {
    return self.timers.count;
}

- (NSUInteger)eventsCount {
    __block NSUInteger count = 0;
    [[self.timers mutableCopy] enumerateObjectsUsingBlock:^(ZLYWeakTimer * _Nonnull timer, NSUInteger idx, BOOL * _Nonnull stop) {
        count += timer.events.count;
    }];
    return count;
}

- (ZLYWeakTimer *)addEvent:(ZLYTimerEvent *)event {
    ZLYWeakTimer *t = nil;
    @synchronized (self) {
        for (int i = 0; i < self.timers.count; i++) {
            ZLYWeakTimer *timer = self.timers[i];
            BOOL result = [timer addEvent:event];
            if (result) {   // 有空余，直接加入
                t = timer;
                break;
            } else {    // 没有空余，创建新 timer 加入
                if (i == self.timers.count - 1) { // 已经是最后一个
                    ZLYWeakTimer *timer = [[ZLYWeakTimer alloc] init];
                    [timer addEvent:event];
                    [self addTimer:timer];
                    t = timer;
                    break;
                }
            }
        }
    }
    return t;
}

- (ZLYWeakTimer *)removeEvent:(ZLYTimerEvent *)event {
    ZLYWeakTimer *t = nil;
    @synchronized (self) {
        for (int i = 0; i < self.timers.count; i++) {
            ZLYWeakTimer *timer = self.timers[i];
            BOOL result = [timer addEvent:event];
            if (result) {   // 有空余，直接加入
                t = timer;
                break;
            } else {    // 没有空余，创建新 timer 加入
                if (i == self.timers.count - 1) { // 已经是最后一个
                    ZLYWeakTimer *timer = [[ZLYWeakTimer alloc] init];
                    [timer addEvent:event];
                    [self addTimer:timer];
                    t = timer;
                    break;
                }
            }
        }
    }
    return t;
}

#pragma mark - Life Circle

- (void)dealloc {
    NSLog(@"%@ dealloc", self);
    @synchronized (self) {
        [self.timers enumerateObjectsUsingBlock:^(MSWeakTimer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj invalidate];
        }];
        self.timers = nil;
    }
}

- (void)start {
    ZLYWeakTimer *backgroundTimer = [[ZLYWeakTimer alloc] init];
    [self addTimer:backgroundTimer];
}

- (void)addTimer:(ZLYWeakTimer *)timer {
    @synchronized (self) {
        NSMutableArray *mutableTimers = [self.timers mutableCopy];
        [mutableTimers addObject:timer];
        self.timers = mutableTimers;
    }
}

- (void)end {
    @synchronized (self) {
        [self.timers enumerateObjectsUsingBlock:^(MSWeakTimer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj invalidate];
        }];
        self.timers = nil;
    }
}

#pragma mark - Getter Setter

- (NSArray<MSWeakTimer *> *)timers {
    if (_timers == nil) {
        _timers = [NSArray array];
    }
    return _timers;
}
@end
