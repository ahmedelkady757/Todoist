//
//  DoneViewController.m
//  Todoist
//

#import "DoneViewController.h"

@implementation DoneViewController

- (TaskStatus)representedStatus { return TaskStatusDone; }
- (NSString *)controllerTitle   { return @"Done"; }

@end
