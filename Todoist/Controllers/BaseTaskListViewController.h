//
//  BaseTaskListViewController.h
//  Todoist
//

#import <UIKit/UIKit.h>
#import "Task.h"


@interface BaseTaskListViewController : UIViewController
                                        <UITableViewDelegate,
                                         UITableViewDataSource,
                                         UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar        *searchBar;
@property (nonatomic, weak) IBOutlet UISegmentedControl *prioritySegment;
@property (nonatomic, weak) IBOutlet UITableView        *tableView;

- (TaskStatus)representedStatus;
- (NSString *)controllerTitle;

@end

