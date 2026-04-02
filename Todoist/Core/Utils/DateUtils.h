
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DateUtils : NSObject

+ (NSString *)shortStringFromDate:(nullable NSDate *)date;

+ (NSString *)fullStringFromDate:(nullable NSDate *)date;

+ (BOOL)isDateDueOrPast:(nullable NSDate *)date;

@end

NS_ASSUME_NONNULL_END
