//
//  ZLYGlobalTimerTests.m
//  ZLYGlobalTimerTests
//
//  Created by summertian4 on 10/30/2018.
//  Copyright (c) 2018 summertian4. All rights reserved.
//

#import <ZLYGlobalTimer/ZLYGlobalTimer.h>

@import XCTest;

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [ZLYGlobalTimer start];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < 100; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arc4random() % 10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ZLYTimerEvent *event = [[ZLYTimerEvent alloc] init];
            event.callBack = ^{
                NSLog(@"event %d 被执行", i);
            };
            dispatch_async(defaultQueue, ^{
                [[ZLYGlobalTimer shareInstance] addEvent:event];
            });
        });
    }
}

@end

