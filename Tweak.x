#import "Headers.h"
#import "ColorSupport.h"

int style = 5;
BOOL colorPrimaryLabel = NO;
BOOL colorBackground = YES;
BOOL colorBorder = NO;

float iconSize = 40; // 24, 32, 40, 48 are good options

@implementation VelvetIndicatorView
@end

@implementation VelvetBackgroundView
@end

%hook NCNotificationShortLookView
%property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
%property (retain, nonatomic) VelvetBackgroundView * velvetBackground;
%property (retain, nonatomic) UIImageView * imageIndicator;
- (void)layoutSubviews {
	%orig;
	CGRect frame = self.frame;
	self.velvetBackground.frame = frame;
}
%end

%hook NCNotificationShortLookViewController
- (void)viewDidLayoutSubviews {
	%orig;

	NCNotificationShortLookView *view = self.viewForPreview;

	// Notification view is not yet fully initialized
	if (view.frame.size.width == 0) return;

	if (view.colorIndicator == nil) {
		VelvetIndicatorView *colorIndicator = [[VelvetIndicatorView alloc] initWithFrame:CGRectZero];

		[view insertSubview:colorIndicator atIndex:2];
		view.colorIndicator = colorIndicator;
	}

	if (view.velvetBackground == nil) {
		VelvetBackgroundView *velvetBackground = [[VelvetBackgroundView alloc] initWithFrame:CGRectZero];
		velvetBackground.layer.cornerRadius = 13;
		velvetBackground.layer.continuousCorners = YES;

		[view insertSubview:velvetBackground atIndex:1];
		view.velvetBackground = velvetBackground;
	}


	if (view.imageIndicator == nil) {
		UIImageView *imageIndicator = [[UIImageView alloc] initWithFrame:CGRectZero];

		[view insertSubview:imageIndicator atIndex:3];
		view.imageIndicator = imageIndicator;
	}

	switch (style) {
        case 1: { // full bar bottom
			view.colorIndicator.frame = CGRectMake(0, 0, view.frame.size.width, 4);
			view.colorIndicator.layer.cornerRadius = 0;
			view.backgroundMaterialView.layer.cornerRadius = 0;
		} break;
        case 2: { // full bar left
			view.colorIndicator.frame = CGRectMake(0, 0, 4, view.frame.size.height);
			view.colorIndicator.layer.cornerRadius = 0;
			view.backgroundMaterialView.layer.cornerRadius = 0;
		} break;
        case 3: { // rounded bar left
			float width = 3;
			view.colorIndicator.frame = CGRectMake(20, 20, width, view.frame.size.height-40);
			view.colorIndicator.layer.cornerRadius = width/2;
			view.colorIndicator.layer.continuousCorners = YES;

			[self velvetHideHeader];
		} break;
        case 4: { // circle left
			float size = 12;
			view.colorIndicator.frame = CGRectMake(20, (view.frame.size.height - size)/2, size, size);
			view.colorIndicator.layer.cornerRadius = size/2;
			view.colorIndicator.layer.continuousCorners = YES;

			[self velvetHideHeader];
		} break;
        case 5: { // icon left
			view.imageIndicator.frame = CGRectMake(20, (view.frame.size.height - iconSize)/2, iconSize, iconSize);
			view.imageIndicator.image = [self getIconForBundleId:self.notificationRequest.sectionIdentifier];

			[self velvetHideHeader];
		} break;
	}

	UIColor *dominantColor = [self getDominantColor];

	view.colorIndicator.backgroundColor = dominantColor;

	if (colorPrimaryLabel) {
		view.notificationContentView.primaryLabel.textColor = dominantColor;
		// view.notificationContentView.primarySubtitleLabel.textColor = dominantColor;
		// view.notificationContentView.secondaryLabel.textColor = dominantColor;
	}

	if (colorBackground) {
		// backgroundMaterialView only looks good in dark mode
		// view.backgroundMaterialView.backgroundColor = [dominantColor colorWithAlphaComponent:0.6];
		view.velvetBackground.backgroundColor = [dominantColor colorWithAlphaComponent:0.6];
	}

	if (colorBorder) {
		view.backgroundMaterialView.layer.borderColor = dominantColor.CGColor;
		view.backgroundMaterialView.layer.borderWidth = 2;
	}

}

