//
//  NotificationScheduler.m
//  Todoist
//

#import "NotificationScheduler.h"

@implementation NotificationScheduler

+ (void)scheduleNotificationForTask:(Task *)task {
    if (!task.reminderDate) return;

    if ([task.reminderDate compare:[NSDate date]] == NSOrderedAscending) return;

    [self cancelNotificationForTask:task];

    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"Task Reminder";
    content.launchImageName =
    content.body  = [NSString stringWithFormat:@"It's time to work on: %@", task.title];
    content.sound = [UNNotificationSound defaultSound];

    NSCalendarUnit units = (NSCalendarUnitYear  | NSCalendarUnitMonth |
                            NSCalendarUnitDay   | NSCalendarUnitHour  |
                            NSCalendarUnitMinute);
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:units
                                                              fromDate:task.reminderDate];

    UNCalendarNotificationTrigger *trigger =
        [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:comps repeats:NO];

    UNNotificationRequest *request =
        [UNNotificationRequest requestWithIdentifier:task.taskId
                                             content:content
                                             trigger:trigger];

    [[UNUserNotificationCenter currentNotificationCenter]
        addNotificationRequest:request
         withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"[NotificationScheduler] Error: %@", error.localizedDescription);
            } else {
                NSLog(@"[NotificationScheduler] Scheduled for task: %@", task.title);
            }
        }];
}

+ (void)cancelNotificationForTask:(Task *)task {
    [[UNUserNotificationCenter currentNotificationCenter]
        removePendingNotificationRequestsWithIdentifiers:@[task.taskId]];
}

@end
