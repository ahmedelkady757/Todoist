//
//  AddTaskViewController.h
//  Todoist
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddTaskViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField        *titleField;
@property (nonatomic, weak) IBOutlet UITextView         *descriptionView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *prioritySegment;
@property (nonatomic, weak) IBOutlet UISwitch           *reminderSwitch;
@property (nonatomic, weak) IBOutlet UIDatePicker       *datePicker;
@property (nonatomic, weak) IBOutlet UILabel            *datePickerLabel;
@property (nonatomic, weak) IBOutlet UIButton           *pickFilesButton;
@property (nonatomic, weak) IBOutlet UIStackView        *fileNamesStack;
@property (nonatomic, weak) IBOutlet UIButton           *saveButton;
@property (nonatomic, weak) IBOutlet UIScrollView       *scrollView;

- (IBAction)reminderSwitchToggled:(UISwitch *)sender;
- (IBAction)pickFilesTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;

@end

NS_ASSUME_NONNULL_END
