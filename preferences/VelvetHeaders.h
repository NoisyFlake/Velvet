#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>

#define kVELVETCOLOR UIColor.orangeColor
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface UINavigationItem (Velvet)
@property (assign,nonatomic) UINavigationBar * navigationBar;
@end

@interface PSControlTableCell : PSTableCell
@property (nonatomic, retain) UIControl *control;
@end

@interface PSSwitchTableCell : PSControlTableCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(id)specifier;
@end

@interface VelvetToggle : PSSwitchTableCell
@end

@interface VelvetBaseController : PSListController
@end

@interface VelvetRootListController : VelvetBaseController
@end