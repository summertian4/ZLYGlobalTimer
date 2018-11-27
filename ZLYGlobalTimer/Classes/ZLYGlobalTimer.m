//
//  ZLYGlobalTimer.m
//  Pods-ZLYGlobalTimer_Example
//
//  Created by 周凌宇 on 2018/10/29.
//

#import "ZLYGlobalTimer.h"
#import "ZLYWeakTimer.h"

@interface ZLYGlobalTimer ()
/** 专门处理 timers events 变动的串行队列 */
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

- (instancetype)init {
    if (self = [super init]) {
        self.privateQueue = dispatch_queue_create("com.zhoulingyu.ZLYGlobalTimer.privatQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSUInteger)timersCount {
    return self.timers.count;
}

- (NSUInteger)eventsCount {
    __block NSUInteger count = 0;
    __weak __typeof(self)weakSelf = self;
    dispatch_sync(self.privateQueue, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            [self.timers enumerateObjectsUsingBlock:^(ZLYWeakTimer * _Nonnull timer, NSUInteger idx, BOOL * _Nonnull stop) {
                count += timer.events.count;
            }];
        }
    });
    return count;
}

- (ZLYWeakTimer *)addEvent:(ZLYTimerEvent *)event {
    __weak __block __typeof(ZLYWeakTimer *)t = nil;
    __weak __typeof(ZLYTimerEvent *)weakEvent = event;
    __weak __typeof(self)weakSelf = self;
    dispatch_sync(self.privateQueue, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            [self.timers enumerateObjectsUsingBlock:^(ZLYWeakTimer * _Nonnull timer, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL result = [timer addEvent:weakEvent];
                if (result) {   // 有空余，成功加入
                    t = timer;
                } else {    // 没有空余，未成功加入
                    if (idx == strongSelf.timers.count - 1) { // 已经是最后一个
                        ZLYWeakTimer *timer = [[ZLYWeakTimer alloc] init];
                        [timer addEvent:weakEvent];
                        [strongSelf addTimer:timer];
                        t = timer;
                    }
                }
            }];
        }
    });
    return t;
}

#pragma mark - Life Circle

- (void)dealloc {
    __weak __typeof(self)weakSelf = self;
    dispatch_sync(self.privateQueue, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.timers enumerateObjectsUsingBlock:^(MSWeakTimer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj invalidate];
            }];
            strongSelf.timers = nil;
        }
    });
}

- (void)start {
    ZLYWeakTimer *backgroundTimer = [[ZLYWeakTimer alloc] init];
    [self addTimer:backgroundTimer];
}

- (void)addTimer:(ZLYWeakTimer *)timer {
    __weak __typeof(self)weakSelf = self;
    dispatch_sync(self.privateQueue, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            NSMutableArray *mutableTimers = [strongSelf.timers mutableCopy];
            [mutableTimers addObject:timer];
            strongSelf.timers = mutableTimers;
        }
    });
}

- (void)end {
    __weak __typeof(self)weakSelf = self;
    dispatch_sync(self.privateQueue, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.timers enumerateObjectsUsingBlock:^(MSWeakTimer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj invalidate];
            }];
            strongSelf.timers = nil;
        }
    });
}

#pragma mark - Getter Setter

- (NSArray<MSWeakTimer *> *)timers {
    if (_timers == nil) {
        _timers = [NSArray array];
    }
    return _timers;
}

@end
