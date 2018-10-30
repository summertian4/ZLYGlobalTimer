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

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, strong) ZLYWeakTimer *timer;
@property (nonatomic, strong) ZLYTimerEvent *event;
@end

@implementation ZLYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)startButtonClicked:(UIButton *)sender {
    self.event = [[ZLYTimerEvent alloc] init];
    self.event.interval = 2;
    __weak __typeof(self)weakSelf = self;
    self.event.callBack = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.label.text = [NSString stringWithFormat:@"%ld", [strongSelf.label.text integerValue] + 2];
        }
        NSLog(@"====== a event be called =======");
    };
    self.timer = [[ZLYGlobalTimer shareInstance] addEvent:self.event];
}

- (IBAction)stopButtonClicked:(UIButton *)sender {
    [self.timer removeEvents:self.event];
}

- (IBAction)globalTimerEndButtonClicked:(UIButton *)sender {
    [ZLYGlobalTimer end];
}

@end
