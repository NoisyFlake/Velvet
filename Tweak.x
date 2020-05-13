#import "Headers.h"
#import "ColorSupport.h"

@implementation VelvetIndicatorView
@end

%hook NCNotificationShortLookView
%property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
%property (retain, nonatomic) UIBlurEffect * blurEffect;
%property (retain, nonatomic) UIVisualEffectView * blurEffectView;
%end

%hook NCNotificationShortLookViewController

- (void)viewDidLayoutSubviews {
	%orig;

	NCNotificationShortLookView *view = self.viewForPreview;

	// Notification view is not yet fully initialized
	if (view.frame.size.width == 0) return;

	if (view.colorIndicator == nil) {
		VelvetIndicatorView *colorIndicator = [[VelvetIndicatorView alloc] initWithFrame:CGRectZero];

		[view insertSubview:colorIndicator atIndex:1];
		view.colorIndicator = colorIndicator;

		// add blur effect view with blur effect style (regular adapts to user style)
		view.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
		view.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:view.blurEffect];
		[view insertSubview:view.blurEffectView atIndex:0];
		view.blurEffectView.alpha = 0.75; // change alpha (?)

		// view.backgroundMaterialView.layer.cornerRadius = 0;
		// view.backgroundMaterialView.alpha = 0;
		[view.backgroundMaterialView removeFromSuperview];
	}

	// Now update the frame and color (this is necessary every time because iOS might reuse this UIView for multiple notifications)

	if (YES) {
		view.colorIndicator.frame = CGRectMake(0, 0, 2, view.frame.size.height);
	} else {
		view.colorIndicator.frame = CGRectMake(0, 0, view.frame.size.width, 2);
	}
	view.blurEffectView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);

	UIImage *icon = view.icons[0];
	view.colorIndicator.backgroundColor = [icon velvetDominantColor];
}
%end