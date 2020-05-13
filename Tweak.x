#import "ColorSupport.h"

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
@property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
@end

@interface NCNotificationViewController : UIViewController
@end

@interface NCNotificationShortLookViewController : NCNotificationViewController
@property (nonatomic,readonly) NCNotificationShortLookView * viewForPreview;
@end



@implementation VelvetIndicatorView
@end

%hook PLPlatterHeaderContentView
- (void)setIcons:(NSArray *)arg1 {
	%orig;

	if (![self.superview isKindOfClass:%c(NCNotificationShortLookView)]) return;

	VelvetIndicatorView *colorIndicator = ((NCNotificationShortLookView *)self.superview).colorIndicator;

	if (colorIndicator) {
		UIImage *icon = arg1[0];
		colorIndicator.backgroundColor = [icon velvetDominantColor];
	}
}
%end

%hook NCNotificationShortLookView
%property (retain, nonatomic) VelvetIndicatorView *colorIndicator;
%end

%hook NCNotificationShortLookViewController

- (void)viewDidLoad {
	%orig;

	NCNotificationShortLookView *view = self.viewForPreview;

	view.colorIndicator = [[VelvetIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 359, 2)];
	[view insertSubview:view.colorIndicator atIndex:1];

	view.backgroundMaterialView.layer.cornerRadius = 0;
}
%end