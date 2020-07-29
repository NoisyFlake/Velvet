#ifdef DEBUG
#define NSLog(fmt, ...) NSLog((@"[Velvet] " fmt), ##__VA_ARGS__)
#else
#define NSLog(fmt, ...)
#endif

@interface NSObject (Velvet)
- (id)safeValueForKey:(id)arg1;
@end

@interface UIImage (UIApplicationIconPrivate)
+(id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(double)arg3 ;
@end

@interface NSNotificationCenter (Velvet)
- (void)addUniqueObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object;
@end

@interface UIView (Velvet)
-(id)_viewControllerForAncestor;
@end

@interface CALayer (Undocumented)
@property (assign) BOOL continuousCorners;
@end

@interface MTMaterialView : UIView
@end

@interface VelvetBackgroundView : UIView
@end

@interface VelvetIndicatorView : UIView
@end

@interface PLPlatterCustomContentView : UIView
@end

@interface PLPlatterHeaderContentView : UIView {
	UIButton* _utilityButton;
}
@property (getter=_dateLabel,nonatomic, readonly) UILabel * dateLabel;
@property (getter=_titleLabel,nonatomic,readonly) UILabel * titleLabel;
@property (nonatomic,readonly) NSArray * iconButtons;
@property (nonatomic,readonly) UIButton * utilityButton;
@property (nonatomic,copy) NSArray * icons;
@end

@interface PLPlatterView : UIView
@property (nonatomic,readonly) MTMaterialView * backgroundMaterialView;
@property (nonatomic,readonly) UIView * customContentView;
@end

@interface PLTitledPlatterView : PLPlatterView {
	PLPlatterHeaderContentView * _headerContentView;
}
@property (nonatomic,readonly) UIView * customContentView;
- (CGRect)_mainContentFrame;
@end

@interface KalmAPI
+ (UIColor *)getColor;
@end

@interface SBLockScreenManager : NSObject
-(void)lockUIFromSource:(int)arg1 withOptions:(id)arg2 ;
@end

@interface LSApplicationProxy
@property (nonatomic,readonly) NSString * applicationType;
@property (nonatomic,readonly) NSString * applicationIdentifier;
@property (getter=isRestricted,nonatomic,readonly) BOOL restricted;
@property (nonatomic,readonly) NSArray * appTags;
@property (getter=isLaunchProhibited,nonatomic,readonly) BOOL launchProhibited;
@property (getter=isPlaceholder,nonatomic,readonly) BOOL placeholder;
@property (getter=isRemovedSystemApp,nonatomic,readonly) BOOL removedSystemApp;
-(id)localizedNameForContext:(id)arg1 ;
@end

@interface LSApplicationWorkspace : NSObject
+(id)defaultWorkspace;
-(id)allInstalledApplications;
@end

@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * displayName;
@end

@interface SBApplicationController : NSObject
+(id)sharedInstance;
-(id)applicationWithBundleIdentifier:(id)arg1;
@end

struct SBIconImageInfo {
    struct CGSize size;
    double scale;
    double continuousCornerRadius;
};

@interface SBIcon : NSObject
-(id)generateIconImageWithInfo:(struct SBIconImageInfo)info;
-(id)unmaskedIconImageWithInfo:(struct SBIconImageInfo)arg1 ;
@end

@interface SBHIconModel : NSObject
@end

@interface SBIconModel : SBHIconModel
-(id)expectedIconForDisplayIdentifier:(id)arg1;
@end

@interface SBIconController : UIViewController
@property (nonatomic,retain) SBIconModel * model;
+(id)sharedInstance;
@end

@interface UIImage (Velvet)
+(id)systemImageNamed:(id)arg1;
@end

@interface UIColor (Velvet)
+(id)labelColor;
@end