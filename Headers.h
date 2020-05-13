@interface PLPlatterHeaderContentView : UIView
@end

@interface MTMaterialView : UIView
@end

@interface MTPlatterView : UIView
@property (nonatomic,readonly) MTMaterialView * backgroundMaterialView;
@end

@interface MTTitledPlatterView : MTPlatterView
@end

@interface VelvetIndicatorView : UIView
@end

@interface NCNotificationShortLookView : MTTitledPlatterView
@property (nonatomic,copy) NSArray * icons;
@property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
@end

@interface NCNotificationViewController : UIViewController
@end

@interface NCNotificationShortLookViewController : NCNotificationViewController
@property (nonatomic,readonly) NCNotificationShortLookView * viewForPreview;
@end