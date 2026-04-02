//
//  EditTaskViewController.m
//  Todoist
//

#import "EditTaskViewController.h"
#import "TaskManager.h"
#import "NotificationScheduler.h"
#import <QuickLook/QuickLook.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface EditTaskViewController () <UIDocumentPickerDelegate,
                                      UITextViewDelegate,
                                      QLPreviewControllerDataSource>

@property (nonatomic, strong) NSMutableArray<NSString *> *workingFilePaths;
@property (nonatomic, strong) NSString *previewFilePath;

@end

@implementation EditTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.workingFilePaths = [self.task.attachedFilePaths mutableCopy] ?: [NSMutableArray array];
    [self styleUI];
    [self populateFields];

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)styleUI {
    self.title = @"Edit Task";

    // Description text view
    self.descriptionView.delegate           = self;
    self.descriptionView.layer.cornerRadius = 8.0;
    self.descriptionView.layer.borderWidth  = 0.5;
    self.descriptionView.layer.borderColor  = [UIColor separatorColor].CGColor;
    self.descriptionView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    self.descriptionView.font               = [UIFont systemFontOfSize:16.0];

    self.statusHintLabel.font          = [UIFont systemFontOfSize:12.0];
    self.statusHintLabel.textColor     = [UIColor systemOrangeColor];
    self.statusHintLabel.numberOfLines = 2;

    self.datePicker.hidden      = YES;
    self.datePickerLabel.hidden = YES;
    self.datePicker.minimumDate    = [NSDate date];
    if (@available(iOS 14.0, *)) {
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleCompact;
    }

    self.saveButton.backgroundColor     = [UIColor systemBlueColor];
    self.saveButton.layer.cornerRadius  = 12.0;
    self.saveButton.layer.masksToBounds = YES;
    [self.saveButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];

    self.addFileButton.contentHorizontalAlignment =
        UIControlContentHorizontalAlignmentLeft;
}


- (void)populateFields {
    self.titleField.text       = self.task.title;
    self.descriptionView.text  = self.task.taskDescription ?: @"";
    self.prioritySegment.selectedSegmentIndex = (NSInteger)self.task.priority;
    self.statusSegment.selectedSegmentIndex   = (NSInteger)self.task.status;

    [self applyStatusRestrictions];

    if (self.task.reminderDate) {
        self.reminderSwitch.on      = YES;
        self.datePicker.hidden      = NO;
        self.datePickerLabel.hidden = NO;
        self.datePicker.date        = self.task.reminderDate;
    }

    [self rebuildFileList];
}

#pragma mark - Status One-Way Enforcement

- (void)applyStatusRestrictions {
    // Disable all first
    for (NSUInteger i = 0; i < 3; i++) {
        [self.statusSegment setEnabled:NO forSegmentAtIndex:i];
    }

    switch (self.task.status) {
        case TaskStatusTodo:
            [self.statusSegment setEnabled:YES forSegmentAtIndex:TaskStatusTodo];
            [self.statusSegment setEnabled:YES forSegmentAtIndex:TaskStatusDoing];
            self.statusHintLabel.text = @"Can advance to Doing";
            break;

        case TaskStatusDoing:
            [self.statusSegment setEnabled:YES forSegmentAtIndex:TaskStatusDoing];
            [self.statusSegment setEnabled:YES forSegmentAtIndex:TaskStatusDone];
            self.statusHintLabel.text = @"Can advance to Done";
            break;

        case TaskStatusDone:
            [self.statusSegment setEnabled:YES forSegmentAtIndex:TaskStatusDone];
            self.statusHintLabel.text = @"Task complete";
            break;
    }
}


- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)statusSegmentChanged:(UISegmentedControl *)sender {
    NSInteger newIdx     = sender.selectedSegmentIndex;
    NSInteger currentIdx = (NSInteger)self.task.status;

    if (newIdx < currentIdx) {
        sender.selectedSegmentIndex = currentIdx;
        [self showAlert:@"Not Allowed"
                message:@"You cannot move a task backwards in the workflow."];
        return;
    }

    if (newIdx > currentIdx + 1) {
        sender.selectedSegmentIndex = currentIdx;
        [self showAlert:@"Not Allowed"
                message:@"You must advance one step at a time."];
        return;
    }
}

- (IBAction)reminderSwitchToggled:(UISwitch *)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.datePicker.hidden      = !sender.isOn;
        self.datePickerLabel.hidden = !sender.isOn;
    }];
}

