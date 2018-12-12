//
//  ZLYViewController.m
//  ZLYGlobalTimer
//
//  Created by summertian4 on 10/30/2018.
//  Copyright (c) 2018 summertian4. All rights reserved.
//

#import "ZLYViewController.h"
#import <ZLYGlobalTimer/ZLYGlobalTimer.h>

#define weakify(var) __weak typeof(var) ZLYWeak_##var = var;
#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = ZLYWeak_##var; \
_Pragma("clang diagnostic pop")

@interface ZLYViewController ()
@property (weak, nonatomic) IBOutlet UILabel *eventCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, strong) ZLYTimerEvent *countEvent;

/**
 压测使用的 events
 */
@property (nonatomic, strong) NSMutableArray<ZLYTimerEvent *> *events;
@end

@implementation ZLYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_queue_t queque = dispatch_queue_create("com.zhoulingyu.ZLYGlobalTimer.privatQueue", DISPATCH_QUEUE_CONCURRENT);
    __weak __typeof(self)weakSelf = self;
    dispatch_async(queque, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            ZLYTimerEvent *dashboarRefreshEvent = [[ZLYTimerEvent alloc] init];
            dashboarRefreshEvent.interval = 1;

            dashboarRefreshEvent.callBack = ^{
                // 回调始终在 main 线程
                NSUInteger eventsCount = [[ZLYGlobalTimer shareInstance] eventsCount];
                strongSelf.eventCountLabel.text = [NSString stringWithFormat:@"%ld", eventsCount];
                NSUInteger timersCount = [[ZLYGlobalTimer shareInstance] timersCount];
                strongSelf.timerCountLabel.text = [NSString stringWithFormat:@"%ld", timersCount];

            };
            [[ZLYGlobalTimer shareInstance] addEvent:dashboarRefreshEvent];
        }
    });
}


/**
 压测

 @param sender
 */
- (IBAction)startTest:(UIButton *)sender {
    __weak __typeof(self)weakSelf = self;
    for (int i = 0; i < 100; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arc4random() % 5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                ZLYTimerEvent *event = [[ZLYTimerEvent alloc] init];
                event.interval = 5;
                event.callBack = ^{
                    NSLog(@"event %d 被执行", i);
                };
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                if (strongSelf) {
                    @synchronized (self) {
                        [strongSelf.events addObject:event];
                    }
                }
                [[ZLYGlobalTimer shareInstance] addEvent:event];
            });
        });
    }

    // 5 秒后开始陆续移除 event
    weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        strongify(self);
         for (int i = 0; i < self.events.count; i++) {
             ZLYTimerEvent *event = self.events[i];
             weakify(event);
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arc4random() % 10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 strongify(event);
                 weakify(event);
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     strongify(event);
                     [[ZLYGlobalTimer shareInstance] removeEvent:event];
                 });
             });
         }
        self.events = nil;
    });
}

- (IBAction)startButtonClicked:(UIButton *)sender {
    self.countEvent = [[ZLYTimerEvent alloc] init];
    self.countEvent.interval = 1;
    __weak __typeof(self)weakSelf = self;
    self.countEvent.callBack = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.label.text = [NSString stringWithFormat:@"%ld", [strongSelf.label.text integerValue] + 1];
        }
    };
    [[ZLYGlobalTimer shareInstance] addEvent:self.countEvent];
}

- (IBAction)stopButtonClicked:(UIButton *)sender {
    [[ZLYGlobalTimer shareInstance] removeEvent:self.countEvent];
}

- (IBAction)globalTimerStartButtonClicked:(UIButton *)sender {
    [ZLYGlobalTimer start];

    dispatch_queue_t queque = dispatch_queue_create("com.zhoulingyu.ZLYGlobalTimer.privatQueue", DISPATCH_QUEUE_CONCURRENT);
    __weak __typeof(self)weakSelf = self;
    dispatch_async(queque, ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            ZLYTimerEvent *dashboarRefreshEvent = [[ZLYTimerEvent alloc] init];
            dashboarRefreshEvent.interval = 1;

            dashboarRefreshEvent.callBack = ^{
                // 回调始终在 main 线程
                NSUInteger eventsCount = [[ZLYGlobalTimer shareInstance] eventsCount];
                strongSelf.eventCountLabel.text = [NSString stringWithFormat:@"%ld", eventsCount];
                NSUInteger timersCount = [[ZLYGlobalTimer shareInstance] timersCount];
                strongSelf.timerCountLabel.text = [NSString stringWithFormat:@"%ld", timersCount];

            };
            [[ZLYGlobalTimer shareInstance] addEvent:dashboarRefreshEvent];
        }
    });
}

- (IBAction)globalTimerEndButtonClicked:(UIButton *)sender {
    [ZLYGlobalTimer end];
}

- (NSMutableArray<ZLYTimerEvent *> *)events {
    if (_events == nil) {
        _events = [NSMutableArray array];
    }
    return _events;
}
@end
