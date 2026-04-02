//
//  Task.h
//  Todoist
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, TaskPriority) {
    TaskPriorityLow    = 0,
    TaskPriorityMedium = 1,
    TaskPriorityHigh   = 2
};

typedef NS_ENUM(NSInteger, TaskStatus) {
    TaskStatusTodo  = 0,
    TaskStatusDoing = 1,
    TaskStatusDone  = 2
};

@interface Task : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, strong) NSString *taskId;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong, nullable) NSString *taskDescription;

@property (nonatomic, assign) TaskPriority priority;

@property (nonatomic, assign) TaskStatus status;

@property (nonatomic, strong, nullable) NSDate *reminderDate;

@property (nonatomic, strong) NSMutableArray<NSString *> *attachedFilePaths;

@property (nonatomic, strong) NSDate *createdAt;

- (instancetype)initWithTitle:(NSString *)title
                  description:(nullable NSString *)description
                     priority:(TaskPriority)priority;

- (NSString *)priorityString;

- (NSString *)statusString;

- (BOOL)canAdvanceStatus;

- (void)advanceStatus;

@end

