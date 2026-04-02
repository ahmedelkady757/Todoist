
#import "DateUtils.h"

@implementation DateUtils

+ (NSDateFormatter *)sharedShortFormatter {
    static NSDateFormatter *fmt = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fmt = [[NSDateFormatter alloc] init];
        fmt.dateStyle = NSDateFormatterMediumStyle;
        fmt.timeStyle = NSDateFormatterNoStyle;
        fmt.locale    = [NSLocale currentLocale];
    });
    return fmt;
}

+ (NSDateFormatter *)sharedFullFormatter {
    static NSDateFormatter *fmt = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fmt = [[NSDateFormatter alloc] init];
        fmt.dateStyle = NSDateFormatterMediumStyle;
        fmt.timeStyle = NSDateFormatterShortStyle;
        fmt.locale    = [NSLocale currentLocale];
    });
    return fmt;
}

+ (NSString *)shortStringFromDate:(nullable NSDate *)date {
    if (!date) return @"No date set";
    return [[self sharedShortFormatter] stringFromDate:date];
}

+ (NSString *)fullStringFromDate:(nullable NSDate *)date {
    if (!date) return @"No date set";
    return [[self sharedFullFormatter] stringFromDate:date];
}

+ (BOOL)isDateDueOrPast:(nullable NSDate *)date {
    if (!date) return NO;
    return ([date compare:[NSDate date]] != NSOrderedDescending);
}

@end
