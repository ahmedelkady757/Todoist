//
//  Task.m
//  Todoist
//

#import "Task.h"

static NSString * const kTaskId            = @"taskId";
static NSString * const kTitle             = @"title";
static NSString * const kTaskDescription   = @"taskDescription";
static NSString * const kPriority          = @"priority";
static NSString * const kStatus            = @"status";
static NSString * const kReminderDate      = @"reminderDate";
static NSString * const kAttachedFilePaths = @"attachedFilePaths";
static NSString * const kCreatedAt         = @"createdAt";

@implementation Task


- (instancetype)initWithTitle:(NSString *)title
                  description:(nullable NSString *)description
                     priority:(TaskPriority)priority {
    self = [super init];
    if (self) {
        _taskId            = [[NSUUID UUID] UUIDString];
        _title             = [title copy];
        _taskDescription   = [description copy];
        _priority          = priority;
        _status            = TaskStatusTodo;
        _reminderDate      = nil;
        _attachedFilePaths = [NSMutableArray array];
        _createdAt         = [NSDate date];
    }
    return self;
}

- (instancetype)init {
    return [self initWithTitle:@"" description:nil priority:TaskPriorityLow];
}


- (NSString *)priorityString {
    switch (self.priority) {
        case TaskPriorityLow:    return @"Low";
        case TaskPriorityMedium: return @"Medium";
        case TaskPriorityHigh:   return @"High";
    }
}

- (NSString *)statusString {
    switch (self.status) {
        case TaskStatusTodo:  return @"Todo";
        case TaskStatusDoing: return @"Doing";
        case TaskStatusDone:  return @"Done";
    }
}

- (BOOL)canAdvanceStatus {
    return self.status != TaskStatusDone;
}

- (void)advanceStatus {
    if ([self canAdvanceStatus]) {
        self.status = (TaskStatus)(self.status + 1);
    }
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.taskId            forKey:kTaskId];
    [coder encodeObject:self.title             forKey:kTitle];
    [coder encodeObject:self.taskDescription   forKey:kTaskDescription];
    [coder encodeInteger:self.priority         forKey:kPriority];
    [coder encodeInteger:self.status           forKey:kStatus];
    [coder encodeObject:self.reminderDate      forKey:kReminderDate];
    [coder encodeObject:self.attachedFilePaths forKey:kAttachedFilePaths];
    [coder encodeObject:self.createdAt         forKey:kCreatedAt];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _taskId            = [coder decodeObjectForKey:kTaskId];
        _title             = [coder decodeObjectForKey:kTitle];
        _taskDescription   = [coder decodeObjectForKey:kTaskDescription];
        _priority          = (TaskPriority)[coder decodeIntegerForKey:kPriority];
        _status            = (TaskStatus)[coder decodeIntegerForKey:kStatus];
        _reminderDate      = [coder decodeObjectForKey:kReminderDate];
        _attachedFilePaths = [coder decodeObjectForKey:kAttachedFilePaths] ?: [NSMutableArray array];
        _createdAt         = [coder decodeObjectForKey:kCreatedAt];
    }
    return self;
}


- (id)copyWithZone:(nullable NSZone *)zone {
    Task *copy               = [[Task alloc] init];
    copy.taskId              = [self.taskId copy];
    copy.title               = [self.title copy];
    copy.taskDescription     = [self.taskDescription copy];
    copy.priority            = self.priority;
    copy.status              = self.status;
    copy.reminderDate        = [self.reminderDate copy];
    copy.attachedFilePaths   = [self.attachedFilePaths mutableCopy];
    copy.createdAt           = [self.createdAt copy];
    return copy;
}

@end