- (IBAction)addFileTapped:(id)sender {
    UIDocumentPickerViewController *picker;
    if (@available(iOS 14.0, *)) {
        picker = [[UIDocumentPickerViewController alloc]
                  initForOpeningContentTypes:@[UTTypeItem] asCopy:YES];
    } else {
        picker = [[UIDocumentPickerViewController alloc]
                  initWithDocumentTypes:@[@"public.item"]
                                 inMode:UIDocumentPickerModeImport];
    }
    picker.delegate                = self;
    picker.allowsMultipleSelection = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)saveTapped:(id)sender {
    NSString *title = [self.titleField.text
                       stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (title.length == 0) {
        [self showAlert:@"Title Required"
                message:@"Please enter a title for the task."];
        return;
    }

    self.task.title           = title;
    self.task.taskDescription = [self.descriptionView.text
                                 stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.prioritySegment && self.prioritySegment.selectedSegmentIndex >= 0) {
        self.task.priority = (TaskPriority)self.prioritySegment.selectedSegmentIndex;
    }
    if (self.statusSegment && self.statusSegment.selectedSegmentIndex >= 0) {
        self.task.status = (TaskStatus)self.statusSegment.selectedSegmentIndex;
    }
    self.task.attachedFilePaths = self.workingFilePaths;

    if (self.reminderSwitch.isOn) {
        self.task.reminderDate = self.datePicker.date;
        [NotificationScheduler scheduleNotificationForTask:self.task];
    } else {
        [NotificationScheduler cancelNotificationForTask:self.task];
        self.task.reminderDate = nil;
    }

    [[TaskManager sharedManager] updateTask:self.task];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)rebuildFileList {
    for (UIView *v in self.fileListStack.arrangedSubviews) {
        [self.fileListStack removeArrangedSubview:v];
        [v removeFromSuperview];
    }
    for (NSString *path in self.workingFilePaths) {
        [self.fileListStack addArrangedSubview:[self fileRowForPath:path]];
    }
}

- (UIView *)fileRowForPath:(NSString *)path {
    UIStackView *row = [[UIStackView alloc] init];
    row.axis      = UILayoutConstraintAxisHorizontal;
    row.spacing   = 8.0;
    row.alignment = UIStackViewAlignmentCenter;

    UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [nameBtn setTitle:[NSString stringWithFormat:@"📄 %@", [path lastPathComponent]]
             forState:UIControlStateNormal];
    nameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    nameBtn.titleLabel.numberOfLines   = 1;
    nameBtn.accessibilityHint          = path;
    [nameBtn addTarget:self action:@selector(openFileTapped:)
      forControlEvents:UIControlEventTouchUpInside];

    UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [delBtn setImage:[UIImage systemImageNamed:@"trash"] forState:UIControlStateNormal];
    delBtn.tintColor         = [UIColor systemRedColor];
    delBtn.accessibilityHint = path;
    [delBtn addTarget:self action:@selector(removeFileTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    [[delBtn widthAnchor] constraintEqualToConstant:36.0].active = YES;

    [row addArrangedSubview:nameBtn];
    [row addArrangedSubview:delBtn];
    return row;
}

- (void)openFileTapped:(UIButton *)sender {
    NSString *path = sender.accessibilityHint;
    if (!path) return;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [self showAlert:@"File Not Found"
                message:@"The attached file could not be located on this device."];
        return;
    }
    self.previewFilePath = path;
    QLPreviewController *ql = [[QLPreviewController alloc] init];
    ql.dataSource = self;
    [self presentViewController:ql animated:YES completion:nil];
}

- (void)removeFileTapped:(UIButton *)sender {
    NSString *path = sender.accessibilityHint;
    if (!path) return;
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Remove Attachment"
                                            message:[NSString stringWithFormat:
                                                     @"Remove %@?",
                                                     [path lastPathComponent]]
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Remove"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction *a) {
        [self.workingFilePaths removeObject:path];
        [self rebuildFileList];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)documentPicker:(UIDocumentPickerViewController *)controller
didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    for (NSURL *url in urls) {
        NSString *path = url.path;
        if (path && ![self.workingFilePaths containsObject:path]) {
            [self.workingFilePaths addObject:path];
        }
    }
    [self rebuildFileList];
}


- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)c { return 1; }
- (id<QLPreviewItem>)previewController:(QLPreviewController *)c
                    previewItemAtIndex:(NSInteger)i {
    return [NSURL fileURLWithPath:self.previewFilePath];
}


- (BOOL)textView:(UITextView *)tv shouldChangeTextInRange:(NSRange)r
 replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) { [tv resignFirstResponder]; return NO; }
    return YES;
}


- (void)dismissKeyboard { [self.view endEditing:YES]; }
- (void)keyboardWillShow:(NSNotification *)n {
    CGRect kb = [n.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, kb.size.height, 0);
    self.scrollView.contentInset          = insets;
    self.scrollView.scrollIndicatorInsets = insets;
}
- (void)keyboardWillHide:(NSNotification *)n {
    self.scrollView.contentInset          = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}


- (void)showAlert:(NSString *)title message:(NSString *)msg {
    UIAlertController *a =
        [UIAlertController alertControllerWithTitle:title
                                            message:msg
                                     preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK"
                                          style:UIAlertActionStyleDefault
                                        handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

@end
