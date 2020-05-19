#import <Preferences/PSListController.h>

#define kVELVETCOLOR [UIColor colorWithRed:0.99 green:0.80 blue:0.00 alpha: 1.00]
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface VelvetBaseController : PSListController
@end

@interface VelvetRootListController : VelvetBaseController
@end

@interface UINavigationItem (Velvet)
@property (assign,nonatomic) UINavigationBar * navigationBar;
@end
