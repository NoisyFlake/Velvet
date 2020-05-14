@interface MTMaterialView : UIView
@end

@interface _UIBackdropViewSettings : NSObject
-(void)setColorTint:(UIColor *)arg1 ;
-(void)setColorTintAlpha:(double)arg1 ;
@end

@interface _UIBackdropView : UIView
-(id)initWithStyle:(long long)arg1 ;
-(_UIBackdropViewSettings *)inputSettings;
-(void)setInputSettings:(_UIBackdropViewSettings *)arg1 ;
-(void)setBlurRadius:(double)arg1 ;
-(void)setBlurRadiusSetOnce:(BOOL)arg1 ;
-(void)setBlurQuality:(id)arg1 ;
@end

@interface PLPlatterHeaderContentView : UIView
@end

@interface PLPlatterView : UIView
@property (nonatomic,readonly) MTMaterialView * backgroundMaterialView;
@property (nonatomic,readonly) UIView * customContentView;
@end

@interface VelvetIndicatorView : UIView
@end

@interface PLTitledPlatterView : PLPlatterView
@property (nonatomic,readonly) UIView * customContentView;
@end

@interface NCNotificationContentView : UIView
@end

@interface NCNotificationShortLookView : PLTitledPlatterView
@property (nonatomic,copy) NSArray * icons;
@property (getter=_notificationContentView,nonatomic,readonly) NCNotificationContentView * notificationContentView;
@property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
@property (retain, nonatomic) _UIBackdropView * blurView;
@end

@interface NCNotificationViewController : UIViewController
@end

@interface NCNotificationShortLookViewController : NCNotificationViewController
@property (nonatomic,readonly) NCNotificationShortLookView * viewForPreview;
@end