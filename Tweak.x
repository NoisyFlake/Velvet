#import "Headers.h"
#import "ColorSupport.h"

@implementation VelvetIndicatorView
@end

%hook NCNotificationShortLookView
%property (retain, nonatomic) VelvetIndicatorView *colorIndicator;
%end

%hook NCNotificationShortLookViewController

-(void)viewDidLayoutSubviews {
	%orig;

	NCNotificationShortLookView *view = self.viewForPreview;

	// Notification view is not yet fully initialized
	if (view.frame.size.width == 0) return;

	if (view.colorIndicator == nil) {
		VelvetIndicatorView *colorIndicator = [[VelvetIndicatorView alloc] initWithFrame:CGRectZero];

		[view insertSubview:colorIndicator atIndex:1];
		view.colorIndicator = colorIndicator;

		view.backgroundMaterialView.layer.cornerRadius = 0;
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