%new
-(void)velvetHideHeader {
	PLPlatterHeaderContentView *header = [self.viewForPreview valueForKey:@"_headerContentView"];

	for (UIView *subview in header.subviews) {
		if ([subview isKindOfClass:%c(UIButton)]) {
			// hide icon
			subview.hidden = YES;
		}
	}

	header.titleLabel.hidden = YES;
}

%new
-(UIColor *)getDominantColor {
	NSString *bundleId = nil;

	if (self.associatedView) {
		// This could be one of those pseudo notifications that are empty, so we have to find the first actual notification in the list to get the color
		NCNotificationListCell *cell = (NCNotificationListCell *)self.associatedView;
		NCNotificationListView *listView = (NCNotificationListView *)cell.superview;

		NCNotificationListCell *frontCell = [listView _visibleViewAtIndex:0];
		NCNotificationViewControllerView *frontView = [frontCell _notificationCellView];
		NCNotificationShortLookView *shortLookView = (NCNotificationShortLookView *)frontView.contentView;

		NCNotificationShortLookViewController *controller = shortLookView._viewControllerForAncestor;
		bundleId = controller.notificationRequest.sectionIdentifier;
	} else {
		// This is a single notification, we can safely use our own bundleId
		bundleId = self.notificationRequest.sectionIdentifier;
	}

	UIImage *icon = [self getIconForBundleId:bundleId];
	return [icon velvetDominantColor];
}

%new
-(UIImage *)getIconForBundleId:(NSString *)bundleId {
	UIImage *icon = [UIImage _applicationIconImageForBundleIdentifier:bundleId format:2 scale:[UIScreen mainScreen].scale];

	if (!icon) {
		// Fallback to the default 20x20 icon
		icon = self.viewForPreview.icons[0];
	}

	return icon;
}
%end

%hook BSUIDefaultDateLabel
-(void)setFrame:(CGRect)frame {
	// Move the dateLabel into the corner to make room for the centered notification text
	if (style == 3 || style == 4 || style == 5) {
		if (self.superview.frame.size.width > 0) {
			frame.origin.y -= 3;
			frame.origin.x += 4;
		}
	}

	%orig;
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
		frame.origin.x = frame.origin.x + (iconSize + 21);
	}
	return frame;
}
%end

%hook NCNotificationContentView
- (void)layoutSubviews {
	%orig;
	CGRect primaryLabelFrame = self.primaryLabel.frame;
	CGRect secondaryLabelFrame = self.secondaryLabel.frame;

	CGFloat labelWidth;

	if (style == 3) {
		labelWidth = 25;
	}
	if (style == 4) {
		labelWidth = 32;
	}
	if (style == 5) {
		labelWidth = (iconSize + 21);
	}

	primaryLabelFrame.size.width = self.primaryLabel.frame.size.width - labelWidth;
	secondaryLabelFrame.size.width = self.secondaryLabel.frame.size.width - labelWidth;

	self.primaryLabel.frame = primaryLabelFrame;
	self.secondaryLabel.frame = secondaryLabelFrame;
}
%end

%ctor {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"Home"
                                                           message:@"Would you like to turn the lights on?"
                                                           bundleID:@"com.apple.Home"];

		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"Instagram"
                                                           message:@"Somebody liked your post."
                                                           bundleID:@"com.burbn.instagram"];

		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"YouTube"
                                                           message:@"PewDiePie uploaded a new video."
                                                           bundleID:@"com.google.ios.youtube"];

		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"iTunes Store"
                                                           message:@"Your favourite artist released a new track!"
                                                           bundleID:@"com.apple.MobileStore"];

		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"Twitter"
                                                           message:@"@HiMyNameIsUbik liked your post."
                                                           bundleID:@"com.atebits.Tweetie2"];

		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"NoisyFlake"
                                                           message:@"ETA?!"
                                                           bundleID:@"com.apple.MobileSMS"];

		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"NoisyFlake"
                                                           message:@"That looks nice!"
                                                           bundleID:@"com.apple.MobileSMS"];
	});
}

// %hook _NCNotificationShortLookScrollView
// -(void)setFrame:(CGRect)frame {

// 	// Make notifications a bit less wide
// 	frame.origin.x = self.superview.frame.origin.x + 10;
// 	frame.size.width = self.superview.frame.size.width - 20;

// 	%orig(frame);

// }
// %end