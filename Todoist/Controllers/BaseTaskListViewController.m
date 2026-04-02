//
//  BaseTaskListViewController.m
//  Todoist
//

#import "BaseTaskListViewController.h"
#import "TaskManager.h"
#import "EditTaskViewController.h"

@interface BaseTaskListViewController ()

@property (nonatomic, strong) NSArray<Task *> *lowTasks;
@property (nonatomic, strong) NSArray<Task *> *mediumTasks;
@property (nonatomic, strong) NSArray<Task *> *highTasks;

@property (nonatomic, assign) NSInteger selectedPriorityIndex;
@property (nonatomic, strong) NSString  *currentSearchText;

@end

@implementation BaseTaskListViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title                  = [self controllerTitle];
    self.selectedPriorityIndex  = 0;
    self.currentSearchText      = @"";
    self.lowTasks    = @[];
    self.mediumTasks = @[];
    self.highTasks   = @[];

    [self styleUI];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTaskData)
                                                 name:TaskManagerDidUpdateTasksNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadTaskData];
}


- (TaskStatus)representedStatus { return TaskStatusTodo; }
- (NSString *)controllerTitle   { return @""; }


- (void)styleUI {
 

    self.searchBar.placeholder = @"Search by task title…";
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.delegate = self;

    self.prioritySegment.selectedSegmentIndex = 0;
    [self.prioritySegment addTarget:self
                             action:@selector(segmentChanged:)
                   forControlEvents:UIControlEventValueChanged];

    self.tableView.delegate          = self;
    self.tableView.dataSource        = self;
    self.tableView.rowHeight         = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 68.0;
}


- (void)reloadTaskData {
    TaskManager *mgr = [TaskManager sharedManager];

    NSArray<Task *> *source;
    switch ([self representedStatus]) {
        case TaskStatusTodo:  source = mgr.todoTasks;  break;
        case TaskStatusDoing: source = mgr.doingTasks; break;
        case TaskStatusDone:  source = mgr.doneTasks;  break;
        default:              source = @[];
    }

    if (self.currentSearchText.length > 0) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:
                             @"title CONTAINS[cd] %@", self.currentSearchText];
        source = [source filteredArrayUsingPredicate:pred];
    }

    self.lowTasks    = [self filter:source priority:TaskPriorityLow];
    self.mediumTasks = [self filter:source priority:TaskPriorityMedium];
    self.highTasks   = [self filter:source priority:TaskPriorityHigh];

    [self updateEmptyState];
    [self.tableView reloadData];
}

- (NSArray<Task *> *)filter:(NSArray<Task *> *)tasks priority:(TaskPriority)p {
    return [tasks filteredArrayUsingPredicate:
            [NSPredicate predicateWithFormat:@"priority == %ld", (long)p]];
}

- (void)updateEmptyState {
    NSInteger total = (NSInteger)(self.lowTasks.count +
                                  self.mediumTasks.count +
                                  self.highTasks.count);
    if (total == 0) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:self.tableView.bounds];
        lbl.text           = @"No tasks here.\n";
        lbl.textColor      = [UIColor systemGrayColor];
        lbl.numberOfLines  = 0;
        lbl.textAlignment  = NSTextAlignmentCenter;
        lbl.font           = [UIFont systemFontOfSize:17.0 weight:UIFontWeightMedium];
        self.tableView.backgroundView = lbl;
    } else {
        self.tableView.backgroundView = nil;
    }
}


- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    self.selectedPriorityIndex = sender.selectedSegmentIndex;
    [self reloadTaskData];
}


- (NSArray<Task *> *)tasksForSection:(NSInteger)section {
    if (self.selectedPriorityIndex == 0) {
        switch (section) {
            case 0: return self.lowTasks;
            case 1: return self.mediumTasks;
            case 2: return self.highTasks;
            default: return @[];
        }
    }
    switch (self.selectedPriorityIndex) {
        case 1: return self.lowTasks;
        case 2: return self.mediumTasks;
        case 3: return self.highTasks;
        default: return @[];
    }
}

- (Task *)taskAtIndexPath:(NSIndexPath *)indexPath {
    return [self tasksForSection:indexPath.section][indexPath.row];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.selectedPriorityIndex == 0) ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)[self tasksForSection:section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.selectedPriorityIndex != 0) return nil;
    switch (section) {
        case 0: return @"🟢 Low Priority";
        case 1: return @"🟡 Medium Priority";
        case 2: return @"🔴 High Priority";
        default: return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 68.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"TaskCell"];
        cell.accessoryType                  = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.numberOfLines  = 2;
        cell.detailTextLabel.textColor      = [UIColor secondaryLabelColor];
        cell.detailTextLabel.font           = [UIFont systemFontOfSize:13.0];
    }

    Task *task = [self taskAtIndexPath:indexPath];
    cell.textLabel.text       = task.title;
    cell.detailTextLabel.text = (task.taskDescription.length > 0)
                                    ? task.taskDescription
                                    : @"No description";

    NSString *imgName;
    switch (task.priority) {
        case TaskPriorityLow:    imgName = @"low";  break;
        case TaskPriorityMedium: imgName = @"medium";  break;
        case TaskPriorityHigh:   imgName = @"high";  break;
    }
    
    cell.imageView.image =
        [UIImage imageNamed:imgName ];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Task *task = [[self taskAtIndexPath:indexPath] copy];

    EditTaskViewController *editVC =
        [self.storyboard instantiateViewControllerWithIdentifier:@"EditTaskViewController"];
    editVC.task = task;

    UINavigationController *nav =
        [[UINavigationController alloc] initWithRootViewController:editVC];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle != UITableViewCellEditingStyleDelete) return;

    Task *task = [self taskAtIndexPath:indexPath];
    NSString *msg = [NSString stringWithFormat:
                     @"Permanently delete \"%@\"?", task.title];

    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Delete Task"
                                            message:msg
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    [alert addAction:[UIAlertAction
                      actionWithTitle:@"Delete"
                                style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction *a) {
        [[TaskManager sharedManager] deleteTaskWithId:task.taskId];
        [self reloadTaskData];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.currentSearchText = searchText;
    [self reloadTaskData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text         = @"";
    self.currentSearchText = @"";
    [searchBar resignFirstResponder];
    [self reloadTaskData];
}

@end
