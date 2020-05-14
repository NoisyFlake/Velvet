@interface MTMaterialView : UIView
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
@property (retain, nonatomic) UIBlurEffect * blurEffect;
@property (retain, nonatomic) UIVisualEffectView * blurEffectView;
@property (retain, nonatomic) UIVibrancyEffect * vibrancyEffect;
@property (retain, nonatomic) UIVisualEffectView * vibrancyEffectView;
@end

@interface NCNotificationViewController : UIViewController
@end

@interface NCNotificationShortLookViewController : NCNotificationViewController
@property (nonatomic,readonly) NCNotificationShortLookView * viewForPreview;
@end