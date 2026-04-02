//
//  TaskManager.m
//  Todoist
//

#import "TaskManager.h"

NSString * const TaskManagerDidUpdateTasksNotification = @"TaskManagerDidUpdateTasksNotification";
static NSString * const kTasksKey = @"com.todoist.tasks";

@interface TaskManager ()
@property (nonatomic, strong) NSMutableArray<Task *> *tasks;
@end

@implementation TaskManager


+ (instancetype)sharedManager {
    static TaskManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TaskManager alloc] initPrivate];
    });
    return instance;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        [self loadTasks];
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"Use [TaskManager sharedManager]");
    return nil;
}


- (NSArray<Task *> *)todoTasks {
    return [self tasksWithStatus:TaskStatusTodo];
}

- (NSArray<Task *> *)doingTasks {
    return [self tasksWithStatus:TaskStatusDoing];
}

- (NSArray<Task *> *)doneTasks {
    return [self tasksWithStatus:TaskStatusDone];
}

- (NSArray<Task *> *)tasksWithStatus:(TaskStatus)status {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %ld", (long)status];
    return [self.tasks filteredArrayUsingPredicate:predicate];
}


- (void)addTask:(Task *)task {
    [self.tasks addObject:task];
    [self saveTasks];
}

- (void)updateTask:(Task *)task {
    NSUInteger idx = [self indexForTaskId:task.taskId];
    if (idx != NSNotFound) {
        self.tasks[idx] = task;
        [self saveTasks];
    }
}

- (void)deleteTaskWithId:(NSString *)taskId {
    NSUInteger idx = [self indexForTaskId:taskId];
    if (idx != NSNotFound) {
        [self.tasks removeObjectAtIndex:idx];
        [self saveTasks];
    }
}

- (nullable Task *)taskWithId:(NSString *)taskId {
    NSUInteger idx = [self indexForTaskId:taskId];
    return (idx != NSNotFound) ? self.tasks[idx] : nil;
}


- (void)saveTasks {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.tasks
                                        requiringSecureCoding:YES
                                                        error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kTasksKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TaskManagerDidUpdateTasksNotification
                                                        object:nil];
}

- (void)loadTasks {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kTasksKey];
    if (data) {
        NSArray *loaded = [NSKeyedUnarchiver unarchivedObjectOfClasses:
                           [NSSet setWithObjects:[NSArray class], [Task class],
                            [NSMutableArray class], [NSString class], [NSDate class], nil]
                                                              fromData:data
                                                                 error:nil];
        self.tasks = loaded ? [loaded mutableCopy] : [NSMutableArray array];
    } else {
        self.tasks = [NSMutableArray array];
    }
}


- (NSUInteger)indexForTaskId:(NSString *)taskId {
    return [self.tasks indexOfObjectPassingTest:^BOOL(Task *obj, NSUInteger idx, BOOL *stop) {
        return [obj.taskId isEqualToString:taskId];
    }];
}

@end
