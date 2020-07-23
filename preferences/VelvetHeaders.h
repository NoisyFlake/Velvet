#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>

#define kVELVETCOLOR [UIColor colorWithRed: 0.46 green: 0.83 blue: 1.00 alpha: 1.00]
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface NSTask : NSObject
- (instancetype)init;
- (void)setLaunchPath:(NSString *)path;
- (void)setArguments:(NSArray *)arguments;
- (void)setStandardOutput:(id)output;
- (void)launch;
- (void)waitUntilExit;
@end

@interface UINavigationItem (Velvet)
@property (assign,nonatomic) UINavigationBar * navigationBar;
@end

@interface PSSegmentableSlider : UISlider
@end

@interface PSControlTableCell : PSTableCell
@property (nonatomic, retain) UIControl *control;
@end

@interface PSSliderTableCell : PSControlTableCell
@end

@interface VelvetSlider : PSSliderTableCell
@end

@interface VelvetButton : PSTableCell
@end

@interface PSSwitchTableCell : PSControlTableCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(id)specifier;
@end

@interface VelvetToggle : PSSwitchTableCell
@end

@interface VelvetBaseController : PSListController
-(NSUserDefaults *)preferences;
@end

@interface VelvetRootListController : VelvetBaseController
@end

@interface VelvetLockscreenController : VelvetBaseController
@end

@interface VelvetMediaplayerController : VelvetBaseController
@end

@interface VelvetWidgetController : VelvetBaseController
@end

@interface VelvetBannerController : VelvetBaseController
@end

@interface PSListItemsController : PSListController
@end

@interface VelvetListItemsController : PSListItemsController
@end