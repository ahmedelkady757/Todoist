//
//  AddTaskViewController.m
//  Todoist
//

#import "AddTaskViewController.h"
#import "Task.h"
#import "TaskManager.h"
#import "NotificationScheduler.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface AddTaskViewController () <UIDocumentPickerDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSMutableArray<NSString *> *attachedFilePaths;

@end

@implementation AddTaskViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.attachedFilePaths = [NSMutableArray array];
    [self styleUI];

    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)styleUI {
    self.title = @"New Task";

    self.descriptionView.delegate              = self;
    self.descriptionView.layer.cornerRadius    = 8.0;
    self.descriptionView.layer.borderWidth     = 0.5;
    self.descriptionView.layer.borderColor     = [UIColor separatorColor].CGColor;
    self.descriptionView.textContainerInset    = UIEdgeInsetsMake(8, 8, 8, 8);
    self.descriptionView.font                  = [UIFont systemFontOfSize:16.0];

    self.datePicker.hidden      = YES;
    self.datePickerLabel.hidden = YES;
    self.datePicker.minimumDate = [NSDate date];
    if (@available(iOS 14.0, *)) {
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleCompact;
    }

    self.saveButton.backgroundColor    = [UIColor systemBlueColor];
    self.saveButton.layer.cornerRadius = 12.0;
    self.saveButton.layer.masksToBounds = YES;
    [self.saveButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];

    self.pickFilesButton.contentHorizontalAlignment =
        UIControlContentHorizontalAlignmentLeft;
}

#pragma mark - IBActions

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)reminderSwitchToggled:(UISwitch *)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.datePicker.hidden      = !sender.isOn;
        self.datePickerLabel.hidden = !sender.isOn;
    }];
}

- (IBAction)pickFilesTapped:(id)sender {
    UIDocumentPickerViewController *picker;
    if (@available(iOS 14.0, *)) {
        picker = [[UIDocumentPickerViewController alloc]
                  initForOpeningContentTypes:@[UTTypeItem] asCopy:YES];
    } else {
        picker = [[UIDocumentPickerViewController alloc]
                  initWithDocumentTypes:@[@"public.item"]
                                 inMode:UIDocumentPickerModeImport];
    }
    picker.delegate               = self;
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

    NSString *desc = [self.descriptionView.text
                      stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    TaskPriority priority = (TaskPriority)self.prioritySegment.selectedSegmentIndex;

    Task *task = [[Task alloc] initWithTitle:title
                                 description:desc
                                    priority:priority];

    if (self.reminderSwitch.isOn) {
        task.reminderDate = self.datePicker.date;
        [NotificationScheduler scheduleNotificationForTask:task];
    }

    task.attachedFilePaths = self.attachedFilePaths;
    [[TaskManager sharedManager] addTask:task];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)documentPicker:(UIDocumentPickerViewController *)controller
didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    for (NSURL *url in urls) {
        NSString *path = url.path;
        if (path && ![self.attachedFilePaths containsObject:path]) {
            [self.attachedFilePaths addObject:path];
            [self addFileLabel:url.lastPathComponent];
        }
    }
}

- (void)addFileLabel:(NSString *)name {
    UILabel *lbl       = [[UILabel alloc] init];
    lbl.text           = [NSString stringWithFormat:@"📄  %@", name];
    lbl.font           = [UIFont systemFontOfSize:13.0];
    lbl.textColor      = [UIColor systemBlueColor];
    lbl.numberOfLines  = 1;
    [self.fileNamesStack addArrangedSubview:lbl];
}


- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


- (void)dismissKeyboard { [self.view endEditing:YES]; }

- (void)keyboardWillShow:(NSNotification *)n {
    CGRect kbFrame = [n.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, kbFrame.size.height, 0);
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
