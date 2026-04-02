

#import <Foundation/Foundation.h>
#import "Task.h"



extern NSString * const TaskManagerDidUpdateTasksNotification;

@interface TaskManager : NSObject

+ (instancetype)sharedManager;


- (NSArray<Task *> *)todoTasks;

- (NSArray<Task *> *)doingTasks;

- (NSArray<Task *> *)doneTasks;


- (void)addTask:(Task *)task;

- (void)updateTask:(Task *)task;

- (void)deleteTaskWithId:(NSString *)taskId;

- (nullable Task *)taskWithId:(NSString *)taskId;


- (void)saveTasks;

@end

