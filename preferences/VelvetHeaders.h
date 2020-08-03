#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#include "../sources/VelvetPrefs.h"

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

@interface UIView (Velvet)
-(id)_viewControllerForAncestor;
@end

@interface UINavigationItem (Velvet)
@property (assign,nonatomic) UINavigationBar * navigationBar;
@end

@interface PSSpecifier (Velvet)
-(void)setValues:(id)arg1 titles:(id)arg2 ;
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

@interface VelvetColorListSelector : PSTableCell
@end

@interface PSSwitchTableCell : PSControlTableCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(id)specifier;
@end

@interface VelvetToggle : PSSwitchTableCell
@end

@interface VelvetBaseController : PSListController
-(VelvetPrefs *)preferences;
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

@interface VelvetColorListController : VelvetBaseController
@end

@interface VelvetColorListCell : PSTableCell
@end


@interface SparkColourPickerView : UIView
@end

@interface SparkColourPickerCell : PSTableCell
@property (nonatomic, strong, readwrite) NSMutableDictionary *options;
@property (nonatomic, strong, readwrite) SparkColourPickerView *colourPickerView;
-(void)colourPicker:(id)picker didUpdateColour:(UIColor*) colour;
-(void)openColourPicker;
-(void)dismissPicker;
@end

@interface VelvetColorPicker : SparkColourPickerCell
@property (nonatomic, retain) UIView *colorPreview;
@property (nonatomic, retain) UIColor *currentColor;
@end