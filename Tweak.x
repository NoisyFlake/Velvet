#import "Headers.h"
#import "ColorSupport.h"

int style = 2;

@implementation VelvetIndicatorView
@end

%hook NCNotificationShortLookView
%property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
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
	}

	// Now update the frame and color (this is necessary every time because iOS might reuse this UIView for multiple notifications)

	switch (style) {
        case 1:
			{
				view.colorIndicator.frame = CGRectMake(0, 0, view.frame.size.width, 4); // full indicator top
				view.colorIndicator.layer.cornerRadius = 0;
        	} break;
        case 2:
			{
				view.colorIndicator.frame = CGRectMake(0, 0, 4, view.frame.size.height); // full indicator left
				view.colorIndicator.layer.cornerRadius = 0;
        	} break;
        case 3:
			{
				float width = 3;
				view.colorIndicator.frame = CGRectMake(20, 20, width, view.frame.size.height-40);
				view.colorIndicator.layer.cornerRadius = width/2;
				view.colorIndicator.layer.continuousCorners = YES;

				PLPlatterHeaderContentView *header = [view valueForKey:@"_headerContentView"];
				header.alpha = 0;
        	} break;
        default:
	        {
				view.colorIndicator.frame = CGRectMake(0, 0, 4, view.frame.size.height); // full indicator left
				view.colorIndicator.layer.cornerRadius = 0;
        	} break;
	}

	UIImage *icon = view.icons[0];
	view.colorIndicator.backgroundColor = [icon velvetDominantColor];
}
%end

%hook PLTitledPlatterView
- (CGRect)_mainContentFrame {
	CGRect frame = %orig;
	if (style == 3) {
		frame.origin.y = frame.origin.y - 14;
		frame.origin.x = frame.origin.x + 25;
		frame.size.width = frame.size.width - 50;
	}
	return frame;
}
%end