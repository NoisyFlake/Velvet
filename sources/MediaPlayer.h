#import <MediaRemote/MediaRemote.h>

@interface CFWPrefsManager : NSObject
@property(nonatomic, assign, getter=isLockScreenEnabled) BOOL lockScreenEnabled;
@property(nonatomic, assign) BOOL lockScreenFullScreenEnabled;
+ (instancetype)sharedInstance;
@end

@interface CSCoverSheetViewControllerBase : UIViewController
@end

@interface SBFTouchPassThroughView : UIView
@end

@interface CSCoverSheetViewBase : SBFTouchPassThroughView
@end

@interface CSMediaControlsView : CSCoverSheetViewBase
@end

static float getCornerRadius();
static void updateMediaplayerColors();
static BOOL colorFlowLockscreenColoringEnabled();
static BOOL colorFlowLockscreenResizingEnabled();
static void colorMediaplayerWithThirdParty(UIColor *color);