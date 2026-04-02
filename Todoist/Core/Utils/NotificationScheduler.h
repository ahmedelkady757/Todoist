
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotificationScheduler : NSObject

+ (void)scheduleNotificationForTask:(Task *)task;

+ (void)cancelNotificationForTask:(Task *)task;

@end

NS_ASSUME_NONNULL_END
