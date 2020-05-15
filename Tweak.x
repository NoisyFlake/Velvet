#import "Headers.h"
#import "ColorSupport.h"

int style = 5;

@implementation VelvetIndicatorView
@end

%hook NCNotificationShortLookView
%property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
%property (retain, nonatomic) UIImageView * imageIndicator;
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

	if (view.imageIndicator == nil) {
		UIImageView *imageIndicator = [[UIImageView alloc] initWithFrame:CGRectZero];

		[view insertSubview:imageIndicator atIndex:1];
		view.imageIndicator = imageIndicator;
	}

	// Now update the frame and color (this is necessary every time because iOS might reuse this UIView for multiple notifications)

	switch (style) {
        case 1: // full bar bottom
			{
				view.colorIndicator.frame = CGRectMake(0, 0, view.frame.size.width, 4);
				view.colorIndicator.layer.cornerRadius = 0;
				view.backgroundMaterialView.layer.cornerRadius = 0;
        	} break;
        case 2: // full bar left
			{
				view.colorIndicator.frame = CGRectMake(0, 0, 4, view.frame.size.height);
				view.colorIndicator.layer.cornerRadius = 0;
				view.backgroundMaterialView.layer.cornerRadius = 0;
        	} break;
        case 3: // rounded bar left
			{
				float width = 3;
				view.colorIndicator.frame = CGRectMake(20, 20, width, view.frame.size.height-40);
				view.colorIndicator.layer.cornerRadius = width/2;
				view.colorIndicator.layer.continuousCorners = YES;

				// hide header elements
				PLPlatterHeaderContentView *header = [view valueForKey:@"_headerContentView"];

				for (UIView *subview in header.subviews) {
					if ([subview isKindOfClass:%c(UIButton)]) {
						// hide icon
						subview.alpha = 0;
					}
				}

				UILabel * titleLabel = header.titleLabel;
				titleLabel.alpha = 0;
        	} break;
        case 4: // circle left
			{
				float size = 12;
				view.colorIndicator.frame = CGRectMake(20, (view.frame.size.height - size)/2, size, size);
				view.colorIndicator.layer.cornerRadius = size/2;
				view.colorIndicator.layer.continuousCorners = YES;

				// hide header elements
				PLPlatterHeaderContentView *header = [view valueForKey:@"_headerContentView"];

				for (UIView *subview in header.subviews) {
					if ([subview isKindOfClass:%c(UIButton)]) {
						// hide icon
						subview.alpha = 0;
					}
				}

				UILabel * titleLabel = header.titleLabel;
				titleLabel.alpha = 0;
			} break;
        case 5: // icon left
			{
				float size = 24;
				view.imageIndicator.frame = CGRectMake(20, (view.frame.size.height - size)/2, size, size);

				// hide header elements
				PLPlatterHeaderContentView *header = [view valueForKey:@"_headerContentView"];

				for (UIView *subview in header.subviews) {
					if ([subview isKindOfClass:%c(UIButton)]) {
						// hide icon
						subview.alpha = 0;
					}
				}

				UILabel * titleLabel = header.titleLabel;
				titleLabel.alpha = 0;
        	} break;
        default:
	        {
				view.colorIndicator.frame = CGRectMake(0, 0, 4, view.frame.size.height);
				view.colorIndicator.layer.cornerRadius = 0;
        	} break;
	}
}
%end

%hook PLTitledPlatterView
- (CGRect)_mainContentFrame {
	// needed because else the frame of it cuts of the content after adjustment
	self.customContentView.clipsToBounds = NO;

	CGRect frame = %orig;
	if (style == 3) {
		frame.origin.y = frame.origin.y - 14;
		frame.origin.x = frame.origin.x + 25;
	}
	if (style == 4) {
		frame.origin.y = frame.origin.y - 14;
		frame.origin.x = frame.origin.x + 32;
	}
	if (style == 5) {
		frame.origin.y = frame.origin.y - 14;
		frame.origin.x = frame.origin.x + 45;
	}
	return frame;
}
%end

%hook NCNotificationListView
- (void)layoutSubviews {
	%orig;

	// This are ListViews that contain ALL current notifications and are therefore irrelevant
	if (!self.grouped) return;

	NCNotificationListCell *frontCell = [self _visibleViewAtIndex:0];
	NCNotificationViewControllerView *frontView = [frontCell _notificationCellView];
	NCNotificationShortLookView *shortLookView = (NCNotificationShortLookView *)frontView.contentView;

	if (shortLookView.colorIndicator == nil) return;

	UIImage *icon = shortLookView.icons[0];
	UIColor *dominantColor = [icon velvetDominantColor];

	if (!dominantColor) return;

	// add icon to image indicator
	if (style == 5) {
		shortLookView.imageIndicator.image = icon;
	}

	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:%c(NCNotificationListCell)]) {
			NCNotificationListCell *cell = (NCNotificationListCell *)subview;
			NCNotificationViewControllerView *frontView = [cell _notificationCellView];
			NCNotificationShortLookView *shortLookView = (NCNotificationShortLookView *)frontView.contentView;

			shortLookView.colorIndicator.backgroundColor = dominantColor;
		}
	}
}
%end

// %hook _NCNotificationShortLookScrollView
// -(void)setFrame:(CGRect)frame {

// 	// Make notifications a bit less wide
// 	frame.origin.x = self.superview.frame.origin.x + 10;
// 	frame.size.width = self.superview.frame.size.width - 20;

// 	%orig(frame);

// }
// %end