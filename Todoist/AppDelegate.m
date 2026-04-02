//
//  AppDelegate.m
//  Todoist
//

#import "AppDelegate.h"
#import "TaskManager.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [TaskManager sharedManager];

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;

    [self requestNotificationPermission];

    return YES;
}


- (void)requestNotificationPermission {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert |
                                                     UNAuthorizationOptionBadge |
                                                     UNAuthorizationOptionSound)
                                  completionHandler:^(BOOL granted, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        NSLog(@"[Todoist] Notification permission error: %@", error.localizedDescription);
                    } else if (granted) {
                        NSLog(@"[Todoist] Notification permission granted.");
                    } else {
                        NSLog(@"[Todoist] Notification permission denied.");
                    }
                });
            }];
        } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            NSLog(@"[Todoist] Notification permission already granted.");
        } else {
            NSLog(@"[Todoist] Notification permission already denied.");
        }
    }];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    if (@available(iOS 14.0, *)) {
        completionHandler(UNNotificationPresentationOptionList | UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionSound);
    } else {
        completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
    }
}

@end
