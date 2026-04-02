//
//  EditTaskViewController.h
//  Todoist
//

#import <UIKit/UIKit.h>
#import "Task.h"


@interface EditTaskViewController : UIViewController

@property (nonatomic, strong) Task *task;

@property (nonatomic, weak) IBOutlet UITextField        *titleField;
@property (nonatomic, weak) IBOutlet UITextView         *descriptionView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *statusSegment;
@property (nonatomic, weak) IBOutlet UILabel            *statusHintLabel;
@property (nonatomic, weak) IBOutlet UISegmentedControl *prioritySegment;
@property (nonatomic, weak) IBOutlet UISwitch           *reminderSwitch;
@property (nonatomic, weak) IBOutlet UIDatePicker       *datePicker;
@property (nonatomic, weak) IBOutlet UILabel            *datePickerLabel;
@property (nonatomic, weak) IBOutlet UIButton           *addFileButton;
@property (nonatomic, weak) IBOutlet UIStackView        *fileListStack;
@property (nonatomic, weak) IBOutlet UIButton           *saveButton;
@property (nonatomic, weak) IBOutlet UIScrollView       *scrollView;

- (IBAction)statusSegmentChanged:(UISegmentedControl *)sender;
- (IBAction)reminderSwitchToggled:(UISwitch *)sender;
- (IBAction)addFileTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;

@end

