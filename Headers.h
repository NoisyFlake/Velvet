#ifdef DEBUG
#define NSLog(fmt, ...) HBLogWarn((@"[Velvet] " fmt), ##__VA_ARGS__)
#else
#define NSLog(fmt, ...)
#endif

@interface UIImage (UIApplicationIconPrivate)
+(id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(double)arg3 ;
@end

@interface UIView (Velvet)
-(id)_viewControllerForAncestor;
@end

@interface CALayer (Undocumented)
@property (assign) BOOL continuousCorners;
@end

@interface MTMaterialView : UIView
@end

@interface PLPlatterView : UIView
@property (nonatomic,readonly) MTMaterialView * backgroundMaterialView;
@property (nonatomic,readonly) UIView * customContentView;
@end

@interface PLPlatterHeaderContentView : UIView {
	UIButton* _utilityButton;
}
@property (getter=_dateLabel,nonatomic, readonly) UILabel * dateLabel;
@property (getter=_titleLabel,nonatomic,readonly) UILabel * titleLabel;
@property (nonatomic,readonly) UIButton * utilityButton;
@end

@interface PLTitledPlatterView : PLPlatterView {
	PLPlatterHeaderContentView * _headerContentView;
}
@property (nonatomic,readonly) UIView * customContentView;
- (CGRect)_mainContentFrame;
@end

@interface VelvetIndicatorView : UIView
@end

@interface BSUIDefaultDateLabel : UILabel
@end

@interface NCNotificationContentView : UIView
@property (setter=_setPrimaryLabel:,getter=_primaryLabel,nonatomic,retain) UILabel * primaryLabel;
@property (setter=_setPrimarySubtitleLabel:,getter=_primarySubtitleLabel,nonatomic,retain) UILabel * primarySubtitleLabel;
@property (getter=_secondaryLabel,nonatomic,readonly) UILabel * secondaryLabel;
@end

@interface NCNotificationShortLookView : PLTitledPlatterView
@property (nonatomic,copy) NSArray * icons;
@property (getter=_notificationContentView,nonatomic,readonly) NCNotificationContentView * notificationContentView;
@property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
@property (retain, nonatomic) UIImageView * imageIndicator;
@end

@interface NCNotificationViewControllerView : UIView
@property (assign,nonatomic) PLPlatterView * contentView;
@end

@interface NCNotificationListCell : UIView
-(NCNotificationViewControllerView *)_notificationCellView;
@end

@interface NCNotificationListView : UIScrollView
@property(nonatomic, getter=isGrouped) BOOL grouped;
@property(nonatomic, getter=hasPerformedFirstLayout) BOOL performedFirstLayout;
@property(retain, nonatomic) NSMutableDictionary *visibleViews;
- (NCNotificationListCell *)_visibleViewAtIndex:(unsigned long long)index;
@end

@interface _NCNotificationShortLookScrollView : UIScrollView
@end

@interface NCNotificationRequest : NSObject
@property (nonatomic,copy,readonly) NSString* sectionIdentifier;
@end

@interface NCNotificationViewController : UIViewController
@property (nonatomic,retain) NCNotificationRequest * notificationRequest;
@property (assign,nonatomic) UIView * associatedView;
@end

@interface NCNotificationShortLookViewController : NCNotificationViewController
@property (nonatomic,readonly) NCNotificationShortLookView * viewForPreview;
-(void)velvetHideHeader;
-(UIColor *)getDominantColor;
@end

@interface JBBulletinManager : NSObject
+(id)sharedInstance;
-(id)showBulletinWithTitle:(NSString *)title message:(NSString *)message bundleID:(NSString *)bundleID;
@end