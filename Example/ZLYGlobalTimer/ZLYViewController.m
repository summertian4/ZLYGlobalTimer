//
//  ZLYViewController.m
//  ZLYGlobalTimer
//
//  Created by summertian4 on 10/30/2018.
//  Copyright (c) 2018 summertian4. All rights reserved.
//

#import "ZLYViewController.h"
#import <ZLYGlobalTimer/ZLYGlobalTimer.h>

@interface ZLYViewController ()
@property (weak, nonatomic) IBOutlet UILabel *eventCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, strong) ZLYWeakTimer *timer;
@property (nonatomic, strong) ZLYTimerEvent *event;
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

- (IBAction)startButtonClicked:(UIButton *)sender {
    self.event = [[ZLYTimerEvent alloc] init];
    self.event.interval = 1;
    __weak __typeof(self)weakSelf = self;
    self.event.callBack = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.label.text = [NSString stringWithFormat:@"%ld", [strongSelf.label.text integerValue] + 1];
        }
    };
    self.timer = [[ZLYGlobalTimer shareInstance] addEvent:self.event];
}

- (IBAction)stopButtonClicked:(UIButton *)sender {
    [self.timer removeEvents:self.event];
}

- (IBAction)globalTimerStartButtonClicked:(UIButton *)sender {
    [ZLYGlobalTimer start];
}

- (IBAction)globalTimerEndButtonClicked:(UIButton *)sender {
    [ZLYGlobalTimer end];
}

@end
