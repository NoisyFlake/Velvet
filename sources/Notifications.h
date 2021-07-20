#define ifDisabled(view) if ((isLockscreen(view) && ![preferences boolForKey:@"enableLockscreen"]) || (!isLockscreen(view) && ![preferences boolForKey:@"enableBanners"]))

@interface NCAuxiliaryOptionsView : UIView
@end

@interface BSUIDefaultDateLabel : UILabel
@end

@interface BSUIEmojiLabelView : UIView
@property (nonatomic,retain) UIColor * textColor;
@end

@interface NCNotificationContentView : UIView
@property (setter=_setPrimaryLabel:,getter=_primaryLabel,nonatomic,retain) UILabel * primaryLabel;
@property (setter=_setPrimarySubtitleLabel:,getter=_primarySubtitleLabel,nonatomic,retain) UILabel * primarySubtitleLabel;
@property (getter=_secondaryLabel,nonatomic,readonly) UILabel * secondaryLabel;
@property (setter=_setSummaryLabel:,getter=_summaryLabel,nonatomic,retain) BSUIEmojiLabelView * summaryLabel;
@end

@interface NCNotificationShortLookView : PLTitledPlatterView
@property (nonatomic,copy) NSArray * icons;
@property (getter=_notificationContentView,nonatomic,readonly) NCNotificationContentView * notificationContentView;
@property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
@property (retain, nonatomic) UIView * velvetBorder;
@property (retain, nonatomic) VelvetBackgroundView * velvetBackground;
@property (retain, nonatomic) UIImageView * imageIndicator;
@property (retain, nonatomic) UIImageView * imageIndicatorCorner;
@property (nonatomic,retain) UIImage * thumbnail;
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

@interface UIImageAsset (Private)
@property (nonatomic,copy,readonly) NSString* assetName;
@end

@interface NCNotificationContent : NSObject
@property (nonatomic,retain) UIImage * attachmentImage;
@end

@interface NCNotificationRequest : NSObject
@property (nonatomic,copy,readonly) NSString* sectionIdentifier;
@property (nonatomic,copy,readonly) NSString* threadIdentifier;
@property (nonatomic,retain) NCNotificationContent * content;
@property (nonatomic,copy,readonly) NSDictionary * context;
@property (nonatomic,readonly) UNNotification * userNotification;
@end

// @interface CNContact : NSObject
// @property (nonatomic,copy,readonly) NSData * imageData;
// @end

@interface NCNotificationViewController : UIViewController
@property (nonatomic,retain) NCNotificationRequest * notificationRequest;
@property (assign,nonatomic) UIView * associatedView;
@end

@interface NCNotificationShortLookViewController : NCNotificationViewController
@property (nonatomic,readonly) NCNotificationShortLookView * viewForPreview;
@property (retain, nonatomic) UIColor * kalmColor;
-(void)velvetHideHeader:(BOOL)hidden;
-(void)velvetHideGroupedNotifications:(BOOL)hidden;
-(UIColor *)getDominantColor;
-(UIImage *)getIconForBundleId:(NSString *)bundleId withMask:(BOOL)isMasked;
-(UIImage *)getContactPicture;
@end

@interface JBBulletinManager : NSObject
+(id)sharedInstance;
-(id)showBulletinWithTitle:(NSString *)title message:(NSString *)message bundleID:(NSString *)bundleID;
@end

@interface MRPlatterViewController : UIViewController
@property (nonatomic,readonly) UIView * contentView;
@property (nonatomic,retain) UIView * backgroundView;
@end

@interface PLShadowView : UIImageView
@end

@interface CNGroupIdentity : NSObject
@property (nonatomic,retain) NSData * groupPhoto;
@end

@interface CKConversation : NSObject
@property (nonatomic,retain) CNGroupIdentity * _conversationVisualIdentity;
@end

@interface CKConversationList : NSObject
@property (nonatomic,retain) NSMutableDictionary * conversationsDictionary;
+(id)sharedConversationList;
-(id)conversationForExistingChatWithGroupID:(id)arg1;
@end

static float getCornerRadius(UIView *view);
static float getAppIconCornerRadius(UIView *view);
static float getIndicatorOffset(UIView *view);
static BOOL isLockscreen(UIView *view);
static NSString *getPreferencesKeyFor(NSString *key, UIView *view);
static NSString *getColorFor(NSString *key, UIView *view);

static void createTestNotifications(int amount);
static void testRegular();
static void testLockscreen();
static BOOL isRTL();