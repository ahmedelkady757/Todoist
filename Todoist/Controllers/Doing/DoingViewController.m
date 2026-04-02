//
//  DoingViewController.m
//  Todoist
//

#import "DoingViewController.h"

@implementation DoingViewController

- (TaskStatus)representedStatus { return TaskStatusDoing; }
- (NSString *)controllerTitle   { return @"Doing"; }

@end
