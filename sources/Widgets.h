@interface WGPlatterHeaderContentView : PLPlatterHeaderContentView
@end

@interface WGWidgetPlatterView : UIView
@property (retain, nonatomic) UIView * contentView;
@property (retain, nonatomic) UIView * velvetBorder;
@property (retain, nonatomic) UIView * velvetFullBorder;
@property (retain, nonatomic) VelvetBackgroundView * velvetBackground;
@end

@interface WGWidgetInfo : NSObject
@property (setter=_setIcon:,getter=_icon,nonatomic,retain) UIImage * icon;
@property (nonatomic,copy,readonly) NSString * widgetIdentifier;
@end

@interface WGWidgetHostingViewController : UIViewController
@property (nonatomic,readonly) WGWidgetInfo * widgetInfo;
@property (nonatomic,copy,readonly) NSString * widgetIdentifier; 
@property (nonatomic,copy,readonly) NSString * displayName;
@end

@interface WGWidgetListItemViewController : UIViewController
@property (nonatomic,readonly) WGWidgetHostingViewController * widgetHost;
@property (nonatomic,copy,readonly) NSString * widgetIdentifier; 
-(void)velvetColorize;
@end

static float getCornerRadius();