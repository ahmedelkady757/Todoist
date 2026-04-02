//
//  ViewController.m  (Todo tab)
//  Todoist
//

#import "ViewController.h"
#import "AddTaskViewController.h"

@implementation ViewController

- (TaskStatus)representedStatus { return TaskStatusTodo; }
- (NSString *)controllerTitle   { return @"Todo"; }

- (void)viewDidLoad {
    [super viewDidLoad];

  
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                      target:self
                                                      action:@selector(addTaskTapped)];
}

- (void)addTaskTapped {
    AddTaskViewController *addVC =
        [self.storyboard instantiateViewControllerWithIdentifier:@"AddTaskViewController"];

    UINavigationController *nav =
        [[UINavigationController alloc] initWithRootViewController:addVC];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
