#import "Headers.h"
#import "ColorSupport.h"

@implementation VelvetIndicatorView
@end

%hook NCNotificationShortLookView
%property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
%property (retain, nonatomic) _UIBackdropView * blurView;
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

		view.blurView = [[_UIBackdropView alloc] initWithStyle:4007];
		// _UIBackdropViewSettings *settings = [view.blurView inputSettings];
		// [settings setColorTint:[UIColor colorWithRed:0.5 green:0.5 blue:0.0 alpha:1.0]];
		// [settings setColorTintAlpha:0.1];
		// [view.blurView setInputSettings:settings];
		// [view.blurView setBlurRadiusSetOnce:NO];
		// [view.blurView setBlurRadius:3.0];
		// [view.blurView setBlurQuality:@"default"];
		[view insertSubview:view.blurView atIndex:0];

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

	UIImage *icon = view.icons[0];
	view.colorIndicator.backgroundColor = [icon velvetDominantColor];
}
%end