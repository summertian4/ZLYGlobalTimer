//
//  ZLYTimerEvent.h
//  Pods-ZLYGlobalTimer_Example
//
//  Created by 周凌宇 on 2018/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLYTimerEvent : NSObject

@property (nonatomic, assign) int interval;
@property (nonatomic, copy) void (^callBack)(void);

@end

NS_ASSUME_NONNULL_END
