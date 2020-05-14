@interface CALayer (Undocumented)
@property (assign) BOOL continuousCorners;
@end

@interface MTMaterialView : UIView
@end

@interface PLPlatterView : UIView
@property (nonatomic,readonly) MTMaterialView * backgroundMaterialView;
@property (nonatomic,readonly) UIView * customContentView;
@end

@interface PLPlatterHeaderContentView : UIView
@end

@interface PLTitledPlatterView : PLPlatterView {
	PLPlatterHeaderContentView * _headerContentView;
}
@property (nonatomic,readonly) UIView * customContentView;
- (CGRect)_mainContentFrame;
@end

@interface VelvetIndicatorView : UIView
@end

@interface NCNotificationContentView : UIView
@end

@interface NCNotificationShortLookView : PLTitledPlatterView
@property (nonatomic,copy) NSArray * icons;
@property (getter=_notificationContentView,nonatomic,readonly) NCNotificationContentView * notificationContentView;
@property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
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

@interface NCNotificationViewController : UIViewController
@end

@interface NCNotificationShortLookViewController : NCNotificationViewController
@property (nonatomic,readonly) NCNotificationShortLookView * viewForPreview;
@end